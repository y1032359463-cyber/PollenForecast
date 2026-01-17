/**
 * Native EXIF Parser 类型声明
 * CodeGenie方案：使用declare module包装
 */

declare module 'exifparser' {
  /**
   * Native解析返回的EXIF数据结构
   */
  export interface NativeExifResult {
    // 解析状态
    success: boolean;
    errorMessage: string;
    
    // === P0 核心拍摄参数 ===
    cameraMake: string;
    cameraModel: string;
    software: string;
    dateTime: string;
    dateTimeOriginal: string;
    dateTimeDigitized: string;
    aperture: string;
    shutterSpeed: string;
    focalLength: string;
    iso: number;
    focalLength35mm: number;
    
    // === 曝光控制 ===
    exposureProgram: number;
    meteringMode: number;
    flash: number;
    whiteBalance: number;
    exposureMode: number;
    exposureBias: number;
    maxAperture: number;
    
    // === 图像属性 ===
    imageWidth: number;
    imageHeight: number;
    pixelXDimension: number;
    pixelYDimension: number;
    orientation: number;
    colorSpace: number;
    contrast: number;
    saturation: number;
    sharpness: number;
    compression: number;
    photometricInterpretation: number;
    
    // === 镜头信息 ===
    lensModel: string;
    lensMake: string;
    lensSerialNumber: string;
    subjectDistance: number;
    
    // === GPS信息 ===
    hasGPS: boolean;
    gpsLatitude: number;
    gpsLongitude: number;
    gpsAltitude: number;
    gpsLatitudeRef: string;
    gpsLongitudeRef: string;
    gpsTimeStamp: string;
    gpsDateStamp: string;
    gpsSpeed: number;
    gpsImgDirection: number;
    
    // === 时间扩展 ===
    subSecTime: string;
    subSecTimeOriginal: string;
    subSecTimeDigitized: string;
    
    // === 分辨率参数 ===
    xResolution: number;
    yResolution: number;
    resolutionUnit: number;
    focalPlaneXResolution: number;
    focalPlaneYResolution: number;
    focalPlaneResolutionUnit: number;
    
    // === 其他元数据 ===
    imageDescription: string;
    userComment: string;
    bitsPerSample: number;
    samplesPerPixel: number;
    componentsConfiguration: string;
    yCbCrPositioning: number;
    exifVersion: string;
    flashpixVersion: string;
    lightSource: number;
    brightness: number;
    sensingMethod: number;
    relatedSoundFile: string;
    
    // === 新增字段（21个）2025-12-20 ===
    // 机身序列号
    bodySerialNumber: string;
    
    // 图像处理扩展
    gainControl: number;
    digitalZoomRatio: number;
    sceneType: number;
    subjectDistanceRange: number;
    customRendered: number;
    sceneCaptureType: number;
    exposureIndex: number;         // 曝光指数
    cFAPattern: string;            // CFA模式（色彩滤镜阵列）
    
    // 闪光灯扩展
    flashEnergy: number;
    
    // 文件/设备扩展
    fileSource: number;
    
    // 主体信息
    subjectLocation: string;
    subjectArea: string;
    
    // 色彩科学扩展
    whitePoint: string;
    primaryChromaticities: string;
    yCbCrCoefficients: string;
    referenceBlackWhite: string;
    transferFunction: string;
    
    // 光谱扩展
    spectralSensitivity: string;
    oecf: string;
    
    // 制造商私有
    makerNote: string;
    
    // 作者版权
    artist: string;
    copyright: string;
    
    // === Phase 2扩展：DNG 1.4/1.6专有字段（P0 - 12个）===
    dngVersion: string;             // DNG版本
    dngBackwardVersion: string;     // DNG向后兼容版本
    uniqueCameraModel: string;      // 相机唯一标识
    cameraSerialNumberDNG: string;  // 相机序列号-DNG专用
    dngLensInfo: string;            // DNG镜头信息
    originalRawFilename: string;    // 原始RAW文件名
    baselineExposure: number;       // 基线曝光
    baselineNoise: number;          // 基线噪点
    baselineSharpness: number;      // 基线锐度
    linearResponseLimit: number;    // 线性响应限制
    shadowScale: number;            // 阴影比例
    previewColorSpace: string;      // 预览色彩空间
  }

  export function parseExifFromPath(filePath: string): NativeExifResult;
  export function parseExifFromBuffer(buffer: ArrayBuffer): NativeExifResult;
}