/**
 * EXIF解析器 - Native C++实现
 * 直接解析DNG/RAW文件的ExifIFD字段
 * 
 * 核心功能：
 * 1. 解析TIFF/DNG文件结构
 * 2. 递归遍历所有IFD节点
 * 3. 提取ExifIFD中的拍摄参数（ISO/光圈/快门/焦距等）
 */

#include "exif_parser.h"
#include <cstring>
#include <cmath>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <hilog/log.h>

// HiLog配置
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0021
#define LOG_TAG "EXIF"

// TIFF/EXIF 常量定义
#define TIFF_BYTE_ORDER_LE 0x4949  // "II" - Little Endian
#define TIFF_BYTE_ORDER_BE 0x4D4D  // "MM" - Big Endian
#define TIFF_MAGIC 42

// IFD Tag定义（EXIF 2.32标准）
#define TAG_IMAGE_WIDTH         0x0100
#define TAG_IMAGE_HEIGHT        0x0101
#define TAG_BITS_PER_SAMPLE     0x0102
#define TAG_COMPRESSION         0x0103
#define TAG_PHOTOMETRIC         0x0106
#define TAG_IMAGE_DESCRIPTION   0x010E
#define TAG_MAKE                0x010F
#define TAG_MODEL               0x0110
#define TAG_ORIENTATION         0x0112
#define TAG_X_RESOLUTION        0x011A
#define TAG_Y_RESOLUTION        0x011B
#define TAG_RESOLUTION_UNIT     0x0128
#define TAG_SOFTWARE            0x0131
#define TAG_DATE_TIME           0x0132
#define TAG_ARTIST              0x013B
#define TAG_COPYRIGHT           0x8298

// ExifIFD Pointer Tag
#define TAG_EXIF_IFD_POINTER    0x8769
#define TAG_GPS_IFD_POINTER     0x8825
#define TAG_SUB_IFDS            0x014A  // SubIFD偏移数组（DNG核心TAG）

// ExifIFD 内部Tag（核心拍摄参数）
#define TAG_EXPOSURE_TIME       0x829A
#define TAG_F_NUMBER            0x829D
#define TAG_EXPOSURE_PROGRAM    0x8822
#define TAG_ISO_SPEED           0x8827
#define TAG_DATE_TIME_ORIGINAL  0x9003
#define TAG_DATE_TIME_DIGITIZED 0x9004
#define TAG_SHUTTER_SPEED       0x9201
#define TAG_APERTURE            0x9202
#define TAG_BRIGHTNESS          0x9203
#define TAG_EXPOSURE_BIAS       0x9204
#define TAG_MAX_APERTURE        0x9205
#define TAG_SUBJECT_DISTANCE    0x9206
#define TAG_METERING_MODE       0x9207
#define TAG_LIGHT_SOURCE        0x9208
#define TAG_FLASH               0x9209
#define TAG_FOCAL_LENGTH        0x920A
#define TAG_USER_COMMENT        0x9286
#define TAG_SUBSEC_TIME         0x9290
#define TAG_SUBSEC_TIME_ORIG    0x9291
#define TAG_SUBSEC_TIME_DIG     0x9292
#define TAG_EXIF_VERSION        0x9000
#define TAG_FLASHPIX_VERSION    0xA000
#define TAG_COLOR_SPACE         0xA001
#define TAG_PIXEL_X_DIMENSION   0xA002
#define TAG_PIXEL_Y_DIMENSION   0xA003
#define TAG_RELATED_SOUND_FILE  0xA004
#define TAG_SENSING_METHOD      0xA217
#define TAG_EXPOSURE_MODE       0xA402
#define TAG_WHITE_BALANCE       0xA403
#define TAG_DIGITAL_ZOOM_RATIO  0xA404
#define TAG_FOCAL_LENGTH_35MM   0xA405
#define TAG_SCENE_CAPTURE_TYPE  0xA406
#define TAG_CONTRAST            0xA408
#define TAG_SATURATION          0xA409
#define TAG_SHARPNESS           0xA40A
#define TAG_LENS_MAKE           0xA433
#define TAG_LENS_MODEL          0xA434
#define TAG_LENS_SERIAL         0xA435

// 分辨率相关Tags
#define TAG_FOCAL_PLANE_X_RES   0xA20E
#define TAG_FOCAL_PLANE_Y_RES   0xA20F
#define TAG_FOCAL_PLANE_RES_UNIT 0xA210

// Interoperability IFD 指针（多IFD递归关键TAG）
#define TAG_INTEROPERABILITY_IFD_POINTER 0xA005

// 图像属性Tags
#define TAG_BITS_PER_SAMPLE     0x0102
#define TAG_SAMPLES_PER_PIXEL   0x0115
#define TAG_COMPONENTS_CONFIG   0x9101

// === 新增Tag定义（扩展至96字段）===
// 机身信息
#define TAG_BODY_SERIAL         0xA431  // 机身序列号

