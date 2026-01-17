/**
 * Node-API 桥接层
 * 将C++ EXIF解析器暴露给ArkTS层
 */

#include <napi/native_api.h>
#include <hilog/log.h>
#include <cstring>
#include "exif_parser.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0021
#define LOG_TAG "ExifNative"

// 辅助函数：设置字符串属性
static void SetStringProperty(napi_env env, napi_value obj, const char* name, const std::string& value) {
    napi_value napiValue;
    napi_create_string_utf8(env, value.c_str(), value.length(), &napiValue);
    napi_set_named_property(env, obj, name, napiValue);
}

// 辅助函数：设置数字属性（整数）
static void SetIntProperty(napi_env env, napi_value obj, const char* name, int32_t value) {
    napi_value napiValue;
    napi_create_int32(env, value, &napiValue);
    napi_set_named_property(env, obj, name, napiValue);
}

// 辅助函数：设置数字属性（双精度）
static void SetDoubleProperty(napi_env env, napi_value obj, const char* name, double value) {
    napi_value napiValue;
    napi_create_double(env, value, &napiValue);
    napi_set_named_property(env, obj, name, napiValue);
}

// 辅助函数：设置布尔属性
static void SetBoolProperty(napi_env env, napi_value obj, const char* name, bool value) {
    napi_value napiValue;
    napi_get_boolean(env, value, &napiValue);
    napi_set_named_property(env, obj, name, napiValue);
}

/**
 * 格式化光圈值
 * 输入: 2.8 -> 输出: "f/2.8"
 */
static std::string FormatAperture(double fNumber) {
    if (fNumber <= 0) return "";
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "f/%.1f", fNumber);
    return std::string(buffer);
}

/**
 * 格式化快门速度
 * 输入: 0.008 -> 输出: "1/125s"
 * 输入: 2.0 -> 输出: "2s"
 */
static std::string FormatShutterSpeed(double exposureTime) {
    if (exposureTime <= 0) return "";
    char buffer[32];
    if (exposureTime >= 1.0) {
        snprintf(buffer, sizeof(buffer), "%.1fs", exposureTime);
    } else {
        int reciprocal = static_cast<int>(1.0 / exposureTime + 0.5);
        snprintf(buffer, sizeof(buffer), "1/%ds", reciprocal);
    }
    return std::string(buffer);
}

/**
 * 格式化焦距
 * 输入: 50.0 -> 输出: "50mm"
 */
static std::string FormatFocalLength(double focalLength) {
    if (focalLength <= 0) return "";
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%.0fmm", focalLength);
    return std::string(buffer);
}

/**
 * 将ExifData转换为napi_value对象
 */
