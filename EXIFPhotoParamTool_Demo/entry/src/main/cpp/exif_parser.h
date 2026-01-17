/**
 * EXIF解析器头文件
 * 定义ExifData结构体和ExifParser类
 */

#ifndef EXIF_PARSER_H
#define EXIF_PARSER_H

#include <string>
#include <vector>
#include <cstdint>

namespace exif {

/**
 * EXIF数据结构体
 * 包含所有可解析的EXIF字段
 */
struct ExifData {
    // 解析状态
    bool success = false;
    std::string errorMessage;
    
    // === 主IFD字段（TIFF基础元数据）===
    std::string cameraMake;      // 相机厂商
    std::string cameraModel;     // 相机型号
    std::string software;        // 软件版本
    std::string dateTime;        // 修改时间
    std::string artist;          // 作者
    std::string copyright;       // 版权
    uint32_t imageWidth = 0;     // 图像宽度
    uint32_t imageHeight = 0;    // 图像高度
    uint16_t orientation = 1;    // 方向
    
    // === ExifIFD字段（核心拍摄参数）===
    double exposureTime = 0.0;   // 曝光时间（秒）
    bool hasExposureTime = false;
    
    double fNumber = 0.0;        // 光圈F值
    bool hasFNumber = false;
    
    uint16_t iso = 0;            // ISO感光度
    bool hasISO = false;
    
    double focalLength = 0.0;    // 焦距（mm）
    bool hasFocalLength = false;
    
    uint16_t focalLength35mm = 0;   // 35mm等效焦距
    std::string dateTimeOriginal;   // 原始拍摄时间
    uint16_t exposureProgram = 0;   // 曝光程序
    uint16_t meteringMode = 0;      // 测光模式
    uint16_t flash = 0;             // 闪光灯状态
    uint16_t whiteBalance = 0;      // 白平衡
    uint16_t exposureMode = 0;      // 曝光模式
    double exposureBias = 0.0;      // 曝光补偿
    double maxAperture = 0.0;       // 最大光圈
    uint16_t colorSpace = 0;        // 色彩空间
    uint32_t pixelXDimension = 0;   // 像素宽度
    uint32_t pixelYDimension = 0;   // 像素高度
    uint16_t contrast = 0;          // 对比度
    uint16_t saturation = 0;        // 饱和度
    uint16_t sharpness = 0;         // 锐度
    uint16_t sceneCaptureType = 0;  // 场景捕获类型
    
    // === 时间扩展 ===
    std::string dateTimeDigitized;  // 数字化时间
    std::string subSecTime;         // DateTime亚秒精度
    std::string subSecTimeOriginal; // DateTimeOriginal亚秒精度
    std::string subSecTimeDigitized;// DateTimeDigitized亚秒精度
    
    // === 镜头信息 ===
    std::string lensMake;        // 镜头厂商
    std::string lensModel;       // 镜头型号
    std::string lensSerialNumber; // 镜头序列号
    double subjectDistance = 0.0; // 对焦距离（米）
    
    // === 分辨率参数 ===
    double xResolution = 0.0;       // X分辨率
    double yResolution = 0.0;       // Y分辨率
    uint16_t resolutionUnit = 2;    // 分辨率单位（2=英寸，3=厘米）
    double focalPlaneXResolution = 0.0;
    double focalPlaneYResolution = 0.0;
    uint16_t focalPlaneResolutionUnit = 2;
    
    // === GPS信息 ===
    bool hasGPS = false;
    std::string gpsLatitudeRef;  // 纬度参考（N/S）
    double gpsLatitude = 0.0;    // 纬度（十进制度）
    std::string gpsLongitudeRef; // 经度参考（E/W）
    double gpsLongitude = 0.0;   // 经度（十进制度）
    uint8_t gpsAltitudeRef = 0;  // 海拔参考（0=海平面以上）
    double gpsAltitude = 0.0;    // 海拔（米）
    std::string gpsTimeStamp;    // GPS时间戳
    std::string gpsDateStamp;    // GPS日期戳
    double gpsSpeed = 0.0;       // GPS速度（km/h）
    double gpsImgDirection = 0.0; // GPS图像方向（度）
    
    // === 图像属性扩展 ===
    uint16_t compression = 0;       // 压缩方式
    uint16_t photometricInterpretation = 0; // 光度解释
    std::string imageDescription;   // 图像描述
    std::string userComment;        // 用户评论
    uint16_t bitsPerSample = 0;     // 每样本位数
    uint16_t samplesPerPixel = 0;   // 每像素样本数
    std::string componentsConfiguration; // 分量配置
    uint16_t yCbCrPositioning = 0;  // YCbCr定位
    
    // === 其他元数据 ===
    std::string exifVersion;        // EXIF版本
    std::string flashpixVersion;    // FlashPix版本
    uint16_t lightSource = 0;       // 光源类型
    double brightness = 0.0;        // 亮度值（EV）
    uint16_t sensingMethod = 0;     // 感光方式
    std::string relatedSoundFile;   // 相关音频文件
    