// 图像处理扩展
#define TAG_GAIN_CONTROL        0xA407  // 增益控制
#define TAG_SCENE_TYPE          0xA301  // 场景类型
#define TAG_SUBJECT_DIST_RANGE  0xA40C  // 主体距离范围
#define TAG_CUSTOM_RENDERED     0xA401  // 自定义渲染
#define TAG_EXPOSURE_INDEX      0xA215  // 曝光指数
#define TAG_CFA_PATTERN         0xA302  // 色彩滤镜阵列模式
#define TAG_DIGITAL_ZOOM_RATIO  0xA404  // 数字变焦比率（确保存在）

// 闪光灯扩展
#define TAG_FLASH_ENERGY        0xA20B  // 闪光灯能量

// 文件/设备扩展
#define TAG_FILE_SOURCE         0xA300  // 文件来源
#define TAG_DEVICE_SETTING_DESC 0xA40D  // 设备设置描述

// 主体信息
#define TAG_SUBJECT_LOCATION    0xA214  // 主体位置
#define TAG_SUBJECT_AREA        0x9214  // 主体区域

// 色彩科学扩展
#define TAG_WHITE_POINT         0x013E  // 白点
#define TAG_PRIMARY_CHROMAT     0x013F  // 原色度
#define TAG_YCBCR_COEFFICIENTS  0x0211  // YCbCr系数
#define TAG_REF_BLACK_WHITE     0x0214  // 参考黑白值
#define TAG_TRANSFER_FUNCTION   0x012D  // 传输函数

// 光谱扩展
#define TAG_SPECTRAL_SENS       0x8824  // 光谱灵敏度
#define TAG_OECF                0x8828  // 光电转换函数

// 制造商私有
#define TAG_MAKER_NOTE          0x927C  // 制造商注释

// 缩略图
#define TAG_THUMBNAIL_OFFSET    0x0201  // 缩略图偏移
#define TAG_THUMBNAIL_LENGTH    0x0202  // 缩略图长度
#define TAG_YCBCR_POSITIONING   0x0213

// GPS IFD Tags
#define TAG_GPS_LATITUDE_REF    0x0001
#define TAG_GPS_LATITUDE        0x0002
#define TAG_GPS_LONGITUDE_REF   0x0003
#define TAG_GPS_LONGITUDE       0x0004
#define TAG_GPS_ALTITUDE_REF    0x0005
#define TAG_GPS_ALTITUDE        0x0006
#define TAG_GPS_TIMESTAMP       0x0007
#define TAG_GPS_DATESTAMP       0x001D
#define TAG_GPS_IMG_DIRECTION   0x0011
#define TAG_GPS_SPEED           0x000D

// === DNG 1.4/1.6专有Tags（Phase 2扩展）===
// P0 - 摄影后期必需（12个字段）
#define TAG_DNG_VERSION              0xC612  // DNG版本
#define TAG_DNG_BACKWARD_VERSION     0xC613  // DNG向后兼容版本
#define TAG_UNIQUE_CAMERA_MODEL      0xC614  // 相机唯一标识
#define TAG_CAMERA_SERIAL_NUMBER     0xC62F  // 相机序列号（DNG专用）
#define TAG_DNG_LENS_INFO            0xC630  // DNG镜头信息
#define TAG_ORIGINAL_RAW_FILENAME    0xC68B  // 原始RAW文件名
#define TAG_BASELINE_EXPOSURE        0xC65A  // 基线曝光
#define TAG_BASELINE_NOISE           0xC65B  // 基线噪点
#define TAG_BASELINE_SHARPNESS       0xC65C  // 基线锐度
#define TAG_LINEAR_RESPONSE_LIMIT    0xC65E  // 线性响应限制
#define TAG_SHADOW_SCALE             0xC633  // 阴影比例
#define TAG_PREVIEW_COLOR_SPACE      0xC71A  // 预览色彩空间

// 数据类型定义
#define TYPE_BYTE       1
#define TYPE_ASCII      2
#define TYPE_SHORT      3
#define TYPE_LONG       4
#define TYPE_RATIONAL   5
#define TYPE_SBYTE      6
#define TYPE_UNDEFINED  7
#define TYPE_SSHORT     8
#define TYPE_SLONG      9
#define TYPE_SRATIONAL  10
#define TYPE_FLOAT      11
#define TYPE_DOUBLE     12

namespace exif {

// 内部辅助函数声明
static uint16_t readUint16(const uint8_t* data, bool littleEndian);
static uint32_t readUint32(const uint8_t* data, bool littleEndian);
static double readRational(const uint8_t* data, bool littleEndian);
static double readSRational(const uint8_t* data, bool littleEndian);
static std::string readString(const uint8_t* data, uint32_t count);
static size_t getTypeSize(uint16_t type);

ExifParser::ExifParser() : littleEndian_(true) {
}

ExifParser::~ExifParser() {
}

ExifData ExifParser::parse(const std::string& filePath) {
    ExifData result;
    result.success = false;
    
    // 读取文件
    std::ifstream file(filePath, std::ios::binary | std::ios::ate);
    if (!file.is_open()) {
        result.errorMessage = "无法打开文件: " + filePath;
        return result;
    }
    
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);
    
