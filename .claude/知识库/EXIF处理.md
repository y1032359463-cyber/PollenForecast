# EXIF 数据解析与处理

> **最后更新**: 2026-01-17  
> **来源**: 整合自技术文档

---

## 1. EXIF字段清单（96个字段）

### 1.1 Image Kit API 支持的字段（40+个）

#### P0 核心拍摄参数（7个）
| 字段 | PropertyKey | 说明 |
|------|-------------|------|
| 光圈值 | `F_NUMBER` | 如 f/2.8 |
| 快门速度 | `EXPOSURE_TIME` | 如 1/125s |
| ISO感光度 | `ISO_SPEED_RATINGS` | 如 ISO 100 |
| 焦距 | `FOCAL_LENGTH` | 如 35mm |
| 相机品牌 | `MAKE` | 如 NIKON |
| 相机型号 | `MODEL` | 如 D800E |
| 镜头型号 | `LENS_MODEL` | 如 AF-S 35mm f/1.4G |

#### P1 曝光控制（10个）
- `EXPOSURE_BIAS_VALUE` - 曝光补偿
- `EXPOSURE_MODE` - 曝光模式
- `EXPOSURE_PROGRAM` - 曝光程序
- `METERING_MODE` - 测光模式
- `WHITE_BALANCE` - 白平衡
- `FLASH` - 闪光灯
- `LIGHT_SOURCE` - 光源
- `MAX_APERTURE_VALUE` - 最大光圈
- `FOCAL_LENGTH_IN_35_MM_FILM` - 35mm等效焦距
- `BRIGHTNESS_VALUE` - 亮度值

#### P1 图像属性（8个）
- `IMAGE_WIDTH` / `IMAGE_LENGTH` - 图像尺寸
- `ORIENTATION` - 方向
- `COLOR_SPACE` - 色彩空间
- `CONTRAST` / `SATURATION` / `SHARPNESS` - 对比度/饱和度/锐度
- `SCENE_CAPTURE_TYPE` - 场景捕获类型

#### GPS信息（7个）
- `GPS_LATITUDE` / `GPS_LONGITUDE` - 经纬度
- `GPS_ALTITUDE` - 海拔
- `GPS_LATITUDE_REF` / `GPS_LONGITUDE_REF` - 经纬度参考
- `GPS_TIME_STAMP` / `GPS_DATE_STAMP` - GPS时间戳

#### 其他字段
- 设备信息：`SOFTWARE`, `ARTIST`, `COPYRIGHT`, `IMAGE_DESCRIPTION`, `USER_COMMENT`
- 分辨率：`X_RESOLUTION`, `Y_RESOLUTION`, `RESOLUTION_UNIT`, `DIGITAL_ZOOM_RATIO`
- 时间：`DATE_TIME_ORIGINAL`, `DATE_TIME`, `DATE_TIME_DIGITIZED`

### 1.2 DNG专有字段（12个，需Native C++解析）

| 字段名 | Tag ID | 说明 |
|--------|--------|------|
| DNG版本 | 50706 | 如 "1.4.0.0" |
| DNG向后兼容版本 | 50707 | 如 "1.1.0.0" |
| 唯一相机型号 | 50708 | 相机唯一标识 |
| 相机序列号 | 50735 | 可能为空 |
| DNG镜头信息 | 50736 | 如 "35-35mm f/1.4-1.4" |
| 原始RAW文件名 | 50827 | 如 "DSC_3070.NEF" |
| 基线曝光 | 50730 | 数值 |
| 基线噪点 | 50731 | 数值 |
| 基线锐度 | 50732 | 数值 |
| 线性响应限制 | 50734 | 数值 |
| 阴影比例 | 50739 | 如 "1.0" |
| 预览色彩空间 | 50879 | 如 "sRGB" |

---

## 2. API 使用指南

### 2.1 getImageProperty() - 单个字段读取

```typescript
import { image } from '@kit.ImageKit'

// 安全读取单个属性
async safeGetProperty(imageSource: image.ImageSource, key: image.PropertyKey): Promise<string> {
  try {
    return await imageSource.getImageProperty(key)
  } catch (error) {
    return ''
  }
}
```

### 2.2 并发读取优化（推荐）

