package com.orderit.sunmi_printer_cloud_inner;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import com.sunmi.externalprinterlibrary2.printer.CloudPrinter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SunmiPrinterCloudInnerPlugin
 */
public class SunmiPrinterCloudInnerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private Context context;
    private MethodChannel channel;
    private static SunmiPrinterCloudInnerMethod sunmiPrinterMethod;
    private static final int REQUEST_CODE = 1001;
    private android.app.Activity activity;
    private final String TAG = SunmiPrinterCloudInnerPlugin.class.getSimpleName();
    private EventChannel.EventSink eventSink;

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext(); // Initialize context
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sunmi_printer_cloud_inner");
        channel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "sunmi_printer_cloud_inner/SEARCH_WIFI");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink sink) {
                Log.d(TAG, "EventChannel onListen triggered");
                eventSink = sink;
            }

            @Override
            public void onCancel(Object arguments) {
                Log.d(TAG, "EventChannel onCancel triggered");
                eventSink = null;
            }
        });
        sunmiPrinterMethod = new SunmiPrinterCloudInnerMethod(flutterPluginBinding.getApplicationContext());
        sunmiPrinterMethod.setMethodChannel(channel);

    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.wtf("Method:", call.method);
        switch (call.method) {
            case "CONNECT_BY_NAME":
                String name = call.argument("name");
                try {
                    sunmiPrinterMethod.connectCloudPrinterByName(name);
                    result.success(true);
                } catch (Exception ignored) {
                    result.error("CONNECT_BY_NAME", "Exception: " + ignored.getMessage(), null);
                    break;
                }
                break;
            case "CONNECT_BY_IP_PORT":
                String ip = call.argument("ip");
                int port = call.argument("port");
                try {
                    sunmiPrinterMethod.createCloudPrinterAndConnect(ip, port);
                    result.success(true);
                } catch (Exception ignored) {
                    result.error("CONNECT_BY_IP_PORT", "Exception: " + ignored.getMessage(), null);
                    break;
                }
                break;
            case "GET_CURRENT_PRINTER":
                Map<String, Object> printer = new HashMap<>();
                try {
                    printer = sunmiPrinterMethod.getCurrentPrinterInfo();
                } catch (Exception ignored) {
                    result.success(new HashMap<>());
                    break;
                }
                result.success(printer);
                break;
            case "GET_PRINTER_BY_NAME":
                try {
                    printer = sunmiPrinterMethod.getCloudPrinterByName(call.argument("name"));
                } catch (Exception ignored) {
                    Log.e(TAG, "Exception GET_CURRENT_PRINTER", ignored);
                    result.success(new HashMap<>());
                    break;
                }
                result.success(printer);
                break;


            case "DELETE_WIFI_CONFIG":
                sunmiPrinterMethod.deleteWifiConfig();
                result.success(true);
                break;
            case "EXIST_WIFI_CONFIG":
                sunmiPrinterMethod.existWifiConfig();
                result.success(true);
                break;
            case "CONNECT_WIFI":
                sunmiPrinterMethod.configWifi(call.argument("name"), call.argument("printer_name"), call.argument("pwd"));
                result.success(true);
                break;
            case "CONNECT_WIFI_BY_SN":
                sunmiPrinterMethod.startPrinterWifi(call.argument("name"), call.argument("sn"), result, eventSink);
                break;


            case "DISCOUNT":
                try {
                    sunmiPrinterMethod.discount();
                } catch (Exception ignored) {
                    Log.e(TAG, "Exception during RELEASE", ignored);
                    result.success(false);
                    break;
                }
                result.success(true);
                break;
            case "SEARCH_PRINTER":
                boolean isGranted = requestPermission();
                if (!isGranted) {
                    result.success(false);
                    break;
                }
                int searchMethod = call.argument("searchMethod");
                try {
                    sunmiPrinterMethod.searchPrinters(context, searchMethod, result);
                } catch (Exception e) {
                    Log.e(TAG, "Exception during printer search", e);
                    result.error("SEARCH_EXCEPTION", "Exception: " + e.getMessage(), null);
                }

                break;


            case "STOP_SEARCH_PRINTER":
                int searchMethod2 = call.argument("searchMethod");
                try {
                    sunmiPrinterMethod.stopSearch(searchMethod2);
                } catch (Exception exception) {
                    Log.e(TAG, "Exception during printer search", exception);
                    result.success(false);
                    break;
                }
                result.success(true);
                break;

            case "COMMIT_PRINTER_BUFFER":
                sunmiPrinterMethod.commitTransBuffer();
                result.success(true);
                break;
            case "CLEAR_BUFFER":
                sunmiPrinterMethod.clearTransBuffer();
                break;
            case "PRINT_TEXT":
                sunmiPrinterMethod.printText(call.argument("text"));
                result.success(true);
                break;

            case "PRINT_RAW_DATA":
                sunmiPrinterMethod.printRawData(call.argument("data"));
                result.success(true);
                break;
            case "MOVE_N_LINE":
                sunmiPrinterMethod.printNLine(call.argument("lines"));
                result.success(true);
                break;
            case "APPEND_TEXT":
                sunmiPrinterMethod.printAppendText(call.argument("text"));
                result.success(true);
                break;
            case "PRINT_ROW":
                sunmiPrinterMethod.printRow(call.argument("cols"));
                result.success(true);
                break;
            case "PRINT_IMAGE":
                byte[] bytes = call.argument("bitmap");
                int mode = call.argument("mode");
                sunmiPrinterMethod.printImage(bytes, mode);
                result.success(true);
                break;
            case "PRINT_BARCODE":
                String barCodeData = call.argument("data");
                int barcodeType = call.argument("barcodeType");
                int textPosition = call.argument("textPosition");
                int size = call.argument("size");
                int height = call.argument("height");
                sunmiPrinterMethod.printBarcode(barCodeData, barcodeType, textPosition, size, height);
                result.success(true);
                break;

            case "PRINT_QRCODE":
                String qRCodedata = call.argument("data");
                int modulesize = call.argument("modulesize");
                int errorlevel = call.argument("errorlevel");
                sunmiPrinterMethod.printQRCode(qRCodedata, modulesize, errorlevel);
                result.success(true);
                break;

            case "INIT_STYLE":
                sunmiPrinterMethod.initStyle();
                result.success(true);
                break;


            case "SET_PRINT_WIDTH":
                int width = call.argument("width");
                sunmiPrinterMethod.setPrintWidth(width);
                result.success(true);
                break;

            case "SET_BLACK_WHITE_REVERSE":
                boolean reverse = call.argument("reverse");
                sunmiPrinterMethod.setBlackWhiteReverseMode(reverse);
                result.success(true);
                break;

            case "SET_SIDE_DOWN":
                boolean enableUpsideDown = call.argument("enable");
                sunmiPrinterMethod.setUpsideDownMode(enableUpsideDown);
                result.success(true);
                break;

            case "SET_CHARACTER_SIZE":
                int characterWidth = call.argument("width");
                int characterHeight = call.argument("height");
                sunmiPrinterMethod.setCharacterSize(characterWidth, characterHeight);
                result.success(true);
                break;

            case "SET_DOTS_FEED":
                int dots = call.argument("dots");
                sunmiPrinterMethod.dotsFeed(dots);
                result.success(true);
                break;

            case "SET_LINE_FEED":
                int lines = call.argument("lines");
                sunmiPrinterMethod.lineFeed(lines);
                result.success(true);
                break;

            case "SET_HORIZONTAL_TAB":
                int tab = call.argument("tab");
                sunmiPrinterMethod.horizontalTab(tab);
                result.success(true);
                break;

            case "SET_ABS_POSITION":
                int absPosition = call.argument("position");
                sunmiPrinterMethod.setAbsolutePrintPosition(absPosition);
                result.success(true);
                break;

            case "SET_RELATIVE_POSITION":
                int relativePosition = call.argument("position");
                sunmiPrinterMethod.setRelativePrintPosition(relativePosition);
                result.success(true);
                break;

            case "SET_UNDERLINE":
                int underline = call.argument("underline");
                sunmiPrinterMethod.setUnderline(underline);
                result.success(true);
                break;

            case "SET_ALIGNMENT":
                int alignment = call.argument("alignment");
                sunmiPrinterMethod.setAlignment(alignment);
                result.success(true);
                break;

            case "SET_BOLD":
                boolean bold = call.argument("bold");
                sunmiPrinterMethod.setBold(bold);
                result.success(true);
                break;

            case "SET_LEFT_SPACE":
                int leftSpace = call.argument("space");
                sunmiPrinterMethod.setLeftSpace(leftSpace);
                result.success(true);
                break;

            case "SET_LINE_SPACE":
                int lineSpace = call.argument("space");
                sunmiPrinterMethod.setLineSpace(lineSpace);
                result.success(true);
                break;
            case "SET_FONT_TYPE_SIZE":
                int fontSize = call.argument("size");
                int fontType = call.argument("font_type");
                sunmiPrinterMethod.setFontTypeSize(fontSize, fontType);
                result.success(true);
                break;
            case "SET_BITMAP_FONT":
                sunmiPrinterMethod.selectBitMapFont();
                result.success(true);
                break;
            case "SET_VECTOR_FONT":
                sunmiPrinterMethod.selectVectorFont();
                result.success(true);
                break;
            case "CUT_PAPER":
                boolean cutType = call.argument("cut_type");
                sunmiPrinterMethod.cutPaper(cutType);
                result.success(true);
                break;

            case "CUT_POST_PAPER":
                boolean postCutType = call.argument("cut_type");
                int distance = call.argument("dis");
                sunmiPrinterMethod.cutPostPaper(postCutType, distance);
                result.success(true);
                break;

            case "SET_PRINTER_DENSITY":
                int density = call.argument("density");
                sunmiPrinterMethod.setPrintDensity(density);
                result.success(true);
                break;

            case "SET_PRINTER_SPEED":
                int speed = call.argument("speed");
                sunmiPrinterMethod.setPrintSpeed(speed);
                result.success(true);
                break;

            case "SET_PRINTER_CUT":
                int cutMode = call.argument("cut_model");
                sunmiPrinterMethod.setPrintCutter(cutMode);
                result.success(true);
                break;

            case "SET_ENCODE_MODE":
                int encodeMode = call.argument("encode_mode");
                sunmiPrinterMethod.setEncodeMode(encodeMode);
                result.success(true);
                break;

            case "RESTORE_DEFAULT_SETTING":
                sunmiPrinterMethod.restoreDefaultSettings();
                result.success(true);
                break;

            case "GET_DEVICE_SN":
                String deviceSN = sunmiPrinterMethod.getDeviceSN();
                result.success(deviceSN);
                break;

            case "GET_STATE_STATE":
                String deviceState = sunmiPrinterMethod.getDeviceState();
                result.success(deviceState);
                break;

            case "GET_DEVICE_MODE":
                String deviceMode = sunmiPrinterMethod.getDeviceMode();
                result.success(deviceMode);
                break;
            case "INSTALL_FONT_FROM_ASSETS":
                String assetPath = call.argument("asset_path");
                int slotId = call.argument("slot_id");
                installFontFromAssets(context, assetPath, slotId);
                result.success(true);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    public void installFontFromAssets(Context context, String assetPath, int slotId) {
        try {
            InputStream is = context.getAssets().open(assetPath);

            File fontDir = new File(context.getFilesDir(), "sunmi_fonts");
            if (!fontDir.exists()) fontDir.mkdirs();

            File fontFile = new File(fontDir, "font_slot_" + slotId + ".ttf");

            OutputStream os = new FileOutputStream(fontFile);
            byte[] buffer = new byte[1024];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
            os.flush();
            os.close();
            is.close();

            // TODO: If you have API to register the font with the printer, call it here.
            Log.d("FontInstall", "Font copied to " + fontFile.getAbsolutePath());

        } catch (IOException e) {
            e.printStackTrace();
            Log.e("FontInstall", "Font install failed: " + e.getMessage());
        }
    }

    private boolean requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // Android 12+
            if (activity.checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED || activity.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED || activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

                Log.d(TAG, "Requesting BLUETOOTH_SCAN, BLUETOOTH_CONNECT, and ACCESS_FINE_LOCATION");

                activity.requestPermissions(new String[]{Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_CODE);

                return false; // Permissions are not yet granted
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) { // Android 6.0 to 11
            if (activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Requesting ACCESS_FINE_LOCATION");

                activity.requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION,}, REQUEST_CODE);

                return false; // Permissions are not yet granted
            }
        } else {
            Log.d(TAG, "Permissions not required for versions below Android 6.0");
        }

        // All necessary permissions are already granted
        return true;
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        context = null;
    }


}