static napi_value ExifDataToNapi(napi_env env, const exif::ExifData& data) {
    napi_value result;
    napi_create_object(env, &result);
    
    // 解析状态
    SetBoolProperty(env, result, "success", data.success);
    SetStringProperty(env, result, "errorMessage", data.errorMessage);
    
    // === 主IFD字段 ===
    SetStringProperty(env, result, "cameraMake", data.cameraMake);
    SetStringProperty(env, result, "cameraModel", data.cameraModel);
    SetStringProperty(env, result, "software", data.software);
    SetStringProperty(env, result, "dateTime", data.dateTime);
    SetStringProperty(env, result, "artist", data.artist);
    SetStringProperty(env, result, "copyright", data.copyright);
    SetIntProperty(env, result, "imageWidth", data.imageWidth);
    SetIntProperty(env, result, "imageHeight", data.imageHeight);
    SetIntProperty(env, result, "orientation", data.orientation);
    
    // === ExifIFD字段（核心拍摄参数）===
    // 原始数值
    SetDoubleProperty(env, result, "exposureTimeRaw", data.exposureTime);
    SetDoubleProperty(env, result, "fNumberRaw", data.fNumber);
    SetIntProperty(env, result, "iso", data.iso);
    SetDoubleProperty(env, result, "focalLengthRaw", data.focalLength);
    
    // 格式化字符串（供UI直接显示）
    SetStringProperty(env, result, "aperture", FormatAperture(data.fNumber));
    SetStringProperty(env, result, "shutterSpeed", FormatShutterSpeed(data.exposureTime));
    SetStringProperty(env, result, "focalLength", FormatFocalLength(data.focalLength));
    
    // 有效性标记
    SetBoolProperty(env, result, "hasExposureTime", data.hasExposureTime);
    SetBoolProperty(env, result, "hasFNumber", data.hasFNumber);
    SetBoolProperty(env, result, "hasISO", data.hasISO);
    SetBoolProperty(env, result, "hasFocalLength", data.hasFocalLength);
    
    // 其他ExifIFD字段
    SetIntProperty(env, result, "focalLength35mm", data.focalLength35mm);
    SetStringProperty(env, result, "dateTimeOriginal", data.dateTimeOriginal);
    SetIntProperty(env, result, "exposureProgram", data.exposureProgram);
    SetIntProperty(env, result, "meteringMode", data.meteringMode);
    SetIntProperty(env, result, "flash", data.flash);
    SetIntProperty(env, result, "whiteBalance", data.whiteBalance);
    SetIntProperty(env, result, "exposureMode", data.exposureMode);
    SetDoubleProperty(env, result, "exposureBias", data.exposureBias);
    SetDoubleProperty(env, result, "maxAperture", data.maxAperture);
    SetIntProperty(env, result, "colorSpace", data.colorSpace);
    SetIntProperty(env, result, "pixelXDimension", data.pixelXDimension);
    SetIntProperty(env, result, "pixelYDimension", data.pixelYDimension);
    SetIntProperty(env, result, "contrast", data.contrast);
    SetIntProperty(env, result, "saturation", data.saturation);
    SetIntProperty(env, result, "sharpness", data.sharpness);
    SetIntProperty(env, result, "sceneCaptureType", data.sceneCaptureType);
    
    // === 镜头信息 ===
    SetStringProperty(env, result, "lensMake", data.lensMake);
    SetStringProperty(env, result, "lensModel", data.lensModel);
    SetStringProperty(env, result, "lensSerialNumber", data.lensSerialNumber);
    SetDoubleProperty(env, result, "subjectDistance", data.subjectDistance);
    
    // === 时间扩展 ===
    SetStringProperty(env, result, "dateTimeDigitized", data.dateTimeDigitized);
    SetStringProperty(env, result, "subSecTime", data.subSecTime);
    SetStringProperty(env, result, "subSecTimeOriginal", data.subSecTimeOriginal);
    SetStringProperty(env, result, "subSecTimeDigitized", data.subSecTimeDigitized);
    
    // === 分辨率参数 ===
    SetDoubleProperty(env, result, "xResolution", data.xResolution);
    SetDoubleProperty(env, result, "yResolution", data.yResolution);
    SetIntProperty(env, result, "resolutionUnit", data.resolutionUnit);
    SetDoubleProperty(env, result, "focalPlaneXResolution", data.focalPlaneXResolution);
    SetDoubleProperty(env, result, "focalPlaneYResolution", data.focalPlaneYResolution);
    SetIntProperty(env, result, "focalPlaneResolutionUnit", data.focalPlaneResolutionUnit);
    
    // === 图像属性扩展 ===
    SetIntProperty(env, result, "compression", data.compression);
    SetIntProperty(env, result, "photometricInterpretation", data.photometricInterpretation);
    SetStringProperty(env, result, "imageDescription", data.imageDescription);
    SetStringProperty(env, result, "userComment", data.userComment);
    SetIntProperty(env, result, "bitsPerSample", data.bitsPerSample);
    SetIntProperty(env, result, "samplesPerPixel", data.samplesPerPixel);
    SetStringProperty(env, result, "componentsConfiguration", data.componentsConfiguration);
    SetIntProperty(env, result, "yCbCrPositioning", data.yCbCrPositioning);
    
    // === 其他元数据 ===
    SetStringProperty(env, result, "exifVersion", data.exifVersion);
    SetStringProperty(env, result, "flashpixVersion", data.flashpixVersion);
    SetIntProperty(env, result, "lightSource", data.lightSource);
    SetDoubleProperty(env, result, "brightness", data.brightness);
    SetIntProperty(env, result, "sensingMethod", data.sensingMethod);
    SetStringProperty(env, result, "relatedSoundFile", data.relatedSoundFile);
    
    // === GPS信息 ===
    SetBoolProperty(env, result, "hasGPS", data.hasGPS);
    SetStringProperty(env, result, "gpsLatitudeRef", data.gpsLatitudeRef);
    SetDoubleProperty(env, result, "gpsLatitude", data.gpsLatitude);
    SetStringProperty(env, result, "gpsLongitudeRef", data.gpsLongitudeRef);
    SetDoubleProperty(env, result, "gpsLongitude", data.gpsLongitude);
    SetIntProperty(env, result, "gpsAltitudeRef", data.gpsAltitudeRef);
    SetDoubleProperty(env, result, "gpsAltitude", data.gpsAltitude);
    SetStringProperty(env, result, "gpsTimeStamp", data.gpsTimeStamp);
    SetStringProperty(env, result, "gpsDateStamp", data.gpsDateStamp);
    SetDoubleProperty(env, result, "gpsSpeed", data.gpsSpeed);
    SetDoubleProperty(env, result, "gpsImgDirection", data.gpsImgDirection);
    
    // === 新增字段（扩展至96字段）===
    // 机身序列号
    SetStringProperty(env, result, "bodySerialNumber", data.bodySerialNumber);
    
    // 图像处理扩展
    SetIntProperty(env, result, "gainControl", data.gainControl);
    SetDoubleProperty(env, result, "digitalZoomRatio", data.digitalZoomRatio);
    SetIntProperty(env, result, "sceneType", data.sceneType);
    SetIntProperty(env, result, "subjectDistanceRange", data.subjectDistanceRange);
    SetIntProperty(env, result, "customRendered", data.customRendered);
    SetDoubleProperty(env, result, "exposureIndex", data.exposureIndex);
    SetStringProperty(env, result, "cFAPattern", data.cFAPattern);
    
    // 闪光灯扩展
    SetDoubleProperty(env, result, "flashEnergy", data.flashEnergy);
    
    // 文件/设备扩展
    SetIntProperty(env, result, "fileSource", data.fileSource);
    SetStringProperty(env, result, "deviceSettingDesc", data.deviceSettingDesc);
    
    // 主体信息
    SetStringProperty(env, result, "subjectLocation", data.subjectLocation);
    SetStringProperty(env, result, "subjectArea", data.subjectArea);
    
    // 色彩科学扩展
    SetStringProperty(env, result, "whitePoint", data.whitePoint);
    SetStringProperty(env, result, "primaryChromaticities", data.primaryChromaticities);
    SetStringProperty(env, result, "yCbCrCoefficients", data.yCbCrCoefficients);
    SetStringProperty(env, result, "referenceBlackWhite", data.referenceBlackWhite);
    SetStringProperty(env, result, "transferFunction", data.transferFunction);
    
    // 光谱扩展
    SetStringProperty(env, result, "spectralSensitivity", data.spectralSensitivity);
    SetStringProperty(env, result, "oecf", data.oecf);
    
    // 制造商私有
    SetStringProperty(env, result, "makerNote", data.makerNote);
    
    // 缩略图
    SetIntProperty(env, result, "thumbnailWidth", data.thumbnailWidth);
    SetIntProperty(env, result, "thumbnailHeight", data.thumbnailHeight);
    SetIntProperty(env, result, "thumbnailOffset", data.thumbnailOffset);
    SetIntProperty(env, result, "thumbnailLength", data.thumbnailLength);
    
    // === Phase 2扩展：DNG 1.4/1.6专有字段（P0 - 12个）===
    SetStringProperty(env, result, "dngVersion", data.dngVersion);
    SetStringProperty(env, result, "dngBackwardVersion", data.dngBackwardVersion);
    SetStringProperty(env, result, "uniqueCameraModel", data.uniqueCameraModel);
    SetStringProperty(env, result, "cameraSerialNumberDNG", data.cameraSerialNumberDNG);
    SetStringProperty(env, result, "dngLensInfo", data.dngLensInfo);
    SetStringProperty(env, result, "originalRawFilename", data.originalRawFilename);
    SetDoubleProperty(env, result, "baselineExposure", data.baselineExposure);
    SetDoubleProperty(env, result, "baselineNoise", data.baselineNoise);
    SetDoubleProperty(env, result, "baselineSharpness", data.baselineSharpness);
    SetDoubleProperty(env, result, "linearResponseLimit", data.linearResponseLimit);
    SetDoubleProperty(env, result, "shadowScale", data.shadowScale);
    SetStringProperty(env, result, "previewColorSpace", data.previewColorSpace);
    
    return result;
}

