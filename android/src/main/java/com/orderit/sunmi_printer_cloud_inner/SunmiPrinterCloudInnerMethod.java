package com.orderit.sunmi_printer_cloud_inner;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.orderit.sunmi_printer_cloud_inner.common.ToastType;
import com.orderit.sunmi_printer_cloud_inner.util.TaskHandleUtil;
import com.orderit.sunmi_printer_cloud_inner.util.TaskTimeoutUtil;
import com.sunmi.cloudprinter.bean.Router;
import com.sunmi.externalprinterlibrary2.ConnectCallback;
import com.sunmi.externalprinterlibrary2.PropCallback;
import com.sunmi.externalprinterlibrary2.ResultCallback;
import com.sunmi.externalprinterlibrary2.SearchCallback;
import com.sunmi.externalprinterlibrary2.SetWifiCallback;
import com.sunmi.externalprinterlibrary2.StatusCallback;
import com.sunmi.externalprinterlibrary2.SunmiPrinterManager;
import com.sunmi.externalprinterlibrary2.WifiResult;
import com.sunmi.externalprinterlibrary2.exceptions.PrinterException;
import com.sunmi.externalprinterlibrary2.exceptions.SearchException;
import com.sunmi.externalprinterlibrary2.printer.CloudPrinter;
import com.sunmi.externalprinterlibrary2.style.AlignStyle;
import com.sunmi.externalprinterlibrary2.style.BarcodeType;
import com.sunmi.externalprinterlibrary2.style.CloudPrinterStatus;
import com.sunmi.externalprinterlibrary2.style.CutterMode;
import com.sunmi.externalprinterlibrary2.style.EncodeType;
import com.sunmi.externalprinterlibrary2.style.ErrorLevel;
import com.sunmi.externalprinterlibrary2.style.HriStyle;
import com.sunmi.externalprinterlibrary2.style.ImageAlgorithm;
import com.sunmi.externalprinterlibrary2.style.UnderlineStyle;