    // === 新增字段（扩展至96字段）===
    // 机身序列号
    std::string bodySerialNumber;
    
    // 图像处理扩展
    uint16_t gainControl = 0;           // 增益控制 (0=无, 1=低增益, 2=高增益)
    double digitalZoomRatio = 0.0;      // 数字变焦比
    uint16_t sceneType = 0;             // 场景类型 (1=直接拍摄)
    uint16_t subjectDistanceRange = 0;  // 主体距离范围 (0=未知, 1=微距, 2=近景, 3=远景)
    uint16_t customRendered = 0;        // 自定义渲染 (0=正常, 1=自定义)
    double exposureIndex = 0.0;         // 曝光指数
    std::string cFAPattern;             // CFA模式 (色彩滤镜阵列)
    
    // 闪光灯扩展
    double flashEnergy = 0.0;           // 闪光灯能量 (BCPS)
    
    // 文件/设备扩展
    uint16_t fileSource = 0;            // 文件来源 (3=DSC)
    std::string deviceSettingDesc;      // 设备设置描述
    
    // 主体信息
    std::string subjectLocation;        // 主体位置 (x, y坐标)
    std::string subjectArea;            // 主体区域
    
    // 色彩科学扩展
    std::string whitePoint;             // 白点 (CIE x,y)
    std::string primaryChromaticities;  // 原色度
    std::string yCbCrCoefficients;      // YCbCr系数
    std::string referenceBlackWhite;    // 参考黑白值
    std::string transferFunction;       // 传输函数
    
    // 光谱扩展
    std::string spectralSensitivity;    // 光谱灵敏度
    std::string oecf;                   // 光电转换函数
    
    // 制造商私有
    std::string makerNote;              // 制造商注释（二进制，截取前100字节）
    
    // 缩略图
    uint32_t thumbnailWidth = 0;        // 缩略图宽度
    uint32_t thumbnailHeight = 0;       // 缩略图高度
    uint32_t thumbnailOffset = 0;       // 缩略图偏移
    uint32_t thumbnailLength = 0;       // 缩略图长度
    
    // === Phase 2扩展：DNG 1.4/1.6专有字段（P0 - 12个）===
    std::string dngVersion;             // DNG版本 (e.g., "1.4.0.0")
    std::string dngBackwardVersion;     // DNG向后兼容版本 (e.g., "1.1.0.0")
    std::string uniqueCameraModel;      // 相机唯一标识 (e.g., "Nikon D800E")
    std::string cameraSerialNumberDNG;  // 相机序列号-DNG专用 (区别于EXIF的bodySerialNumber)
    std::string dngLensInfo;            // DNG镜头信息 (e.g., "35-35mm f/1.4-1.4")
    std::string originalRawFilename;    // 原始RAW文件名 (e.g., "DSC_3070.NEF")
    double baselineExposure = 0.0;      // 基线曝光 (e.g., 0.35)
    double baselineNoise = 0.0;         // 基线噪点 (e.g., 0.6)
    double baselineSharpness = 0.0;     // 基线锐度 (e.g., 1.0)
    double linearResponseLimit = 0.0;   // 线性响应限制
    double shadowScale = 0.0;           // 阴影比例 (e.g., 1.0)
    std::string previewColorSpace;      // 预览色彩空间 ("Gray Gamma 2.2" / "sRGB")
};

/**
 * IFD类型枚举
 */
enum IFDType {
    IFD_TYPE_PRIMARY = 0,  // 主IFD (IFD0)
    IFD_TYPE_EXIF = 1,     // ExifIFD
    IFD_TYPE_GPS = 2,      // GPS IFD
    IFD_TYPE_INTEROP = 3,  // Interoperability IFD
    IFD_TYPE_SUB = 4       // SubIFD (DNG专用)
};

/**
 * EXIF解析器类
 */
class ExifParser {
public:
    ExifParser();
    ~ExifParser();
    
    /**
     * 解析文件
     * @param filePath 文件路径
     * @return ExifData 解析结果
     */
    ExifData parse(const std::string& filePath);
    
    /**
     * 解析内存buffer
     * @param data 数据指针
     * @param length 数据长度
     * @return ExifData 解析结果
     */
    ExifData parseBuffer(const uint8_t* data, size_t length);

private:
    bool littleEndian_;
    
    /**
     * 解析IFD目录
     */
    void parseIFD(const uint8_t* data, size_t length, uint32_t offset, 
                  ExifData& result, IFDType ifdType);
    
    /**
     * 解析单个Tag
     */
    void parseTag(uint16_t tag, uint16_t type, uint32_t count,
                  const uint8_t* data, ExifData& result, IFDType ifdType);
};

} // namespace exif

#endif // EXIF_PARSER_H
