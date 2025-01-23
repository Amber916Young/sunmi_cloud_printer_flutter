library enums;

///*PrinterStatus*
///
///This enum will give you the status of the printer.
///Sometimes the status can be ERROR, but don't worry about this status, always try co print anyway!
enum CloudPrinterStatus {
  OFFLINE,
  UNKNOWN,
  RUNNING,
  NEAR_OUT_PAPER,
  OUT_PAPER,
  JAM_PAPER,
  PICK_PAPER,
  COVER,
  OVER_HOT,
  MOTOR_HOT
}

///*PrinterMode*
///
///Enum to set printer mode
enum PrinterMode { UNKNOWN, NORMAL_MODE, BLACK_LABEL_MODE, LABEL_MODE }

enum EncodeType { ASCII, GB18030, BIG5, SHIFT_JIS, JIS_0208, KSC_5601, UTF_8 }

///*SunmiPrintAlign*
///
///Enum to set printer aligntment
enum SunmiPrintAlign { LEFT, CENTER, RIGHT }

///*SunmiQrcodeLevel*
///
//Enum to set a QRcode Level (Low to High)
enum SunmiQrcodeLevel { LEVEL_L, LEVEL_M, LEVEL_Q, LEVEL_H }

enum SunmiUnderline { EMPTY, ONE, TWO }

///*SunmiBarcodeType*
///
///Enum to set Barcode Type
enum SunmiCloudPrinterBarcodeType { UPCA, UPCE, EAN13, EAN8, CODE39, ITF, CODABAR, CODE93, CODE128 }

///*SunmiBarcodeTextPos*
///
///Enum to set how the thex will be printed in barcode
enum SunmiHriStyle { HIDE, ABOVE, BELOW, BOTH }

enum FontType { LATIN, CJK, OTHER }

enum ImageAlgorithm { BINARIZATION, DITHERING }

///*SunmiFontSize*
///Enum to set font in the printer
enum SunmiFontSize { XS, SM, MD, LG, XL }

enum SunmiCutPaper { FULL, HALF }

enum SunmiCutMode { NORMAL, FULL, HALF, NULL }