    std::vector<uint8_t> buffer(size);
    if (!file.read(reinterpret_cast<char*>(buffer.data()), size)) {
        result.errorMessage = "读取文件失败";
        return result;
    }
    file.close();
    
    return parseBuffer(buffer.data(), buffer.size());
}

ExifData ExifParser::parseBuffer(const uint8_t* data, size_t length) {
    ExifData result;
    result.success = false;
    
    if (length < 8) {
        result.errorMessage = "文件太小，不是有效的TIFF/DNG";
        return result;
    }
    
    // 检查字节序标记
    uint16_t byteOrder = (data[0] << 8) | data[1];
    if (byteOrder == TIFF_BYTE_ORDER_LE) {
        littleEndian_ = true;
    } else if (byteOrder == TIFF_BYTE_ORDER_BE) {
        littleEndian_ = false;
    } else {
        result.errorMessage = "无效的TIFF字节序标记";
        return result;
    }
    
    // 检查TIFF魔数
    uint16_t magic = readUint16(data + 2, littleEndian_);
    if (magic != TIFF_MAGIC) {
        result.errorMessage = "无效的TIFF魔数";
        return result;
    }
    
    // 获取第一个IFD偏移
    uint32_t ifd0Offset = readUint32(data + 4, littleEndian_);
    if (ifd0Offset >= length) {
        result.errorMessage = "IFD0偏移量超出文件范围";
        return result;
    }
    
    // 解析IFD0（主图像目录）
    parseIFD(data, length, ifd0Offset, result, IFD_TYPE_PRIMARY);
    
    result.success = true;
    return result;
}

void ExifParser::parseIFD(const uint8_t* data, size_t length, uint32_t offset, 
                          ExifData& result, IFDType ifdType) {
    if (offset + 2 > length) return;
    
    uint16_t numEntries = readUint16(data + offset, littleEndian_);
    
    // === 调试日志：IFD遍历状态 ===
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                 "[EXIF-IFD] 解析IFD类型:%d 偏移:0x%08X TAG数量:%d", 
                 ifdType, offset, numEntries);
    
    offset += 2;
    
    for (uint16_t i = 0; i < numEntries; i++) {
        if (offset + 12 > length) break;
        
        uint16_t tag = readUint16(data + offset, littleEndian_);
        uint16_t type = readUint16(data + offset + 2, littleEndian_);
        uint32_t count = readUint32(data + offset + 4, littleEndian_);
        uint32_t valueOffset = readUint32(data + offset + 8, littleEndian_);
        
        // 计算数据大小
        size_t typeSize = getTypeSize(type);
        size_t totalSize = typeSize * count;
        
        // 数据位置：<=4字节存在offset字段本身，否则offset是指针
        const uint8_t* valueData;
        if (totalSize <= 4) {
            valueData = data + offset + 8;
        } else {
            if (valueOffset >= length) {
                offset += 12;
                continue;
            }
            valueData = data + valueOffset;
        }
        
        // 处理特殊Tag：ExifIFD、GPS IFD、SubIFD 和 Interoperability IFD指针
        if (tag == TAG_EXIF_IFD_POINTER && ifdType == IFD_TYPE_PRIMARY) {
            uint32_t exifOffset = readUint32(valueData, littleEndian_);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                         "[EXIF-IFD] 发现ExifIFD指针 -> 偏移:0x%08X", exifOffset);
            parseIFD(data, length, exifOffset, result, IFD_TYPE_EXIF);
        } else if (tag == TAG_GPS_IFD_POINTER && ifdType == IFD_TYPE_PRIMARY) {
            uint32_t gpsOffset = readUint32(valueData, littleEndian_);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                         "[EXIF-IFD] 发现GPS IFD指针 -> 偏移:0x%08X", gpsOffset);
            parseIFD(data, length, gpsOffset, result, IFD_TYPE_GPS);
        } else if (tag == TAG_SUB_IFDS && ifdType == IFD_TYPE_PRIMARY) {
            // === SubIFD递归解析（核心修复：DNG大量字段存储在SubIFD中）===
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                         "[EXIF-IFD] 发现SubIFD指针 count:%d", count);
            // SubIFD偏移可能是数组（count表示SubIFD数量）
            for (uint32_t j = 0; j < count && j < 5; j++) {  // 最多处理5个SubIFD，防止异常数据
                uint32_t subIfdOffset = readUint32(valueData + j*4, littleEndian_);
                if (subIfdOffset > 0 && subIfdOffset < length) {
                    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                 "[EXIF-IFD] 递归SubIFD[%d] 偏移:0x%08X", j, subIfdOffset);
                    parseIFD(data, length, subIfdOffset, result, IFD_TYPE_SUB);
                }
            }
        } else if (tag == TAG_INTEROPERABILITY_IFD_POINTER && ifdType == IFD_TYPE_EXIF) {
            // === Interoperability IFD递归解析（多IFD递归关键修复）===
            uint32_t interopOffset = readUint32(valueData, littleEndian_);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                         "[EXIF-IFD] 发现Interoperability IFD指针 -> 偏移:0x%08X", interopOffset);
            if (interopOffset > 0 && interopOffset < length) {
                parseIFD(data, length, interopOffset, result, IFD_TYPE_INTEROP);
            }
        } else {
            // 解析具体字段
            parseTag(tag, type, count, valueData, result, ifdType);
        }
        
        offset += 12;
    }
    
    // === IFD1（缩略图IFD）递归解析 ===
    // 仅从IFD0跳转到IFD1，避免无限递归
    if (ifdType == IFD_TYPE_PRIMARY) {
        // Next IFD Offset 位于所有条目之后（offset已经指向条目末尾）
        if (offset + 4 <= length) {
            uint32_t nextIfdOffset = readUint32(data + offset, littleEndian_);
            if (nextIfdOffset > 0 && nextIfdOffset < length) {
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-IFD] 发现IFD1(缩略图) -> 偏移:0x%08X", nextIfdOffset);
                // 注意：IFD1使用IFD_TYPE_SUB类型，避免重复解析ExifIFD指针
                parseIFD(data, length, nextIfdOffset, result, IFD_TYPE_SUB);
            }
        }
    }
}

