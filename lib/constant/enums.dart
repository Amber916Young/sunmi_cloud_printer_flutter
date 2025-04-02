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

enum ImageAlgorithm { BINARIZATION, DITHERING }

///*SunmiFontSize*
///Enum to set font in the printer

enum SunmiCutPaper { FULL, HALF }

enum SunmiFontType { LATIN, CJK, OTHER }

enum SunmiCutMode { NORMAL, FULL, HALF, NULL }

enum SunmiFontSize { XXS, XS, SM, MD, LG, XL, XXL, XXXL }

enum SunmiCharacterScale { XXS, XS, SM, MD, LG, XL, XXL, XXXL }

const Map<SunmiFontType, int> fontTypeMap = {
  SunmiFontType.LATIN: 10,
  SunmiFontType.CJK: 11,
  SunmiFontType.OTHER: 12,
};
int buildSize(int multiplier) => (multiplier << 4) | multiplier;

Map<SunmiFontSize, int> fontSize = {
  SunmiFontSize.XXS: buildSize(0), // 1x
  SunmiFontSize.XS: buildSize(1), // 2x
  SunmiFontSize.SM: buildSize(2),
  SunmiFontSize.MD: buildSize(3),
  SunmiFontSize.LG: buildSize(4),
  SunmiFontSize.XL: buildSize(5),
  SunmiFontSize.XXL: buildSize(6),
  SunmiFontSize.XXXL: buildSize(7), // 8x
};

Map<SunmiCharacterScale, (int width, int height)> fontScale = {
  SunmiCharacterScale.XXS: (1, 1),
  SunmiCharacterScale.XS: (2, 1),
  SunmiCharacterScale.SM: (2, 2),
  SunmiCharacterScale.MD: (3, 2),
  SunmiCharacterScale.LG: (3, 3),
  SunmiCharacterScale.XL: (4, 3),
  SunmiCharacterScale.XXL: (4, 4),
  SunmiCharacterScale.XXXL: (5, 5),
};