/**
 * Native函数：解析文件路径
 * 签名: parseExifFromPath(filePath: string): ExifData
 */
static napi_value ParseExifFromPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    if (argc < 1) {
        napi_throw_error(env, nullptr, "Missing file path argument");
        return nullptr;
    }
    
    // 获取文件路径
    size_t pathLen;
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &pathLen);
    std::string filePath(pathLen, '\0');
    napi_get_value_string_utf8(env, args[0], &filePath[0], pathLen + 1, nullptr);
    
    OH_LOG_INFO(LOG_APP, "[EXIF-Native] 开始解析文件: %{public}s", filePath.c_str());
    
    // 解析EXIF
    exif::ExifParser parser;
    exif::ExifData result = parser.parse(filePath);
    
    if (result.success) {
        OH_LOG_INFO(LOG_APP, "[EXIF-Native] 解析成功: ISO=%{public}d, F=%.1f, Shutter=%.4f",
                    result.iso, result.fNumber, result.exposureTime);
    } else {
        OH_LOG_ERROR(LOG_APP, "[EXIF-Native] 解析失败: %{public}s", result.errorMessage.c_str());
    }
    
    return ExifDataToNapi(env, result);
}

/**
 * Native函数：解析ArrayBuffer
 * 签名: parseExifFromBuffer(buffer: ArrayBuffer): ExifData
 */