```typescript
// 使用 Promise.all 并发读取多个字段
const [aperture, shutterSpeed, iso, focalLength] = await Promise.all([
  this.safeGetProperty(imageSource, image.PropertyKey.F_NUMBER),
  this.safeGetProperty(imageSource, image.PropertyKey.EXPOSURE_TIME),
  this.safeGetProperty(imageSource, image.PropertyKey.ISO_SPEED_RATINGS),
  this.safeGetProperty(imageSource, image.PropertyKey.FOCAL_LENGTH)
])
```

### 2.3 getImageProperties() - 批量读取（API 20）

```typescript
// 批量读取多个EXIF字段
const propertyKeys = [
  image.PropertyKey.F_NUMBER,
  image.PropertyKey.EXPOSURE_TIME,
  image.PropertyKey.ISO_SPEED_RATINGS
]
const properties: Map<image.PropertyKey, string> = await imageSource.getImageProperties(propertyKeys)

// 从Map中获取值
const fNumber = properties.get(image.PropertyKey.F_NUMBER) || ''
```

---

## 3. Native C++ 解析 RAW 格式

### 3.1 支持的格式
DNG, NEF, CR2, CR3, ARW, ORF, RAF, RW2, PEF, SRW, 3FR, DCR, KDC, MRW, NRW, RWL, SR2, SRF, X3F

### 3.2 调用方式

```typescript
import { parseExifFromPath } from '../../cpp/types/libexifparser/index'

// DNG/RAW文件使用Native解析
if (isDngOrRaw(filePath)) {
  const nativeResult = parseExifFromPath(filePath)
  if (nativeResult.success) {
    // 解析成功，包含DNG专有字段
  }
} else {
  // 普通JPG/PNG使用Image Kit
}
```

### 3.3 关键日志

**成功日志**：
```
[EXIF] 🔴 DNG/RAW文件检测到，使用Native C++解析
[EXIF-Native] ✅ 解析成功
[EXIF-Native] DNG版本: 1.4.0.0
```

**失败日志**：
```
[EXIF-Native] ❌ 解析失败: 无法打开文件
[EXIF] ⚠️ Native C++解析失败，fallback到Image Kit
```

---

## 4. 数据格式化

### 4.1 光圈值
```typescript
formatAperture(value: string): string {
  const num = parseFloat(value)
  return isNaN(num) ? value : `f/${num.toFixed(1)}`
}
// "2.8" → "f/2.8"
```

### 4.2 快门速度
```typescript
formatShutterSpeed(value: string): string {
  const num = parseFloat(value)
  if (isNaN(num)) return value
  if (num >= 1) return `${num}s`
  return `1/${Math.round(1/num)}s`
}
// "0.008" → "1/125s"
```

### 4.3 焦距
```typescript
formatFocalLength(value: string): string {
  const num = parseFloat(value)
  return isNaN(num) ? value : `${Math.round(num)}mm`
}
// "35.0" → "35mm"
```

---

## 5. 性能优化

### 5.1 资源释放（必须）

```typescript
let imageSource: image.ImageSource | null = null
let pixelMap: image.PixelMap | null = null

try {
  imageSource = image.createImageSource(fd)
  pixelMap = await imageSource.createPixelMap()
  // 业务逻辑
} finally {
  pixelMap?.release()
  imageSource?.release()
  fileIo.closeSync(fd)
}
```

### 5.2 批量处理限流

- 并发数 ≤ 3张
- 失败重试 ≤ 3次

### 5.3 缩略图生成

```typescript
const pixelMap = await imageSource.createPixelMap({
  desiredSize: { width: 120, height: 120 }
})
```

⚠️ **注意**: `desiredSize` 和 `desiredRegion` 不能同时设置，需要两步法：先裁切再 scale()

---

## 6. 常见问题

### Q1: DNG字段全部为undefined
**排查**：
1. 检查Native模块是否加载
2. 检查文件路径格式（可能需要移除`file://`前缀）
3. 检查日志中的success字段

### Q2: Native模块未加载
**排查**：
1. 检查 `libexifparser.so` 是否存在于构建输出
2. 检查导入路径：`../../cpp/types/libexifparser/index`
3. 删除 `entry\build` 重新构建

### Q3: 普通照片字段为空
**排查**：
1. 部分照片可能不包含完整EXIF数据
2. 截图、社交媒体下载的图片通常无EXIF

---

**相关文档**：
- [避坑指南](./避坑指南.md)
- [性能优化](./性能优化.md)