void ExifParser::parseTag(uint16_t tag, uint16_t type, uint32_t count,
                          const uint8_t* data, ExifData& result, IFDType ifdType) {
    // === 关键调试：记录所有TAG，特别关注DNG范围(0xC612-0xC71A) ===
    if (tag >= 0xC612 && tag <= 0xC71A) {
        // DNG专有TAG（重点监控）
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, LOG_TAG, 
                     "[EXIF-DNG-TAG] 🔴 TAG:0x%04X Type:%d Count:%d ifdType:%d", 
                     tag, type, count, ifdType);
    } else {
        // 普通TAG（info级别）
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                     "[EXIF-TAG] TAG:0x%04X Type:%d ifdType:%d", 
                     tag, type, ifdType);
    }
    
    // === 调试日志：TAG处理状态 ===
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, LOG_TAG, 
                 "[EXIF-TAG] TAG:0x%04X type:%d count:%d ifdType:%d", 
                 tag, type, count, ifdType);
    
    // === 主IFD + SubIFD字段（合并处理，SubIFD优先） ===
    if (ifdType == IFD_TYPE_PRIMARY || ifdType == IFD_TYPE_SUB) {
        bool isSubIFD = (ifdType == IFD_TYPE_SUB);
        switch (tag) {
            case TAG_MAKE:
                // 相机品牌保持IFD0值（设备基础信息）
                if (!isSubIFD) {
                    result.cameraMake = readString(data, count);
                }
                break;
            case TAG_MODEL:
                // 相机型号保持IFD0值（设备基础信息）
                if (!isSubIFD) {
                    result.cameraModel = readString(data, count);
                }
                break;
            case TAG_ORIENTATION:
                // SubIFD优先（主图像方向）
                if (isSubIFD || result.orientation == 0) {
                    result.orientation = readUint16(data, littleEndian_);
                }
                break;
            case TAG_SOFTWARE:
                if (isSubIFD || result.software.empty()) {
                    result.software = readString(data, count);
                }
                break;
            case TAG_DATE_TIME:
                if (isSubIFD || result.dateTime.empty()) {
                    result.dateTime = readString(data, count);
                }
                break;
            case TAG_IMAGE_WIDTH:
                // SubIFD优先（主图像尺寸）
                if (isSubIFD || result.imageWidth == 0) {
                    result.imageWidth = (type == TYPE_SHORT) ? 
                        readUint16(data, littleEndian_) : readUint32(data, littleEndian_);
                }
                break;
            case TAG_IMAGE_HEIGHT:
                // SubIFD优先（主图像尺寸）
                if (isSubIFD || result.imageHeight == 0) {
                    result.imageHeight = (type == TYPE_SHORT) ? 
                        readUint16(data, littleEndian_) : readUint32(data, littleEndian_);
                }
                break;
            case TAG_ARTIST:
                if (isSubIFD || result.artist.empty()) {
                    result.artist = readString(data, count);
                }
                break;
            case TAG_COPYRIGHT:
                if (isSubIFD || result.copyright.empty()) {
                    result.copyright = readString(data, count);
                }
                break;
            case TAG_IMAGE_DESCRIPTION:
                if (isSubIFD || result.imageDescription.empty()) {
                    result.imageDescription = readString(data, count);
                }
                break;
            case TAG_X_RESOLUTION:
                // SubIFD优先（主图像分辨率）
                if (isSubIFD || result.xResolution == 0) {
                    result.xResolution = readRational(data, littleEndian_);
                    if (isSubIFD) {
                        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                     "[EXIF-COVER] SubIFD覆盖: xResolution=%.1f", result.xResolution);
                    }
                }
                break;
            case TAG_Y_RESOLUTION:
                // SubIFD优先（主图像分辨率）
                if (isSubIFD || result.yResolution == 0) {
                    result.yResolution = readRational(data, littleEndian_);
                    if (isSubIFD) {
                        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                     "[EXIF-COVER] SubIFD覆盖: yResolution=%.1f", result.yResolution);
                    }
                }
                break;
            case TAG_RESOLUTION_UNIT:
                // SubIFD优先
                if (isSubIFD || result.resolutionUnit == 0) {
                    result.resolutionUnit = readUint16(data, littleEndian_);
                }
                break;
            case TAG_COMPRESSION:
                // SubIFD优先（RAW压缩算法）
                if (isSubIFD || result.compression == 0) {
                    result.compression = readUint16(data, littleEndian_);
                    if (isSubIFD) {
                        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                     "[EXIF-COVER] SubIFD覆盖: compression=%d", result.compression);
                    }
                }
                break;
            case TAG_PHOTOMETRIC:
                // SubIFD优先
                if (isSubIFD || result.photometricInterpretation == 0) {
                    result.photometricInterpretation = readUint16(data, littleEndian_);
                }
                break;
            case TAG_BITS_PER_SAMPLE:
                // SubIFD优先
                if (isSubIFD || result.bitsPerSample == 0) {
                    result.bitsPerSample = readUint16(data, littleEndian_);
                }
                break;
            case TAG_SAMPLES_PER_PIXEL:
                // SubIFD优先
                if (isSubIFD || result.samplesPerPixel == 0) {
                    result.samplesPerPixel = readUint16(data, littleEndian_);
                }
                break;
            case TAG_YCBCR_POSITIONING:
                if (isSubIFD || result.yCbCrPositioning == 0) {
                    result.yCbCrPositioning = readUint16(data, littleEndian_);
                }
                break;
            
            // === 新增主IFD + SubIFD字段解析 ===
            case TAG_WHITE_POINT:
                if (count >= 2 && (isSubIFD || result.whitePoint.empty())) {
                    double x = readRational(data, littleEndian_);
                    double y = readRational(data + 8, littleEndian_);
                    char buf[64];
                    snprintf(buf, sizeof(buf), "%.4f,%.4f", x, y);
                    result.whitePoint = std::string(buf);
                }
                break;
            case TAG_PRIMARY_CHROMAT:
                if (count >= 6 && (isSubIFD || result.primaryChromaticities.empty())) {
                    std::string chromat;
                    for (int i = 0; i < 6; i++) {
                        double val = readRational(data + i * 8, littleEndian_);
                        if (i > 0) chromat += ",";
                        char buf[16];
                        snprintf(buf, sizeof(buf), "%.4f", val);
                        chromat += buf;
                    }
                    result.primaryChromaticities = chromat;
                }
                break;
            case TAG_YCBCR_COEFFICIENTS:
                if (count >= 3 && (isSubIFD || result.yCbCrCoefficients.empty())) {
                    double y = readRational(data, littleEndian_);
                    double cb = readRational(data + 8, littleEndian_);
                    double cr = readRational(data + 16, littleEndian_);
                    char buf[64];
                    snprintf(buf, sizeof(buf), "%.4f,%.4f,%.4f", y, cb, cr);
                    result.yCbCrCoefficients = std::string(buf);
                }
                break;
            case TAG_REF_BLACK_WHITE:
                if (count >= 6 && (isSubIFD || result.referenceBlackWhite.empty())) {
                    std::string bw;
                    for (int i = 0; i < 6; i++) {
                        double val = readRational(data + i * 8, littleEndian_);
                        if (i > 0) bw += ",";
                        char buf[16];
                        snprintf(buf, sizeof(buf), "%.0f", val);
                        bw += buf;
                    }
                    result.referenceBlackWhite = bw;
                }
                break;
            case TAG_TRANSFER_FUNCTION:
                // 传输函数是768个值的数组，只标记存在
                if (count > 0 && (isSubIFD || result.transferFunction.empty())) {
                    result.transferFunction = "present(" + std::to_string(count) + " values)";
                }
                break;
            case TAG_THUMBNAIL_OFFSET:
                // 缩略图仅在IFD0处理（SubIFD是主图像）
                if (!isSubIFD) {
                    result.thumbnailOffset = readUint32(data, littleEndian_);
                }
                break;
            case TAG_THUMBNAIL_LENGTH:
                // 缩略图仅在IFD0处理（SubIFD是主图像）
                if (!isSubIFD) {
                    result.thumbnailLength = readUint32(data, littleEndian_);
                }
                break;
            
            // === DNG 1.4/1.6专有TAG（合并到PRIMARY/SUB IFD处理块）===
            case TAG_DNG_VERSION:
                // DNG版本：4字节数组表示 [1,4,0,0]
                if (count >= 4) {
                    char buf[16];
                    snprintf(buf, sizeof(buf), "%d.%d.%d.%d", 
                            data[0], data[1], data[2], data[3]);
                    result.dngVersion = std::string(buf);
                    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                 "[EXIF-DNG] ✅ DNGVersion=%s (ifdType=%d)", buf, ifdType);
                }
                break;
            case TAG_DNG_BACKWARD_VERSION:
                // DNG向后兼容版本
                if (count >= 4) {
                    char buf[16];
                    snprintf(buf, sizeof(buf), "%d.%d.%d.%d", 
                            data[0], data[1], data[2], data[3]);
                    result.dngBackwardVersion = std::string(buf);
                    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                 "[EXIF-DNG] ✅ DNGBackwardVersion=%s", buf);
                }
                break;
            case TAG_UNIQUE_CAMERA_MODEL:
                result.uniqueCameraModel = readString(data, count);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ UniqueCameraModel=%s", 
                             result.uniqueCameraModel.c_str());
                break;
            case TAG_CAMERA_SERIAL_NUMBER:
                // DNG专用相机序列号（区别于EXIF的BodySerialNumber）
                result.cameraSerialNumberDNG = readString(data, count);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ CameraSerialNumber=%s", 
                             result.cameraSerialNumberDNG.c_str());
                break;
            case TAG_DNG_LENS_INFO:
                // DNG镜头信息：4个有理数 [MinFocal, MaxFocal, MinF, MaxF]
                if (count >= 4) {
                    double minFocal = readRational(data, littleEndian_);
                    double maxFocal = readRational(data + 8, littleEndian_);
                    double minF = readRational(data + 16, littleEndian_);
                    double maxF = readRational(data + 24, littleEndian_);
                    char buf[64];
                    snprintf(buf, sizeof(buf), "%.0f-%.0fmm f/%.1f-%.1f", 
                            minFocal, maxFocal, minF, maxF);
                    result.dngLensInfo = std::string(buf);
                    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                 "[EXIF-DNG] ✅ DNGLensInfo=%s", buf);
                }
                break;
            case TAG_ORIGINAL_RAW_FILENAME:
                result.originalRawFilename = readString(data, count);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ OriginalRawFilename=%s", 
                             result.originalRawFilename.c_str());
                break;
            case TAG_BASELINE_EXPOSURE:
                result.baselineExposure = readSRational(data, littleEndian_);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ BaselineExposure=%.4f", result.baselineExposure);
                break;
            case TAG_BASELINE_NOISE:
                result.baselineNoise = readRational(data, littleEndian_);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ BaselineNoise=%.4f", result.baselineNoise);
                break;
            case TAG_BASELINE_SHARPNESS:
                result.baselineSharpness = readRational(data, littleEndian_);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ BaselineSharpness=%.4f", result.baselineSharpness);
                break;
            case TAG_LINEAR_RESPONSE_LIMIT:
                result.linearResponseLimit = readRational(data, littleEndian_);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ LinearResponseLimit=%.4f", result.linearResponseLimit);
                break;
            case TAG_SHADOW_SCALE:
                result.shadowScale = readRational(data, littleEndian_);
                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                             "[EXIF-DNG] ✅ ShadowScale=%.4f", result.shadowScale);
                break;
            case TAG_PREVIEW_COLOR_SPACE:
                // 预览色彩空间：枚举值（1=灰度，2=sRGB）
                {
                    uint32_t cs = (type == TYPE_SHORT) ? readUint16(data, littleEndian_) : readUint32(data, littleEndian_);
                    if (cs == 1) result.previewColorSpace = "Gray Gamma 2.2";
                    else if (cs == 2) result.previewColorSpace = "sRGB";
                    else result.previewColorSpace = std::to_string(cs);
                    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, LOG_TAG, 
                                 "[EXIF-DNG] ✅ PreviewColorSpace=%s", result.previewColorSpace.c_str());
                }
                break;
        }
    }
    
    // ExifIFD字段（核心拍摄参数）
    if (ifdType == IFD_TYPE_EXIF) {
        switch (tag) {
            case TAG_EXPOSURE_TIME:
                result.exposureTime = readRational(data, littleEndian_);
                result.hasExposureTime = true;
                break;
            case TAG_F_NUMBER:
                result.fNumber = readRational(data, littleEndian_);
                result.hasFNumber = true;
                break;
            case TAG_ISO_SPEED:
                result.iso = readUint16(data, littleEndian_);
                result.hasISO = true;
                break;
            case TAG_FOCAL_LENGTH:
                result.focalLength = readRational(data, littleEndian_);
                result.hasFocalLength = true;
                break;
            case TAG_FOCAL_LENGTH_35MM:
                result.focalLength35mm = readUint16(data, littleEndian_);
                break;
            case TAG_DATE_TIME_ORIGINAL:
                result.dateTimeOriginal = readString(data, count);
                break;
            case TAG_DATE_TIME_DIGITIZED:
                result.dateTimeDigitized = readString(data, count);
                break;
            case TAG_SUBSEC_TIME:
                result.subSecTime = readString(data, count);
                break;
            case TAG_SUBSEC_TIME_ORIG:
                result.subSecTimeOriginal = readString(data, count);
                break;
            case TAG_SUBSEC_TIME_DIG:
                result.subSecTimeDigitized = readString(data, count);
                break;
            case TAG_EXIF_VERSION:
                result.exifVersion = readString(data, count);
                break;
            case TAG_FLASHPIX_VERSION:
                result.flashpixVersion = readString(data, count);
                break;
            case TAG_EXPOSURE_PROGRAM:
                result.exposureProgram = readUint16(data, littleEndian_);
                break;
            case TAG_METERING_MODE:
                result.meteringMode = readUint16(data, littleEndian_);
                break;
            case TAG_FLASH:
                result.flash = readUint16(data, littleEndian_);
                break;
            case TAG_WHITE_BALANCE:
                result.whiteBalance = readUint16(data, littleEndian_);
                break;
            case TAG_EXPOSURE_MODE:
                result.exposureMode = readUint16(data, littleEndian_);
                break;
            case TAG_EXPOSURE_BIAS:
                result.exposureBias = readSRational(data, littleEndian_);
                break;
            case TAG_MAX_APERTURE:
                result.maxAperture = readRational(data, littleEndian_);
                break;
            case TAG_SUBJECT_DISTANCE:
                result.subjectDistance = readRational(data, littleEndian_);
                break;
            case TAG_BRIGHTNESS:
                result.brightness = readSRational(data, littleEndian_);
                break;
            case TAG_LIGHT_SOURCE:
                result.lightSource = readUint16(data, littleEndian_);
                break;
            case TAG_COLOR_SPACE:
                result.colorSpace = readUint16(data, littleEndian_);
                break;
            case TAG_PIXEL_X_DIMENSION:
                result.pixelXDimension = (type == TYPE_SHORT) ? 
                    readUint16(data, littleEndian_) : readUint32(data, littleEndian_);
                break;
            case TAG_PIXEL_Y_DIMENSION:
                result.pixelYDimension = (type == TYPE_SHORT) ? 
                    readUint16(data, littleEndian_) : readUint32(data, littleEndian_);
                break;
            case TAG_CONTRAST:
                result.contrast = readUint16(data, littleEndian_);
                break;
            case TAG_SATURATION:
                result.saturation = readUint16(data, littleEndian_);
                break;
            case TAG_SHARPNESS:
                result.sharpness = readUint16(data, littleEndian_);
                break;
            case TAG_LENS_MAKE:
                result.lensMake = readString(data, count);
                break;
            case TAG_LENS_MODEL:
                result.lensModel = readString(data, count);
                break;
            case TAG_LENS_SERIAL:
                result.lensSerialNumber = readString(data, count);
                break;
            case TAG_USER_COMMENT:
                result.userComment = readString(data, count);
                break;
            case TAG_RELATED_SOUND_FILE:
                result.relatedSoundFile = readString(data, count);
                break;
            case TAG_COMPONENTS_CONFIG:
                if (count >= 4) {
                    char buf[16];
                    snprintf(buf, sizeof(buf), "%d%d%d%d", data[0], data[1], data[2], data[3]);
                    result.componentsConfiguration = std::string(buf);
                }
                break;
            case TAG_SENSING_METHOD:
                result.sensingMethod = readUint16(data, littleEndian_);
                break;
            case TAG_FOCAL_PLANE_X_RES:
                result.focalPlaneXResolution = readRational(data, littleEndian_);
                break;
            case TAG_FOCAL_PLANE_Y_RES:
                result.focalPlaneYResolution = readRational(data, littleEndian_);
                break;
            case TAG_FOCAL_PLANE_RES_UNIT:
                result.focalPlaneResolutionUnit = readUint16(data, littleEndian_);
                break;
            case TAG_SCENE_CAPTURE_TYPE:
                result.sceneCaptureType = readUint16(data, littleEndian_);
                break;
            
            // === 新增ExifIFD字段解析 ===
            case TAG_BODY_SERIAL:
                result.bodySerialNumber = readString(data, count);
                break;
            case TAG_GAIN_CONTROL:
                result.gainControl = readUint16(data, littleEndian_);
                break;
            case TAG_DIGITAL_ZOOM_RATIO:
                result.digitalZoomRatio = readRational(data, littleEndian_);
                break;
            case TAG_SCENE_TYPE:
                result.sceneType = data[0];
                break;
            case TAG_SUBJECT_DIST_RANGE:
                result.subjectDistanceRange = readUint16(data, littleEndian_);
                break;
            case TAG_CUSTOM_RENDERED:
                result.customRendered = readUint16(data, littleEndian_);
                break;
            case TAG_EXPOSURE_INDEX:
                result.exposureIndex = readRational(data, littleEndian_);
                break;
            case TAG_CFA_PATTERN:
                // CFA模式: 简化处理，只记录前2个字节
                if (count >= 2) {
                    char buf[32];
                    snprintf(buf, sizeof(buf), "%d,%d", data[0], data[1]);
                    result.cFAPattern = std::string(buf);
                }
                break;
            case TAG_FLASH_ENERGY:
                result.flashEnergy = readRational(data, littleEndian_);
                break;
            case TAG_FILE_SOURCE:
                result.fileSource = data[0];
                break;
            case TAG_SUBJECT_LOCATION:
                if (count >= 2) {
                    uint16_t x = readUint16(data, littleEndian_);
                    uint16_t y = readUint16(data + 2, littleEndian_);
                    char buf[32];
                    snprintf(buf, sizeof(buf), "%d,%d", x, y);
                    result.subjectLocation = std::string(buf);
                }
                break;
            case TAG_SUBJECT_AREA:
                if (count >= 2) {
                    std::string area;
                    for (uint32_t i = 0; i < count && i < 4; i++) {
                        uint16_t val = readUint16(data + i * 2, littleEndian_);
                        if (i > 0) area += ",";
                        area += std::to_string(val);
                    }
                    result.subjectArea = area;
                }
                break;
            case TAG_SPECTRAL_SENS:
                result.spectralSensitivity = readString(data, count);
                break;
            case TAG_OECF:
                // OECF是复杂结构，只存储简单标记
                result.oecf = "present";
                break;
            case TAG_MAKER_NOTE:
                // 制造商注释：截取前100字节转hex
                if (count > 0) {
                    size_t len = std::min(count, (uint32_t)50);
                    std::string hex;
                    for (size_t i = 0; i < len; i++) {
                        char buf[4];
                        snprintf(buf, sizeof(buf), "%02X", data[i]);
                        hex += buf;
                    }
                    result.makerNote = hex + (count > 50 ? "..." : "");
                }
                break;
        }
    }
    
    // GPS IFD字段
    if (ifdType == IFD_TYPE_GPS) {
        switch (tag) {
            case TAG_GPS_LATITUDE_REF:
                result.gpsLatitudeRef = readString(data, count);
                break;
            case TAG_GPS_LATITUDE:
                if (count >= 3) {
                    double deg = readRational(data, littleEndian_);
                    double min = readRational(data + 8, littleEndian_);
                    double sec = readRational(data + 16, littleEndian_);
                    result.gpsLatitude = deg + min / 60.0 + sec / 3600.0;
                    result.hasGPS = true;
                }
                break;
            case TAG_GPS_LONGITUDE_REF:
                result.gpsLongitudeRef = readString(data, count);
                break;
            case TAG_GPS_LONGITUDE:
                if (count >= 3) {
                    double deg = readRational(data, littleEndian_);
                    double min = readRational(data + 8, littleEndian_);
                    double sec = readRational(data + 16, littleEndian_);
                    result.gpsLongitude = deg + min / 60.0 + sec / 3600.0;
                }
                break;
            case TAG_GPS_ALTITUDE_REF:
                result.gpsAltitudeRef = data[0];
                break;
            case TAG_GPS_ALTITUDE:
                result.gpsAltitude = readRational(data, littleEndian_);
                break;
            case TAG_GPS_TIMESTAMP:
                if (count >= 3) {
                    double h = readRational(data, littleEndian_);
                    double m = readRational(data + 8, littleEndian_);
                    double s = readRational(data + 16, littleEndian_);
                    char buf[32];
                    snprintf(buf, sizeof(buf), "%02d:%02d:%02d", 
                            (int)h, (int)m, (int)s);
                    result.gpsTimeStamp = std::string(buf);
                }
                break;
            case TAG_GPS_DATESTAMP:
                result.gpsDateStamp = readString(data, count);
                break;
            case TAG_GPS_SPEED:
                result.gpsSpeed = readRational(data, littleEndian_);
                break;
            case TAG_GPS_IMG_DIRECTION:
                result.gpsImgDirection = readRational(data, littleEndian_);
                break;
        }
    }
}

