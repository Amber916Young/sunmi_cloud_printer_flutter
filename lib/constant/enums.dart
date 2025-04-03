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

enum SunmiPrinterPaper { PAPER58, PAPER80 }

enum SunmiFontType { LATIN, CJK, OTHER }

enum SunmiCutMode { NORMAL, FULL, HALF, NULL }

enum SunmiFontSize { XXS, XS, SM, MD, LG, XL, XXL, XXXL }

// works for both Vector Font and Bitmap Font
enum SunmiCharacterScale {
  NORMAL, // 1x1
  WIDE, // 2x1
  TALL, // 1x2
  SM, // 2x2
  MD, // 3x2
  LG, // 3x3
  XL, // 4x4
  XXL, // 5x5
  XXXL, // 6x6
}

const Map<SunmiFontType, int> fontTypeMap = {
  SunmiFontType.LATIN: 10,
  SunmiFontType.CJK: 11,
  SunmiFontType.OTHER: 12,
};

Map<SunmiFontSize, int> fontSize = {
  SunmiFontSize.XXS: buildSize(0, 0), // 1x1
  SunmiFontSize.XS: buildSize(1, 1), // 2x2
  SunmiFontSize.SM: buildSize(1, 2), // 2x3
  SunmiFontSize.MD: buildSize(2, 2), // 3x3
  SunmiFontSize.LG: buildSize(2, 3), // 3x4
  SunmiFontSize.XL: buildSize(3, 3), // 4x4
  SunmiFontSize.XXL: buildSize(4, 4), // 5x5
  SunmiFontSize.XXXL: buildSize(5, 5), // 6x6
};

const Map<SunmiCharacterScale, (int width, int height)> fontScale = {
  SunmiCharacterScale.NORMAL: (1, 1),
  SunmiCharacterScale.WIDE: (2, 1),
  SunmiCharacterScale.TALL: (1, 2),
  SunmiCharacterScale.SM: (2, 2),
  SunmiCharacterScale.MD: (3, 2),
  SunmiCharacterScale.LG: (3, 3),
  SunmiCharacterScale.XL: (4, 4),
  SunmiCharacterScale.XXL: (5, 5),
  SunmiCharacterScale.XXXL: (6, 6),
};

const Map<SunmiFontSize, int> fontSizeToCols = {
  SunmiFontSize.XXS: 56,
  SunmiFontSize.XS: 48,
  SunmiFontSize.SM: 41,
  SunmiFontSize.MD: 36,
  SunmiFontSize.LG: 32,
  SunmiFontSize.XL: 28,
  SunmiFontSize.XXL: 26,
  SunmiFontSize.XXXL: 24,
};

const Map<SunmiPrinterPaper, int> printableDotWidth = {
  SunmiPrinterPaper.PAPER58: 360, // 58mm paper
  SunmiPrinterPaper.PAPER80: 550, // 80mm paper
};

// CJK valid range 16- 41
const Map<SunmiFontSize, int> cjkFontMap = {
  SunmiFontSize.XXS: 20,
  SunmiFontSize.XS: 22,
  SunmiFontSize.SM: 24,
  SunmiFontSize.MD: 28,
  SunmiFontSize.LG: 32,
  SunmiFontSize.XL: 34,
  SunmiFontSize.XXL: 36,
  SunmiFontSize.XXXL: 41,
};

// ascii valid range 8- 24
const Map<SunmiFontSize, int> asciiFontMap = {
  SunmiFontSize.XXS: 10,
  SunmiFontSize.XS: 12,
  SunmiFontSize.SM: 14,
  SunmiFontSize.MD: 16,
  SunmiFontSize.LG: 18,
  SunmiFontSize.XL: 20,
  SunmiFontSize.XXL: 22,
  SunmiFontSize.XXXL: 24,
};
// width, height are 0-based (0 = 1x, 1 = 2x, etc.)
int buildSize(int widthMultiplier, int heightMultiplier) => ((heightMultiplier & 0x0F) << 4) | (widthMultiplier & 0x0F);
int clampEscPosSize(int size) => size.clamp(1, 8);
