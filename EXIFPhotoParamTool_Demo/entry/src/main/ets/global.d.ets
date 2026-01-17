/**
 * 全局类型声明 - Phase 4兜底方案
 * 用于扩展本地模块的类型定义（声明合并）
 * 
 * 使用场景：
 * - Phase 1-3都失败后的临时解决方案
 * - 确保编译通过，但治标不治本
 * 
 * 注意：
 * - 这是TypeScript的声明合并特性
 * - 新增字段会自动扩展原有定义（不覆盖）
 * - 全局生效，所有文件都能访问
 */

declare module 'exifparser' {
  interface NativeExifResult {
    // === 21个新增字段（Phase 5扩展）===
    // 机身序列号
    bodySerialNumber: string;
    
    // 图像处理扩展
    gainControl: number;              // 增益控制（0=无，1=低增益提升，2=高增益提升）
    digitalZoomRatio: number;         // 数字变焦比率
    sceneType: number;                // 场景类型（1=直接拍摄）
    subjectDistanceRange: number;     // 主体距离范围（0=未知，1=微距，2=近景，3=远景）
    customRendered: number;           // 自定义渲染（0=正常，1=自定义）
    sceneCaptureType: number;         // 场景捕获类型（0=标准，1=风景，2=人像，3=夜景）
    
    // 闪光灯扩展
    flashEnergy: number;              // 闪光灯能量（BCPS）
    
    // 文件/设备扩展
    fileSource: number;               // 文件来源（3=DSC）
    
    // 主体信息
    subjectLocation: string;          // 主体位置
    subjectArea: string;              // 主体区域
    
    // 色彩科学扩展
    whitePoint: string;               // 白点
    primaryChromaticities: string;    // 原色度
    yCbCrCoefficients: string;        // YCbCr系数
    referenceBlackWhite: string;      // 参考黑白点
    transferFunction: string;         // 传输函数
    
    // 光谱扩展
    spectralSensitivity: string;      // 光谱灵敏度
    oecf: string;                     // 光电转换函数
    
    // 制造商私有
    makerNote: string;                // 制造商备注
    
    // 作者版权
    artist: string;                   // 作者
    copyright: string;                // 版权信息
  }
}