import org.json.JSONArray;
import org.json.JSONObject;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class SunmiPrinterCloudInnerMethod implements ResultCallback {
    private final String TAG = SunmiPrinterCloudInnerMethod.class.getSimpleName();
    private final Context _context;
    private MethodChannel _methodChannel;
    private CloudPrinter _currentCloudPrinter;
    private HashMap<String, CloudPrinter> _cloudPrinters = new HashMap<>();
    private HashMap<String, Router> _routers = new HashMap<>();
    final int timeoutSeconds = 30;

    public SunmiPrinterCloudInnerMethod(Context context) {
        this._context = context;
    }

    /**
     * Setup cloud printer.
     */

    public void searchPrinters(Context context, int searchMethod, MethodChannel.Result result) {
        List<Map<String, Object>> printerList = new ArrayList<>();
        _cloudPrinters = new HashMap<>();
        Handler handler = new Handler(Looper.getMainLooper());
        Log.d(TAG, "Start searching printers...");
        try {
            SunmiPrinterManager.getInstance().searchCloudPrinter(context, searchMethod, printer -> {
                String name = printer.getCloudPrinterInfo().name;
                if (_cloudPrinters.containsKey(name)) return;
                Map<String, Object> printerData = new HashMap<>();
                printerData.put("name", name);
                printerData.put("macAddress", printer.getCloudPrinterInfo().mac);
                printerData.put("ipAddress", printer.getCloudPrinterInfo().address);
                printerData.put("port", printer.getCloudPrinterInfo().port);
                printerData.put("isConnected", printer.isConnected());
                printerList.add(printerData);
                _cloudPrinters.put(name, printer);
                Log.d(TAG, "Printer found: " + printerData);
            });

            // Stop search and return after 10 seconds
            handler.postDelayed(() -> {
                Log.d(TAG, "Stopping search and returning printers");
                try {
                    stopSearch(searchMethod);
                } catch (SearchException e) {
                    throw new RuntimeException(e);
                }
                result.success(printerList);
            }, 10000);

        } catch (SearchException e) {
            Log.e(TAG, "Exception during printer search", e);
        }
    }


    public Map<String, Object> getCurrentPrinterInfo() {
        Map<String, Object> printerData = new HashMap<>();
        printerData.put("name", _currentCloudPrinter.getCloudPrinterInfo().name);
        printerData.put("macAddress", _currentCloudPrinter.getCloudPrinterInfo().mac);
        printerData.put("ipAddress", _currentCloudPrinter.getCloudPrinterInfo().address);
        printerData.put("port", _currentCloudPrinter.getCloudPrinterInfo().port);
        printerData.put("isConnected", _currentCloudPrinter.isConnected());
        Log.e("getCurrentPrinterInfo", _currentCloudPrinter.toString());
        return printerData;
    }

    public Map<String, Object> getCloudPrinterByName(String name) {
        CloudPrinter printer = getCloudPrinter(name);
        Map<String, Object> printerData = new HashMap<>();
        printerData.put("name", name);
        printerData.put("macAddress", printer.getCloudPrinterInfo().mac);
        printerData.put("ipAddress", printer.getCloudPrinterInfo().address);
        printerData.put("port", printer.getCloudPrinterInfo().port);
        printerData.put("isConnected", printer.isConnected());
        return printerData;
    }


    public void startPrinterWifi(String name, String sn, MethodChannel.Result result, EventChannel.EventSink eventSink) {
        _currentCloudPrinter = getCloudPrinter(name);
        discount();
        SunmiPrinterManager.getInstance().startPrinterWifi(_context, _currentCloudPrinter, sn);
        initSearch(result, eventSink);
    }

    private void initSearch(MethodChannel.Result result, EventChannel.EventSink eventSink) {
        List<Map<String, Object>> routers = new ArrayList<>();
        _routers = new HashMap<>();
        if (_currentCloudPrinter == null) {
            Log.e(TAG, "Current cloud printer is null.");
            result.success(routers);
            if (eventSink != null) eventSink.endOfStream();
            return;
        }

        Log.d(TAG, "Start searching routers...");

        SunmiPrinterManager.getInstance().searchPrinterWifiList(_context, _currentCloudPrinter, new WifiResult() {
            @Override
            public void onRouterFound(Router router) {
                String name = router.getName();
                if (_routers.containsKey(name)) return;

                Map<String, Object> routerData = new HashMap<>();
                routerData.put("name", name);
                routerData.put("hasPwd", router.isHasPwd());
                routerData.put("pwd", router.getPwd());
                routerData.put("rssi", router.getRssi());
                routers.add(routerData);
                _routers.put(name, router);
                Log.d(TAG, "Router found: " + routerData);
                if (eventSink != null) {
                    eventSink.success(routerData);
                }
            }

            @Override
            public void onFinish() {
                Log.d(TAG, "Wi-Fi search finished. Total: " + routers.size());
                result.success(routers);
                if (eventSink != null) {
                    eventSink.endOfStream();
                }
            }

            @Override
            public void onFailed() {
                Log.e(TAG, "Wi-Fi search failed.");
                _routers = new HashMap<>();
                result.error("SEARCH_FAILED", "Failed to search printer Wi-Fi list", null);
                // Notify Flutter of an error
                if (eventSink != null) {
                    eventSink.error("SEARCH_FAILED", "Failed to search printer Wi-Fi list", null);
                }
            }
        });

    }

    public void deleteWifiConfig() {
        SunmiPrinterManager.getInstance().deletePrinterWifi(_context, _currentCloudPrinter);
    }

    public void existWifiConfig() {
        SunmiPrinterManager.getInstance().exitPrinterWifi(_context, _currentCloudPrinter);
    }

    //connect wifi
    public void configWifi(String name, String printer_name, String pwd) {
        if (checkConnect()) {
            Router currentRouter = getRouters(name);
            _currentCloudPrinter = getCloudPrinter(printer_name);
            TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<Void>() {
                @Override
                public void register(TaskHandleUtil.Callback<Void> callback) {
                    SunmiPrinterManager.getInstance().setPrinterWifi(_context, _currentCloudPrinter, currentRouter.getEssid(), pwd, new SetWifiCallback() {
                        @Override
                        public void onSetWifiSuccess() {
                            Log.e(TAG, "onSetWifiSuccess");
                        }

                        @Override
                        public void onConnectWifiSuccess() {
                            Log.e(TAG, "onConnectWifiSuccess");
                        }

                        @Override
                        public void onConnectWifiFailed() {
                            Log.e(TAG, "onConnectWifiFailed");
                        }
                    });
                }
            });
        }
    }

    //connect ble
    public void connectCloudPrinterByName(String name) throws PrinterException {
        _currentCloudPrinter = getCloudPrinter(name);
        if (_currentCloudPrinter == null) {
            Log.e(TAG, "No printer found with the name: ");
            return;
        }

        TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<Void>() {
            @Override
            public void register(TaskHandleUtil.Callback<Void> callback) {
                _currentCloudPrinter.connect(_context, new ConnectCallback() {
                    @Override
                    public void onConnect() {
                        Log.d(TAG, "Successfully connected to printer.");
                        callback.onSuccess(null);
                    }

                    @Override
                    public void onFailed(String reason) {
                        Log.e(TAG, "Failed to connect to printer: " + reason);
                        callback.onError(new PrinterException(reason));
                    }

                    @Override
                    public void onDisConnect() {
                        Log.d(TAG, "Disconnected from printer.");
                    }
                });
            }
        });

    }

    //connect ip
    public void createCloudPrinterAndConnect(String ip, int port) throws PrinterException {
        _currentCloudPrinter = SunmiPrinterManager.getInstance().createCloudPrinter(ip, port);
        TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<Void>() {
            @Override
            public void register(TaskHandleUtil.Callback<Void> callback) {
                _currentCloudPrinter.connect(_context, new ConnectCallback() {
                    @Override
                    public void onConnect() {
                        Log.d(TAG, "Successfully connected to printer.");
                        _cloudPrinters.put(_currentCloudPrinter.getCloudPrinterInfo().name, _currentCloudPrinter);
                        callback.onSuccess(null);
                    }

                    @Override
                    public void onFailed(String reason) {
                        Log.e(TAG, "Failed to connect to printer: " + reason);
                        callback.onError(new PrinterException(reason));
                    }

                    @Override
                    public void onDisConnect() {
                        Log.d(TAG, "Disconnected from printer.");
                    }
                });
            }
        });
    }

    public void discount() {
        if (_currentCloudPrinter != null) {
            _currentCloudPrinter.release(_context);
        }
    }

    /**
     * @param text
     * @throws PrinterException printText
     */
    public void printText(String text) {
        if (checkConnect()) {
            _currentCloudPrinter.printText(text + '\n');
        }
    }


    public void initStyle() {
        if (checkConnect()) {
            _currentCloudPrinter.initStyle();
        }
    }


    public void printAppendText(String text) throws PrinterException {
        if (checkConnect()) {
            _currentCloudPrinter.appendText(text);
        }
    }

    /**
     * @param n
     * @throws PrinterException printNextLine
     */
    public void printNLine(int n) throws PrinterException {
        if (checkConnect() && n > 0) {
            for (int i = 0; i < n; i++) {
                _currentCloudPrinter.printText("\n");
            }
        }
    }

    public void printRow(String colsStr) {
        try {
            JSONArray cols = new JSONArray(colsStr);
            String[] colsText = new String[cols.length()];
            int[] colsWidth = new int[cols.length()];
            AlignStyle[] colsAlign = new AlignStyle[cols.length()];
            for (int i = 0; i < cols.length(); i++) {
                JSONObject col = cols.getJSONObject(i);
                String textColumn = col.getString("text");
                int widthColumn = col.getInt("width");
                int alignColumn = col.getInt("align");
                colsText[i] = textColumn;
                colsWidth[i] = widthColumn;
                Log.d(TAG, textColumn + "  " + widthColumn + "  " + alignColumn);

                switch (alignColumn) {
                    case 1:
                        colsAlign[i] = AlignStyle.CENTER;
                        break;
                    case 2:
                        colsAlign[i] = AlignStyle.RIGHT;
                        break;
                    default:
                        colsAlign[i] = AlignStyle.LEFT;

                }
            }
            _currentCloudPrinter.printColumnsText(colsText, colsWidth, colsAlign);

        } catch (Exception err) {
            Log.d(TAG, err.getMessage());
        }
    }

    public void printImage(byte[] bytes, int modeInt) {
        Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        ImageAlgorithm mode = switch (modeInt) {
            case 1 -> ImageAlgorithm.DITHERING;
            default -> ImageAlgorithm.BINARIZATION;
        };
        _currentCloudPrinter.printImage(bitmap, mode);

    }

    public void printBarcode(String data, int barcodeType, int textPosition, int size, int height) {
        BarcodeType codeType = BarcodeType.CODE128;
        HriStyle style = HriStyle.HIDE;
        codeType = switch (barcodeType) {
            case 0 -> BarcodeType.UPCA;
            case 1 -> BarcodeType.UPCE;
            case 2 -> BarcodeType.EAN13;
            case 3 -> BarcodeType.EAN8;
            case 4 -> BarcodeType.CODE39;
            case 5 -> BarcodeType.ITF;
            case 6 -> BarcodeType.CODABAR;
            case 7 -> BarcodeType.CODE93;
            case 8 -> BarcodeType.CODE128;
            default -> codeType;
        };
        style = switch (textPosition) {
            case 0 -> HriStyle.HIDE;
            case 1 -> HriStyle.ABOVE;
            case 2 -> HriStyle.BELOW;
            case 3 -> HriStyle.BOTH;
            default -> style;
        };
        _currentCloudPrinter.printBarcode(data, codeType, height, size, style);

    }

    public void printQRCode(String data, int modulesize, int errorlevel) {
        ErrorLevel level = ErrorLevel.H;
        level = switch (errorlevel) {
            case 0 -> ErrorLevel.L;
            case 1 -> ErrorLevel.M;
            case 2 -> ErrorLevel.Q;
            case 3 -> ErrorLevel.H;
            default -> level;
        };
        _currentCloudPrinter.printQrcode(data, modulesize, level);
    }

    public void printRawData(byte[] bytes) {
        _currentCloudPrinter.appendRawData(bytes);
    }

    public void setPrintWidth(int width) {
        _currentCloudPrinter.setPrintWidth(width);
    }

    public void setBlackWhiteReverseMode(boolean reverse) {
        _currentCloudPrinter.setBlackWhiteReverseMode(reverse);
    }

    public void setUpsideDownMode(boolean enable) {
        _currentCloudPrinter.setUpsideDownMode(enable);
    }

    public void setCharacterSize(int width, int height) {
        _currentCloudPrinter.setCharacterSize(width, height);
    }

    public void dotsFeed(int dots) {
        _currentCloudPrinter.dotsFeed(dots);
    }

    public void lineFeed(int lines) {
        _currentCloudPrinter.lineFeed(lines);
    }

    public void horizontalTab(int tab) {
        _currentCloudPrinter.horizontalTab(tab);
    }

    public void setAbsolutePrintPosition(int position) {
        _currentCloudPrinter.setAbsolutePrintPosition(position);
    }

    public void setRelativePrintPosition(int position) {
        _currentCloudPrinter.setRelativePrintPosition(position);
    }

    public void setUnderline(int underline) {
        UnderlineStyle mode = UnderlineStyle.EMPTY;
        mode = switch (underline) {
            case 0 -> UnderlineStyle.EMPTY;
            case 1 -> UnderlineStyle.ONE;
            case 2 -> UnderlineStyle.TWO;
            default -> mode;
        };
        _currentCloudPrinter.setUnderlineMode(mode);
    }

    public void setAlignment(int alignmentInt) {
        AlignStyle alignment = AlignStyle.LEFT;
        alignment = switch (alignmentInt) {
            case 0 -> AlignStyle.LEFT;
            case 1 -> AlignStyle.CENTER;
            case 2 -> AlignStyle.RIGHT;
            default -> alignment;
        };
        _currentCloudPrinter.setAlignment(alignment);
    }

    public void setBold(boolean bold) {
        _currentCloudPrinter.setBoldMode(bold);
    }

    public void setLeftSpace(int space) {
        _currentCloudPrinter.setLeftSpace(space);
    }

    public void setLineSpace(int space) {
        _currentCloudPrinter.setLineSpacing(space);
    }

    public void setFontTypeSize(int size, int type) {
        int fontId = 1;
        switch (type) {
            case 10:
                _currentCloudPrinter.selectAsciiCharFont(fontId);
                _currentCloudPrinter.setAsciiSize(size);
                break;
            case 11:
                _currentCloudPrinter.selectCjkCharFont(fontId);
                _currentCloudPrinter.setCjkSize(size);
                break;
            case 12:
                _currentCloudPrinter.selectOtherCharFont(fontId);
                _currentCloudPrinter.setOtherSize(size);
                break;
        }
    }

    public void selectVectorFont() {
        _currentCloudPrinter.selectAsciiCharFont(1);
        _currentCloudPrinter.selectCjkCharFont(1);
        _currentCloudPrinter.selectOtherCharFont(1);
    }

    public void selectBitMapFont() {
        _currentCloudPrinter.selectAsciiCharFont(0);
        _currentCloudPrinter.selectCjkCharFont(0);
        _currentCloudPrinter.selectOtherCharFont(0);
    }


    public void cutPaper(boolean fullCut) {
        Log.e("cutPaper", String.valueOf(fullCut));
        _currentCloudPrinter.cutPaper(fullCut);
    }

    public void cutPostPaper(boolean fullCut, int distance) {
        _currentCloudPrinter.postCutPaper(fullCut, distance);
    }

    public void setPrintDensity(int density) {
        _currentCloudPrinter.setPrintDensity(density);
    }

    public void setPrintSpeed(int speed) {
        _currentCloudPrinter.setPrintSpeed(speed);
    }

    public void setPrintCutter(int mode) {
        CutterMode cutterMode = CutterMode.NULL;
        cutterMode = switch (mode) {
            case 0 -> CutterMode.NULL;
            case 1 -> CutterMode.NORMAL;
            case 2 -> CutterMode.HALF;
            case 3 -> CutterMode.ALL;
            default -> cutterMode;
        };
        _currentCloudPrinter.setPrintCutter(cutterMode);
    }

    public void setEncodeMode(int mode) {
        EncodeType type = EncodeType.GB18030;
        type = switch (mode) {
            case 0 -> EncodeType.UTF_8;
            case 1 -> EncodeType.ASCII;
            case 2 -> EncodeType.GB18030;
            case 3 -> EncodeType.BIG5;
            case 4 -> EncodeType.SHIFT_JIS;
            case 5 -> EncodeType.JIS_0208;
            case 6 -> EncodeType.KSC_5601;
            default -> type;
        };
        _currentCloudPrinter.setEncodeMode(type);
    }

    public void restoreDefaultSettings() {
        _currentCloudPrinter.restoreDefaultSettings();
    }

    public String getDeviceSN() {
        String result = TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<String>() {
            @Override
            public void register(TaskHandleUtil.Callback<String> callback) {
                _currentCloudPrinter.getDeviceSN(new PropCallback() {
                    @Override
                    public void onProperty(String s) {
                        Log.i("getDeviceSN", s);
                        callback.onSuccess(s);
                    }
                });
            }
        });
        return result != null ? result : "UNKNOWN";
    }

    public String getDeviceState() {
        Log.i("getDeviceState", _currentCloudPrinter.getCloudPrinterInfo().name);
        Log.i("getDeviceState", _currentCloudPrinter.getCloudPrinterInfo().mac);
        Log.i("getDeviceState", String.valueOf(_currentCloudPrinter.isConnected()));
        _currentCloudPrinter.getDeviceState(new StatusCallback() {
            @Override
            public void onResult(CloudPrinterStatus cloudPrinterStatus) {
                Log.i("getDeviceState", cloudPrinterStatus.name());
            }
        });
        return "";
//        String result = TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<String>() {
//            @Override
//            public void register(TaskHandleUtil.Callback<String> callback) {
//                Log.i("getDeviceState", _currentCloudPrinter.getCloudPrinterInfo().name);
//                Log.i("getDeviceState", _currentCloudPrinter.getCloudPrinterInfo().mac);
//                Log.i("getDeviceState", String.valueOf(_currentCloudPrinter.isConnected()));
//
//                _currentCloudPrinter.getDeviceState(new StatusCallback() {
//                    @Override
//                    public void onResult(CloudPrinterStatus cloudPrinterStatus) {
//                        Log.i("getDeviceState", cloudPrinterStatus.name());
//                        callback.onSuccess(cloudPrinterStatus.name());
//                    }
//                });
//            }
//        });
//        return result != null ? result : "UNKNOWN";
    }


    public String getDeviceMode() {
        String result = TaskHandleUtil.runAsyncWithCallback(new TaskHandleUtil.CallbackRegistrar<String>() {
            @Override
            public void register(TaskHandleUtil.Callback<String> callback) {
                _currentCloudPrinter.getDeviceModel(new PropCallback() {
                    @Override
                    public void onProperty(String s) {
                        Log.i("getDeviceMode", s);
                        callback.onSuccess(s);
                    }
                });
            }
        });
        return result != null ? result : "UNKNOWN";
    }


    public void stopSearch(int searchMethod) throws SearchException {
        SunmiPrinterManager.getInstance().stopSearch(_context, searchMethod);
    }

    public void commitTransBuffer() {
        _currentCloudPrinter.commitTransBuffer(this);
    }


    public void clearTransBuffer() {
        _currentCloudPrinter.clearTransBuffer();
    }

    private CloudPrinter getCloudPrinter(String name) {
        return _cloudPrinters.get(name);
    }

    private Router getRouters(String name) {
        return _routers.get(name);
    }

    private boolean checkConnect() {
        if (_currentCloudPrinter == null) {
            return false;
        }
        return _currentCloudPrinter.isConnected();
    }


    @Override
    public void onComplete() {
        Log.e(TAG, "onComplete");

    }

    @Override
    public void onFailed(CloudPrinterStatus cloudPrinterStatus) {
        Log.e(TAG, "onFailed===>" + cloudPrinterStatus.name());

    }

    public void setMethodChannel(MethodChannel channel) {
        this._methodChannel = channel;
    }

    private void showToast(String message, ToastType type) {
        if (_methodChannel != null) {
            new Handler(Looper.getMainLooper()).post(() -> {
                Map<String, String> toastData = new HashMap<>();
                toastData.put("message", message);
                toastData.put("type", type.name()); // "SUCCESS", "FAIL", "WARN"
                _methodChannel.invokeMethod("showToast", toastData);
            });

        }
    }


}