static napi_value ParseExifFromBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    if (argc < 1) {
        napi_throw_error(env, nullptr, "Missing buffer argument");
        return nullptr;
    }
    
    // 获取ArrayBuffer数据
    void* data;
    size_t length;
    napi_get_arraybuffer_info(env, args[0], &data, &length);
    
    OH_LOG_INFO(LOG_APP, "[EXIF-Native] 开始解析Buffer: %{public}zu bytes", length);
    
    // 解析EXIF
    exif::ExifParser parser;
    exif::ExifData result = parser.parseBuffer(static_cast<uint8_t*>(data), length);
    
    if (result.success) {
        OH_LOG_INFO(LOG_APP, "[EXIF-Native] Buffer解析成功: ISO=%{public}d", result.iso);
    } else {
        OH_LOG_ERROR(LOG_APP, "[EXIF-Native] Buffer解析失败: %{public}s", result.errorMessage.c_str());
    }
    
    return ExifDataToNapi(env, result);
}

/**
 * 模块初始化
 */
static napi_value Init(napi_env env, napi_value exports) {
    OH_LOG_INFO(LOG_APP, "[EXIF-Native] 🟢 模块初始化开始");
    
    napi_property_descriptor desc[] = {
        { "parseExifFromPath", nullptr, ParseExifFromPath, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "parseExifFromBuffer", nullptr, ParseExifFromBuffer, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    
    OH_LOG_INFO(LOG_APP, "[EXIF-Native] 🟢 方法注册完成");
    
    return exports;
}

// 模块注册
EXTERN_C_START
static napi_module exifModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "exifparser",
    .nm_priv = nullptr,
    .reserved = { 0 },
};

__attribute__((constructor)) void RegisterExifModule(void) {
    napi_module_register(&exifModule);
}
EXTERN_C_END