// === 辅助函数实现 ===

static uint16_t readUint16(const uint8_t* data, bool littleEndian) {
    if (littleEndian) {
        return data[0] | (data[1] << 8);
    }
    return (data[0] << 8) | data[1];
}

static uint32_t readUint32(const uint8_t* data, bool littleEndian) {
    if (littleEndian) {
        return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
    }
    return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
}

static double readRational(const uint8_t* data, bool littleEndian) {
    uint32_t numerator = readUint32(data, littleEndian);
    uint32_t denominator = readUint32(data + 4, littleEndian);
    if (denominator == 0) return 0.0;
    return static_cast<double>(numerator) / static_cast<double>(denominator);
}

static double readSRational(const uint8_t* data, bool littleEndian) {
    int32_t numerator = static_cast<int32_t>(readUint32(data, littleEndian));
    int32_t denominator = static_cast<int32_t>(readUint32(data + 4, littleEndian));
    if (denominator == 0) return 0.0;
    return static_cast<double>(numerator) / static_cast<double>(denominator);
}

static std::string readString(const uint8_t* data, uint32_t count) {
    if (count == 0) return "";
    // 去除末尾的null字符
    size_t len = count;
    while (len > 0 && data[len - 1] == 0) len--;
    return std::string(reinterpret_cast<const char*>(data), len);
}

static size_t getTypeSize(uint16_t type) {
    switch (type) {
        case TYPE_BYTE:
        case TYPE_SBYTE:
        case TYPE_ASCII:
        case TYPE_UNDEFINED:
            return 1;
        case TYPE_SHORT:
        case TYPE_SSHORT:
            return 2;
        case TYPE_LONG:
        case TYPE_SLONG:
        case TYPE_FLOAT:
            return 4;
        case TYPE_RATIONAL:
        case TYPE_SRATIONAL:
        case TYPE_DOUBLE:
            return 8;
        default:
            return 1;
    }
}

} // namespace exif
