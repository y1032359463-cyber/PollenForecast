# ArkTS 语法与类型系统

> **分类**: ArkTS 核心语法规则与 API 20 适配
> **最后更新**: 2026-01-13（新增：直辖市JSON数据结构特殊处理）
> **返回**: [← 主知识库](../知识库.md)

---

## 📑 本分类包含

1. [ArkTS 模块类型导出规则](#arkts-模块类型导出规则)
2. [@Builder 响应式更新](#builder-响应式更新)
3. [ForEach Key 响应式更新规则](#foreach-key-响应式更新规则)
4. [ArkTS catch 子句类型注解规则](#arkts-catch-子句类型注解规则)
5. [ArkTS 对象字面量类型禁止规则](#arkts-对象字面量类型禁止规则) ✨ 新增
6. [Base64 编码（ArkTS 替代 btoa）](#base64-编码arkts-替代-btoa)
7. [页面返回手势处理（onBackPress）](#5-页面返回手势处理onbackpress)
8. [JSON UTF-8 编码解码（TextDecoder）](#json-utf-8-编码解码textdecoder) ✨
9. [直辖市JSON数据结构特殊处理](#直辖市json数据结构特殊处理) ✨ 新增
10. [List组件点击事件绑定规范](#list组件点击事件绑定规范) ✨ 新增
11. [ArkTS 语法与 API 适配 (API 20)](#arkts-语法与-api-适配-api-20)
12. [@Builder 布局嵌套完整性](#builder-布局嵌套完整性) ✨ 新增

---

## ArkTS 模块类型导出规则

> ✅ **已验证**: 2025-12-21 (EXIFPhotoParamTool 项目)
> **问题**: `Module has no exported member 'InterfaceName'` 编译错误
> **根本原因**: `declare module` 内的 interface 未显式导出
> **来源**: CodeGenie 专家建议

### 核心规则

**1. declare module 内所有类型必须显式 export**
```typescript
// ❌ 错误写法：默认不导出
declare module 'mymodule' {
  interface MyType { ... }  // 不可见
}

// ✅ 正确写法：显式export
declare module 'mymodule' {
  export interface MyType { ... }  // 可被导入
  export function myFunc(): MyType;
}
```

**说明**：
- ArkTS 不支持隐式导出（与标准 TypeScript 一致）
- 即使在 `.d.ts` 文件中也需要 export 关键字
- 所有 interface/function/type 都必须有 export

**2. .d.ts 与 .ets 文件职责分离**

| 文件 | 职责 | 导出方式 |
|------|------|----------|
| `index.d.ts` | 类型声明（供编译器） | `export interface/function` |
| `index.ets` | 运行时实现 | `export function/const` |
| `oh-package.json5` | 配置 | `"main": ".ets", "types": ".d.ts"` |

**错误实践**（无效）：
```typescript
// index.ets 中导出 .d.ts 的类型 ❌
export type { MyType }  // 不生效！类型只能在 .d.ts 中导出
```

**正确实践**：
```typescript
// index.d.ts（完整类型声明）
declare module 'mymodule' {
  export interface MyType { ... }
  export function myFunc(): MyType;
}

// index.ets（仅实现逻辑）
export function myFunc() { ... }
```

**3. 类型系统解析优先级**

当同时存在 `.d.ts` 和 `.ets`：
1. 编译器优先读取 `oh-package.json5` 的 `types` 字段
2. `.d.ts` 的类型声明 **完全覆盖** `.ets` 的类型推断
3. `.ets` 的 `export type` 语句在有 `.d.ts` 时被忽略

### 常见错误及解决方案

**错误1**: `Module has no exported member`
- **原因**: `declare module` 内 interface 缺少 export
- **解决**: 添加 `export` 关键字

**错误2**: `Duplicate export`
- **原因**: 函数既用 `export function` 又在末尾 `export { func }`
- **解决**: 删除重复的导出语句

**错误3**: `.ets` 中 `export type` 无效
- **原因**: 类型定义在 `.d.ts` 中，`.ets` 无法二次导出
- **解决**: 删除 `.ets` 中的 `export type` 语句

---

## @Builder 响应式更新

### 强制性规则

**✅ 正确写法：参数传递式响应**
```typescript
@Builder
TabBuilder(safeBottom: number) {
  Column() {
    // 使用传入参数
  }
  .height(56 + safeBottom)
}

// 调用时
this.TabBuilder(this.safeBottom)
```

**❌ 错误写法：直接引用存储值**
```typescript
@Builder
TabBuilder() {
  Column() {
    // 直接使用 this.safeBottom 不会触发更新
  }
}
```

### 多参数优化

使用对象封装：
```typescript
interface SafeAreaParams {
  top: number,
  bottom: number
}

@Builder
TabBuilder(params: SafeAreaParams) {
  // 使用 params.top / params.bottom
}
```

---

## ForEach Key 响应式更新规则

> ✅ **已验证**: 2025-12-24
> **场景**: 列表项更新后 UI 不刷新

### 核心规则

**Key 必须唯一且能反映数据变化**

```typescript
// ❌ 错误：仅用 id（数据更新但 id 不变，UI 不刷新）
ForEach(this.records, (record: PhotoRecord) => {
  // ...
}, (record: PhotoRecord) => record.id)

// ✅ 正确：id + 变化字段（笔记更新会改变 updateTime）
ForEach(this.records, (record: PhotoRecord) => {
  // ...
}, (record: PhotoRecord) => record.id + '_' + record.updateTime.toString())
```

### 组合 Key 策略

| 场景 | Key 组合 | 示例 |
|------|---------|------|
| 仅显示静态数据 | `id` | `record.id` |
| 包含可编辑字段 | `id + updateTime` | `${record.id}_${record.updateTime}` |
| 排序可变列表 | `id + index` | `${record.id}_${index}` |
| 状态可切换项 | `id + status` | `${record.id}_${record.status}` |

---

## ArkTS catch 子句类型注解规则

> ✅ **已验证**: 2025-12-26
> **错误码**: `arkts-no-types-in-catch`

### 规则说明

ArkTS **禁止**在 catch 子句中为错误对象添加类型注解。

**❌ 错误写法**：
```typescript
try {
  await someAsyncOperation()
} catch (error: Error) {  // ❌ 编译错误：arkts-no-types-in-catch
  console.error(error.message)
}
```

**✅ 正确写法**：
```typescript
try {
  await someAsyncOperation()
} catch (error) {  // ✅ 不添加类型注解
  console.error('操作失败: ' + error)
}
```

### 类型安全处理

如需类型检查，在 catch 内部进行：
```typescript
try {
  await someAsyncOperation()
} catch (error) {
  if (error instanceof Error) {
    console.error(`错误: ${error.message}`)
  } else {
    console.error(`未知错误: ${JSON.stringify(error)}`)
  }
}
```

---

## ArkTS 展开运算符禁止规则

> ✅ **已验证**: 2026-01-10 (PollenForecast 项目)
> **错误码**: `arkts-no-spread`
> **问题**: ArkTS 不支持展开运算符 `...`，必须显式创建对象/数组

### 核心规则

**ArkTS 严格模式禁止使用展开运算符**

**❌ 错误写法**：
```typescript
// 错误1: 对象展开
const newObj = { ...oldObj }  // ❌ 编译错误：arkts-no-spread
const updatedCity = { ...city, isFavorite: true }  // ❌ 错误

// 错误2: 数组展开
const newArr = [...oldArr]  // ❌ 编译错误：arkts-no-spread
const copy = [...this.cityList]  // ❌ 错误
```

**✅ 正确写法**：
```typescript
// 对象：显式创建所有字段
const newObj: CityItem = {
  name: oldObj.name,
  distance: oldObj.distance,
  isFavorite: oldObj.isFavorite,
  isTop: oldObj.isTop,
  province: oldObj.province,
  pinyin: oldObj.pinyin,
  pinyinInitial: oldObj.pinyinInitial,
  pollenLevel: oldObj.pollenLevel,
  pollenIndex: oldObj.pollenIndex
}

// 数组：使用 for 循环复制
const newArr: CityItem[] = []
for (let i = 0; i < oldArr.length; i++) {
  newArr.push(oldArr[i])
}
```

### 常见错误场景

| 错误场景 | 错误码 | 解决方案 |
|---------|--------|---------|
| `{ ...obj }` | `arkts-no-spread` | 显式列出所有字段创建对象 |
| `[...arr]` | `arkts-no-spread` | 使用 `for` 循环复制数组 |
| `{ ...obj, key: value }` | `arkts-no-spread` | 显式创建对象并设置新值 |
| `arr.map(x => ({ ...x, key: value }))` | `arkts-no-spread` | 在 map 中显式创建对象 |

### 修复示例

**修复前**：
```typescript
// ❌ 错误：使用展开运算符
toggleFavorite(cityName: string): void {
  const newList = [...this.cityList]
  const updatedCity = { ...city, isFavorite: !city.isFavorite }
  newList[index] = updatedCity
  this.cityList = newList
}
```

**修复后**：
```typescript
// ✅ 正确：显式创建
toggleFavorite(cityName: string): void {
  const newList: CityItem[] = []
  for (let i = 0; i < this.cityList.length; i++) {
    newList.push(this.cityList[i])
  }
  const city = newList[index]
  const updatedCity: CityItem = {
    name: city.name,
    distance: city.distance,
    isFavorite: !city.isFavorite,
    isTop: city.isTop,
    province: city.province,
    pinyin: city.pinyin,
    pinyinInitial: city.pinyinInitial,
    pollenLevel: city.pollenLevel,
    pollenIndex: city.pollenIndex
  }
  newList[index] = updatedCity
  this.cityList = newList
}
```

### 关键要点

- ✅ **对象复制**：必须显式列出所有字段
- ✅ **数组复制**：使用 `for` 循环或 `slice()`（如果支持）
- ✅ **类型明确**：创建对象时使用 `const obj: Interface = { ... }`
- ❌ **禁止展开**：不能在对象/数组位置使用 `...`

---

## ArkTS 对象字面量类型禁止规则

> ✅ **已验证**: 2026-01-07 (PollenForecast 项目)
> **错误码**: `arkts-no-obj-literals-as-types` / `arkts-no-untyped-obj-literals`
> **问题**: 对象字面量不能作为类型声明，必须使用显式接口

### 核心规则

**ArkTS 严格模式禁止使用对象字面量作为类型声明**

**❌ 错误写法**：
```typescript
// 错误1: 对象字面量作为类型声明
private async getAddressAsync(lat: number, lng: number): Promise<{ city: string, address: string } | null> {
  // ❌ 编译错误：arkts-no-obj-literals-as-types
}

// 错误2: 未类型化的对象字面量
return { city, address }  // ❌ 编译错误：arkts-no-untyped-obj-literals
```

**✅ 正确写法**：
```typescript
// 步骤1: 先定义接口
interface AddressInfo {
  city: string
  address: string
}

// 步骤2: 使用接口作为类型
private async getAddressAsync(lat: number, lng: number): Promise<AddressInfo | null> {
  // ...

  // 步骤3: 显式创建对象（符合接口类型）
  const addressInfo: AddressInfo = { city, address }
  return addressInfo
}
```

### 常见错误场景

| 错误场景 | 错误码 | 解决方案 |
|---------|--------|---------|
| `Promise<{ a: string }>` | `arkts-no-obj-literals-as-types` | 定义接口 `interface A { a: string }`，使用 `Promise<A>` |
| `return { a: string }` | `arkts-no-untyped-obj-literals` | 定义接口并显式创建对象 |
| 函数参数 `{ x: number }` | `arkts-no-obj-literals-as-types` | 定义接口作为参数类型 |

### 修复示例（LocationService.ets）

**修复前**：
```typescript
private async getAddressAsync(lat: number, lng: number): Promise<{ city: string, address: string } | null> {
  return { city, address }  // ❌ 两处错误
}
```

**修复后**：
```typescript
interface AddressInfo {
  city: string
  address: string
}

private async getAddressAsync(lat: number, lng: number): Promise<AddressInfo | null> {
  const addressInfo: AddressInfo = { city, address }  // ✅ 正确
  return addressInfo
}
```

### 关键要点

- ✅ **必须定义接口**：所有对象字面量类型都需要对应的接口定义
- ✅ **显式类型标注**：创建对象时使用 `const obj: Interface = { ... }`
- ✅ **接口位置**：接口可以定义在文件顶部或类外部
- ❌ **禁止内联类型**：不能在类型位置直接写 `{ key: type }`

---

## Base64 编码（ArkTS 替代 btoa）

> ✅ **已验证**: 2025-12-24
> **场景**: 图片数据转 Base64 字符串

### 标准方案

ArkTS 没有 `btoa()`，使用 `util.Base64Helper`：

```typescript
import { util } from '@kit.ArkTS'

// ArrayBuffer → Base64 字符串
function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const uint8Array = new Uint8Array(buffer)
  const base64Helper = new util.Base64Helper()
  return base64Helper.encodeToStringSync(uint8Array)
}

// 使用示例
const imageBuffer: ArrayBuffer = ... // 图片二进制数据
const base64String = arrayBufferToBase64(imageBuffer)
const dataUrl = `data:image/jpeg;base64,${base64String}`
```

### API 对照表

| Web API | ArkTS API | 说明 |
|---------|-----------|------|
| `btoa(str)` | `util.Base64Helper.encodeToStringSync(Uint8Array)` | 编码 |
| `atob(str)` | `util.Base64Helper.decodeSync(str)` | 解码 |

---

## JSON UTF-8 编码解码（TextDecoder）

> ✅ **已验证**: 2026-01-12 (PollenForecast 项目)
> **场景**: 从 rawfile 加载JSON文件，中文乱码
> **根本原因**: `String.fromCharCode()` 按单字节解码UTF-8编码的JSON，导致中文乱码
> **来源**: PollenForecast 项目实践

### 核心问题

**错误用法**：使用 `String.fromCharCode()` 逐字节拼接字符串

```typescript
// ❌ 错误写法：按单字节解码，导致UTF-8中文乱码
const rawFile = await resMgr.getRawFileContent('china_area_full.json')
const uint8Array = new Uint8Array(rawFile.buffer)
let jsonString = ''
for (let i = 0; i < uint8Array.length; i++) {
  jsonString += String.fromCharCode(uint8Array[i])  // ❌ 乱码！
}
const data = JSON.parse(jsonString)

// 结果：城市名显示为 "æ´é³å¸" 而不是 "洛阳市"
```

### 正确方案

**使用 `util.TextDecoder` 正确解码UTF-8**

```typescript
import util from '@ohos.util'

// ✅ 正确写法：使用TextDecoder
const rawFile = await resMgr.getRawFileContent('china_area_full.json')
const uint8Array = new Uint8Array(rawFile.buffer)
const decoder = new util.TextDecoder('utf-8')  // 指定UTF-8编码
const jsonString = decoder.decodeWithStream(uint8Array)  // 正确解码
const data = JSON.parse(jsonString)

// 结果：城市名正确显示为 "洛阳市"
```

### 原理说明

1. **UTF-8 编码特点**：
   - 中文字符占 3 个字节（如 `洛` = `0xE6 0xB4 0x9B`）
   - `String.fromCharCode()` 按单字节处理，把 3 个字节当成03个 Latin1 字符

2. **乱码过程**：
   ```
   UTF-8: E6 B4 9B (3字节) → "洛"
   错误解码: æ + ´ +  → "æ´" (乱码)
   ```

3. **TextDecoder 优势**：
   - 自动处理多字节字符
   - 支持流式解码（`decodeWithStream`）
   - 性能优化（原生 API）

### 完整示例（ChinaAreaDataLoader.ets）

```typescript
import { CityItem, DistrictItem, LocationCoordinate } from './CityUtils'
import resourceManager from '@ohos.resourceManager'
import util from '@ohos.util'  // ✅ 导入TextDecoder

interface RawAreaData {
  citycode: string | string[]
  adcode: string
  name: string
  center: string
  level: string
  districts: RawAreaData[]
}

export async function loadChinaAreaData(context: Context): Promise<CityItem[]> {
  try {
    const resMgr = context.resourceManager
    const rawFile = await resMgr.getRawFileContent('china_area_full.json')
    
    // 🔧 使用TextDecoder正确解码UTF-8
    const uint8Array = new Uint8Array(rawFile.buffer)
    const decoder = new util.TextDecoder('utf-8')
    const jsonString = decoder.decodeWithStream(uint8Array)
    
    // 解析JSON
    const provinceData: RawAreaData[] = JSON.parse(jsonString)
    
    // 转换为CityItem数组
    const cities: CityItem[] = []
    for (const province of provinceData) {
      for (const city of province.districts) {
        if (city.level === 'city') {
          cities.push({
            name: city.name,  // ✅ 中文正常显示
            province: province.name,
            // ...
          })
        }
      }
    }
    
    console.info(`[加载完成] 共 ${cities.length} 个城市`)
    return cities
  } catch (error) {
    console.error(`[加载失败] ${error}`)
    return []
  }
}
```

### 关键要点

| 项目 | 错误做法 | 正确做法 |
|------|----------|----------|
| **导入** | 无导入 | `import util from '@ohos.util'` |
| **实例化** | - | `new util.TextDecoder('utf-8')` |
| **解码** | `String.fromCharCode(byte)` | `decoder.decodeWithStream(uint8Array)` |
| **编码指定** | 无 | 必须指定 `'utf-8'` |

### 常见错误

**错衷1**: 忘记导入 util
```typescript
// ❌ const decoder = new TextDecoder('utf-8')  // TextDecoder is not defined
// ✅ import util from '@ohos.util'
//    const decoder = new util.TextDecoder('utf-8')
```

**错衷2**: 使用错误的解码方法
```typescript
// ❌ const text = decoder.decode(uint8Array)  // 方法不存在
// ✅ const text = decoder.decodeWithStream(uint8Array)
```

**错衷3**: 未指定编码
```typescript
// ❌ const decoder = new util.TextDecoder()  // 默认可能不是UTF-8
// ✅ const decoder = new util.TextDecoder('utf-8')  // 显式指定
```

### 适用场景

- ✅ 从 rawfile 加载JSON文件（包含中文）
- ✅ 从网络请求获取的二进制数据解码
- ✅ 文件读取后的字符串转换
- ✅ 任何需要处理UTF-8编码的场景

---

## 直辖市JSON数据结构特殊处理

> ✅ **已验证**: 2026-01-13 (PollenForecast 项目)
> **场景**: 三级城市选择功能，直辖市（北京、上海、天津、重庆）无法弹出区县菜单
> **根本原因**: 直辖市的JSON数据结构与普通城市不同，需要特殊处理
> **来源**: PollenForecast 项目实践

### 核心问题

**直辖市与JSON数据结构差异**

```typescript
// 普通城市结构：省份 → 城市 → 区县
{
  "name": "河南省",
  "level": "province",
  "districts": [{
    "name": "洛阳市",
    "level": "city",
    "districts": [{
      "name": "新安县",
      "level": "district"
    }]
  }]
}

// 直辖市结构：直辖市 → 城市容器 → 区县
{
  "name": "北京市",
  "level": "province",  // ← 注意：直辖市本身是 province 级别
  "districts": [{
    "name": "北京城区",  // ← 这是中间层容器
    "level": "city",
    "districts": [{
      "name": "怀柔区",  // ← 真正的区县在这里
      "level": "district"
    }]
  }]
}
```

**问题现象**：
- 普通城市（如洛阳、广州）：三级菜单正常弹出
- 直辖市（北京、上海、天津、重庆）：三级菜单无法弹出

### 错误写法

**❓ 只处理 `level === 'city'` 的节点，导致直辖市被跳过**

```typescript
export async function loadChinaAreaData(context: Context): Promise<CityItem[]> {
  const provinceData: RawAreaData[] = JSON.parse(jsonString)
  const cities: CityItem[] = []
  
  for (const province of provinceData) {
    // ⚠️ 问题：只遍历 province.districts 中 level='city' 的节点
    for (const city of province.districts) {
      if (city.level !== 'city') continue  // ← 直辖市的 province 本身不是 'city'，被跳过！
      
      // 解析区县
      const districts: DistrictItem[] = []
      for (const district of city.districts) {
        if (district.level === 'district') {
          districts.push({ name: district.name, ... })
        }
      }
      
      cities.push({
        name: city.name,
        province: province.name,
        districts: districts
      })
    }
  }
  return cities
}
```

**问题分析**：
1. 代码假设所有省份下直接是 `level='city'` 的城市
2. 但直辖市的 `province.districts[0]` 是中间层容器（如 "北京城区"）
3. 真正的区县在 `province.districts[0].districts` 中
4. 因此直辖市数据被完全跳过，查询时找不到

### 正确方案

**✅ 特殊检测直辖市，直接使用 province 作为 city**

```typescript
export async function loadChinaAreaData(context: Context): Promise<CityItem[]> {
  const provinceData: RawAreaData[] = JSON.parse(jsonString)
  const cities: CityItem[] = []
  
  for (const province of provinceData) {
    // 📦 特殊处理：直辖市（北京、上海、天津、重庆）
    const isDirectCity = ['北京', '上海', '天津', '重庆'].some(name => province.name.includes(name))
    
    if (isDirectCity && province.districts.length > 0) {
      // 直辖市：直接使用 province 作为 city
      const cityDistricts = province.districts[0]?.districts || []  // ← 从容器中获取区县
      const location = parseCenter(province.center)
      
      const districts: DistrictItem[] = []
      for (const district of cityDistricts) {
        if (district.level === 'district') {
          const districtLocation = parseCenter(district.center)
          districts.push({
            name: district.name,
            cityName: province.name,  // ← 直辖市名
            isFavorite: false,
            isTop: false,
            adcode: district.adcode,
            location: districtLocation
          })
        }
      }
      
      cities.push({
        name: province.name,  // ← 直辖市名（如 "北京市"）
        province: province.name,  // ← 省份名也是直辖市名
        distance: 0,
        isFavorite: false,
        isTop: false,
        hasDistricts: districts.length > 0,
        districts: districts.length > 0 ? districts : undefined,
        adcode: province.adcode,
        location: location
      })
      continue  // ← 跳过后面的普通城市处理
    }
    
    // 普通省份：遍历省份下的城市
    for (const city of province.districts) {
      if (city.level !== 'city') continue
      // ... 普通城市处理逻辑
    }
  }
  
  return cities
}
```

### 关键要点

| 项目 | 普通城市 | 直辖市 |
|------|----------|--------|
| **省份名** | `河南省` | `北京市` |
| **城市名** | `洛阳市` | `北京市` (与省份名相同) |
| **结构层次** | `province → city → district` | `province → [container] → district` |
| **区县位置** | `province.districts[i].districts` | `province.districts[0].districts` |
| **中间层** | 无 | 有（如 "北京城区"）|

### 检测逻辑

```typescript
// ✅ 方法1：按城市名匹配
const isDirectCity = ['北京', '上海', '天津', '重庆'].some(name => province.name.includes(name))

// ✅ 方梕2：按 adcode 前两位匹配（直辖市的 adcode）
const directCityAdcodes = ['110000', '310000', '120000', '500000']  // 北京、上海、天津、重庆
const isDirectCity = directCityAdcodes.includes(province.adcode)

// ✅ 方梕3：结合判断（最严谨）
const isDirectCity = (
  ['北京', '上海', '天津', '重庆'].some(name => province.name.includes(name)) &&
  province.districts.length > 0 &&
  province.districts[0].level === 'city'
)
```

### 完整示例（ChinaAreaDataLoader.ets）

```typescript
import { CityItem, DistrictItem } from './CityUtils'
import util from '@ohos.util'

interface RawAreaData {
  citycode: string | string[]
  adcode: string
  name: string
  center: string
  level: string
  districts: RawAreaData[]
}

export async function loadChinaAreaData(context: Context): Promise<CityItem[]> {
  try {
    const resMgr = context.resourceManager
    const rawFile = await resMgr.getRawFileContent('china_area_full.json')
    
    const uint8Array = new Uint8Array(rawFile.buffer)
    const decoder = new util.TextDecoder('utf-8')
    const jsonString = decoder.decodeWithStream(uint8Array)
    const provinceData: RawAreaData[] = JSON.parse(jsonString)
    
    const cities: CityItem[] = []
    
    for (const province of provinceData) {
      // 📦 特殊处理：直辖市
      const isDirectCity = ['北京', '上海', '天津', '重庆'].some(name => province.name.includes(name))
      
      if (isDirectCity && province.districts.length > 0) {
        const cityDistricts = province.districts[0]?.districts || []
        const location = parseCenter(province.center)
        
        const districts: DistrictItem[] = []
        for (const district of cityDistricts) {
          if (district.level === 'district') {
            districts.push({
              name: district.name,
              cityName: province.name,
              isFavorite: false,
              isTop: false,
              adcode: district.adcode,
              location: parseCenter(district.center)
            })
          }
        }
        
        cities.push({
          name: province.name,
          province: province.name,
          distance: 0,
          isFavorite: false,
          isTop: false,
          hasDistricts: districts.length > 0,
          districts: districts.length > 0 ? districts : undefined,
          adcode: province.adcode,
          location: location
        })
        continue
      }
      
      // 普通省份处理
      for (const city of province.districts) {
        if (city.level !== 'city') continue
        
        const location = parseCenter(city.center)
        const districts: DistrictItem[] = []
        
        for (const district of city.districts) {
          if (district.level === 'district') {
            districts.push({
              name: district.name,
              cityName: city.name,
              isFavorite: false,
              isTop: false,
              adcode: district.adcode,
              location: parseCenter(district.center)
            })
          }
        }
        
        cities.push({
          name: city.name,
          province: province.name,
          distance: 0,
          isFavorite: false,
          isTop: false,
          hasDistricts: districts.length > 0,
          districts: districts.length > 0 ? districts : undefined,
          adcode: city.adcode,
          location: location
        })
      }
    }
    
    console.info(`[加载完成] 共 ${cities.length} 个城市`)
    return cities
  } catch (error) {
    console.error(`[加载失败] ${error}`)
    return []
  }
}

function parseCenter(center: string): LocationCoordinate {
  const parts = center.split(',')
  return {
    lng: parseFloat(parts[0]),
    lat: parseFloat(parts[1])
  }
}
```

### 常见错误

**错误1**: 忽略直辖市特殊结构
```typescript
// ❓ 直接遍历 province.districts，假设都是 city
// → 直辖市的 province.districts[0] 是容器，不是真正的城市
```

**错误2**: 只检查省份名，不检查结构
```typescript
// ❓ 只根据 province.name 判断，不检查 districts 是否存在
// → 可能导致空指针错误
```

**错误3**: 忽略中间层容器
```typescript
// ❓ 直接遍历 province.districts 作为区县
// → 直辖市的 province.districts[0] 是容器，不是区县
```

### 适用场景

- ✅ 加载中国行政区划数据（如 modood/china-area-data）
- ✅ 三级城市选择功能（省→市→区/县）
- ✅ 地址解析和地理编码转换
- ✅ 城市列表展示和搜索
- ✅ 任何需要处理中国行政区划的场景

---

## ArkTS 语法与 API 适配 (API 20)

### 1. 异常处理严格模式
> 已验证: 2025-12-07

**问题**: throw err 报错 (err 类型为 unknown)
**解决**: 仅记录日志或类型检查后再抛出

### 2. LocalStorage 与 @Entry
**问题**: @Entry 缺少参数警告
**解决**: @Entry(storage) 显式传递 LocalStorage 实例

### 3. 废弃 API 适配指南（API 20）

> ✅ **已验证**: 2026-01-10  
> **来源**: PollenForecast 项目实践  
> **适用项目**: 从 API 9/17 升级到 API 20 的应用

#### 完整替代方案表格

| 废弃 API | 替代方案 | 说明 |
|---------|---------|------|
| `px2vp(value)` | `value / display.getDefaultDisplaySync().densityPixels` | 全局函数已移除，需手动计算 |
| `onScroll` | `onDidScroll` | 滚动事件更名 |
| `animateTo` | `.animation()` 属性 或 `this.getUIContext().animateTo()` | 推荐使用属性动画，或通过 UIContext 调用 |
| `promptAction.*` (静态) | `this.getUIContext().getPromptAction().*` | 必须通过 UIContext 调用 |
| `router.*` (静态) | `this.getUIContext().getRouter().*` | 必须通过 UIContext 调用 |
| `getContext(this)` | `this.getUIContext().getHostContext()` | 获取上下文的新方式 |

#### 使用示例

**px2vp 替代**：
```typescript
// ❌ 废弃写法
const width = px2vp(100)

// ✅ 正确写法
import { display } from '@kit.ArkUI';
const densityPixels = display.getDefaultDisplaySync().densityPixels;
const width = 100 / densityPixels;
```

**promptAction 替代**：
```typescript
// ❌ 废弃写法
import { promptAction } from '@kit.ArkUI';
promptAction.showToast({ message: '提示' });

// ✅ 正确写法
import { promptAction } from '@kit.ArkUI';
this.getUIContext().getPromptAction().showToast({ message: '提示' });
```

**router 替代**：
```typescript
// ❌ 废弃写法
import { router } from '@kit.AbilityKit';
router.pushUrl({ url: 'pages/Index' });

// ✅ 正确写法
import { router } from '@kit.AbilityKit';
this.getUIContext().getRouter().pushUrl({ url: 'pages/Index' });
```

### 4. AppStorage 全局对象（API 20）

> ✅ **已验证**: 2026-01-10 (PollenForecast 项目)
> **问题**: `Module '"@kit.ArkData"' has no exported member 'AppStorage'`
> **根本原因**: AppStorage 是全局内置对象，不需要导入，但在API 20中方法名有所变化
> **来源**: 华为智能客服、小艺、CodeGenie（专家共识）

#### 核心规则

**AppStorage 是全局内置对象，但现在应通过 '@kit.ArkUI' 导入**

```typescript
// ❌ 错误写法：尝试直接使用（旧版本）
AppStorage.setOrCreate('isDarkMode', false)  // 可能不再支持

// ❌ 错误写法：错误的导入路径
import { AppStorage } from '@kit.ArkData'  // 编译错误

// ✅ 正确写法：通过 '@kit.ArkUI' 导入
import { AppStorage } from '@kit.ArkUI'
AppStorage.SetOrCreate<string>('currentCity', cityName)
const value = AppStorage.Get<string>('currentCity')
```

**重要变化**：
- 导入方式：`import { AppStorage } from '@kit.ArkUI'`
- 方法名变化：`SetOrCreate` 和 `Get`（首字母大写）
- 必须使用泛型：`SetOrCreate<string>('key', value)`
- 旧方法名如 `setOrCreate` 不再支持

#### 核心规则

**AppStorage 是全局内置对象，无需导入**

```typescript
// ❌ 错误写法：尝试导入
import { AppStorage } from '@kit.ArkData'  // 编译错误

// ✅ 正确写法：直接使用全局对象
## @Builder 布局嵌套完整性

> ✅ **已验证**: 2026-01-15 (PollenForecast 项目)
> **场景**: 使用 `search_replace` 修改代码后报出大量方法识别错误。

### 核心规则

在 ArkTS 中，组件的方法（如 `@Builder`）内部必须保持严谨的 UI 描述结构。在使用自动化工具修改代码时，极易发生以下错误：

1.  **容器丢失**：删除了 `Column() {` 但保留了对应的 `}`。
2.  **花括号失配**：导致编译器认为后续的方法定义是在类外部。

**❌ 典型错误结构**：
```typescript
@Builder
MyComponent() {
  // Column() { // <-- 容器被误删
    Text('Hello')
  } // <-- 这里的闭合花括号会导致后续代码解析异常
}
```

**✅ 稳健修改策略**：
- 在修改 `@Builder` 内部逻辑时，务必包含外层容器的头部和尾部作为上下文。
- 修改后立即检查类的末尾是否有多余或缺失的花括号。

---
const value = AppStorage.get('isDarkMode')
const hasKey = AppStorage.has('isDarkMode')
```

**说明**：
- API 20 中 `AppStorage` 是 ArkTS 运行时全局内置对象（类似 `console`）
- `@kit.ArkData` 模块在 API 20 已废弃，不导出 `AppStorage`
- 所有操作可直接调用，无需任何导入语句

#### 深浅色模式适配用法

**EntryAbility.ets**：
```typescript
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化AppStorage（无需导入，直接使用）
    const initialColorMode = this.context.config.colorMode
    const initialIsDarkMode = (initialColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    AppStorage.setOrCreate('isDarkMode', initialIsDarkMode)
  }

  onConfigurationUpdated(newConfig: Configuration): void {
    // 配置变化时更新AppStorage（页面@StorageLink会自动响应）
    const newIsDarkMode = (newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    AppStorage.setOrCreate('isDarkMode', newIsDarkMode)
  }
}
```
```

**Index.ets**：
```typescript
@Entry
@Component
struct Index {
  // 使用@StorageLink自动同步AppStorage（无需导入）
  @StorageLink('isDarkMode') isDarkMode: boolean = false

  build() {
    Column() {
      // UI内容
    }
    .backgroundColor(this.isDarkMode ? '#1C1C1E' : '#F8FAFC')
  }
}
```

#### 关键要点

| 项目 | 正确做法 |
|------|----------|
| **AppStorage 导入** | ❌ 不需要导入，直接使用全局对象 |
| **Ability 监听** | 实现 `onConfigurationUpdated` 更新 AppStorage |
| **页面同步** | 使用 `@StorageLink('key')` 自动同步 |
| **生命周期名** | `onConfigurationUpdated`（已验证，API 20正确方法名） |

#### 装饰器对比

| 装饰器 | 绑定方式 | 适用场景 |
|--------|----------|----------|
| `@StorageLink` | 双向绑定（AppStorage ↔ 组件） | 深浅色模式、全局配置 |
| `@StorageProp` | 单向绑定（AppStorage → 组件） | 只读配置 |

### 5. 页面返回手势处理（onBackPress）

> ✅ **已验证**: 2026-01-02 (EXIFPhotoParamTool 项目)
> **问题**: 多选模式下需要拦截返回手势，退出多选模式而不是退出应用
> **来源**: CodeGenie + 华为智能助手

#### 核心规则

**@Entry组件支持onBackPress()方法处理返回手势**

```typescript
@Entry
@Component
struct Index {
  @State isMultiSelectMode: boolean = false

  // ✅ 正确：在@Entry组件中定义onBackPress方法
  onBackPress(): boolean {
    if (this.isMultiSelectMode) {
      this.exitMultiSelectMode()
      return true  // 拦截返回操作，不退出应用
    }
    return false  // 放行返回操作，使用默认行为
  }

  build() {
    Stack() {
      // 页面内容
    }
  }

  private exitMultiSelectMode(): void {
    this.isMultiSelectMode = false
    this.selectedIds = []
  }
}
```

**说明**：
- `onBackPress()` 是 `@Entry` 组件的标准生命周期方法
- 返回 `true` 表示拦截返回操作（不退出应用）
- 返回 `false` 表示放行返回操作（使用默认行为）
- 无需导入任何模块，直接在组件中定义即可

#### 错误尝试（已验证失败）

**❌ 错误1：在Column/Stack上添加onBackPress**
```typescript
Column() {
  .onBackPress(() => { ... })  // ❌ 编译错误：不符合UI组件语法
}
```

**❌ 错误2：使用Page组件包装**
```typescript
Page() {
  Stack() { ... }
}
.onBackPress(() => { ... })  // ❌ 编译错误：Page组件语法错误
```

**❌ 错误3：使用router.enableBack()**
```typescript
aboutToDisappear() {
  router.enableBack({ ... })  // ❌ API可能不存在或用法不正确
}
```

#### 正确用法

**✅ 在@Entry组件中直接定义onBackPress方法**：
```typescript
@Entry
@Component
struct MyPage {
  @State customMode: boolean = false

  // ✅ 正确：直接定义onBackPress方法
  onBackPress(): boolean {
    if (this.customMode) {
      // 自定义处理逻辑
      this.exitCustomMode()
      return true  // 拦截返回
    }
    return false  // 放行返回
  }

  build() {
    // 页面内容
  }
}
```

#### 关键要点

| 项目 | 说明 |
|------|------|
| **方法位置** | 必须在 `@Entry` 组件中定义，不能在子组件中 |
| **返回值** | `boolean` 类型，`true`=拦截，`false`=放行 |
| **导入** | 无需导入任何模块 |
| **生命周期** | 每次返回手势触发时调用 |
| **性能** | 避免在方法中执行耗时操作 |

#### 常见场景

**场景1：多选模式拦截返回**
```typescript
onBackPress(): boolean {
  if (this.isMultiSelectMode) {
    this.exitMultiSelectMode()
    return true  // 退出多选模式，不退出应用
  }
  return false  // 普通模式，正常退出应用
}
```

**场景2：编辑模式拦截返回**
```typescript
onBackPress(): boolean {
  if (this.isEditing) {
    // 显示确认对话框
    this.showExitConfirmDialog()
    return true  // 拦截返回，等待用户确认
  }
  return false
}
```

**场景3：表单未保存拦截返回**
```typescript
onBackPress(): boolean {
  if (this.hasUnsavedChanges) {
    this.showSaveDialog()
    return true  // 拦截返回，提示保存
  }
  return false
}
```

---

## List组件点击事件绑定规范

> ✅ **已验证**: 2026-01-10 (PollenForecast 项目)
> **场景**: 省份分组点击无法展开
> **问题**: onClick 事件不触发
> **根本原因**: ListItem 组件会拦截其内部子组件的点击事件
> **来源**: 小艺 AI + CodeGenie + 小米MIMO（三专家共识）

### 核心问题

**ArkUI 规则**: `ListItem` 组件会拦截其内部子组件的点击事件。

**❌ 错误写法**:
```typescript
ListItem() {
  Row() {
    Text(group.title)
    Text(group.isExpanded ? '▼' : '▶')
  }
  .onClick(() => {  // ❌ 不触发！
    this.toggleGroup(group.key)
  })
}
```

**✅ 正确写法**:
```typescript
ListItem() {
  Row() {
    Text(group.title)
    Text(group.isExpanded ? '▼' : '▶')
  }
  .width('100%')
  .height(40)
  .padding({ left: 16, right: 16 })
}
.onClick(() => {  // ✅ 正常触发
  console.info(`[点击生效] ${group.title}`)
  this.toggleGroup(group.key)
})
```

### 关键改动点

1. **事件绑定位置**: 从 `Row` 组件移到 `ListItem` 结束后的 `.onClick()`
2. **样式属性**: 保留在 `Row` 上（width、height、padding、backgroundColor）
3. **嵌套结构**: `ListItem().onClick()` 而非 `Row().onClick()`

### 状态管理优化

#### Set 类型问题（有争议）

**两专家观点**:
- **小艺 AI + CodeGenie**: `@State` 装饰的 `Set` 类型在 ArkUI 中无法正确触发 UI 更新
- **小米MIMO**: Set 的 add/delete 方法会触发 ArkUI 响应式更新

**建议方案（保险起见）**: 改用数组

```typescript
// 原代码（Set方式）
@State expandedGroups: Set<string> = new Set()

toggleGroup(groupKey: string): void {
  if (this.expandedGroups.has(groupKey)) {
    this.expandedGroups.delete(groupKey)
  } else {
    this.expandedGroups.add(groupKey)
  }
}

// 判断展开状态
isExpanded: this.expandedGroups.has(group.key)
```

**改用数组（推荐）**:
```typescript
@State expandedKeys: string[] = []

toggleGroup(groupKey: string): void {
  if (this.expandedKeys.includes(groupKey)) {
    // ✅ 使用 filter 创建新数组触发更新
    this.expandedKeys = this.expandedKeys.filter(k => k !== groupKey)
  } else {
    // ✅ 使用扩展运算符创建新数组
    this.expandedKeys = [...this.expandedKeys, groupKey]
  }
}

// 判断展开状态
isExpanded: this.expandedKeys.includes(group.key)
```

**注意事项**:
- ❌ **错误**: `this.expandedKeys.push(newKey)` (直接修改原数组)
- ✅ **正确**: `this.expandedKeys = [...this.expandedKeys, newKey]` (创建新数组)

### 完整修正代码示例

```typescript
List({ scroller: this.scroller }) {
  ForEach(this.getGroupedCities(), (group: CityGroup) => {
    
    // ========== 省份标题 ==========
    if (this.displayMode === 'province') {
      ListItem() {
        Row() {
          Text(group.title)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(group.isExpanded ? '▼' : '▶')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.card_background'))
      }
      // ⚠️ 关键: onClick 绑定在 ListItem 上
      .onClick(() => {
        console.info(`[点击生效] ${group.title}, key: ${group.key}`)
        this.toggleGroup(group.key)
      })
    }
    
    // ========== 城市列表 ==========
    if (this.displayMode !== 'province' || group.isExpanded) {
      ForEach(group.cities, (city: CityItem) => {
        ListItem() {
          this.CityItemComponent(city)
        }
      }, (city: CityItem) => city.name)
    }
    
  }, (group: CityGroup) => group.key)
}
```

### 最佳实践总结

| 规范项 | 错误写法 | 正确写法 |
|---------|---------|----------|
| **事件绑定位置** | `Row().onClick()` | `ListItem().onClick()` |
| **状态类型** | `@State expandedGroups: Set<string>` | `@State expandedKeys: string[]` (建议) |
| **数组更新** | `arr.push(item)` | `arr = [...arr, item]` |
| **条件渲染** | 嵌套 3 层以上 | 使用 `@Builder` 拆分 |
| **唯一键** | `ForEach(arr, ...)` | `ForEach(arr, ..., item => item.id)` |

### 专家观点分析

| 问题 | 小艺 AI | CodeGenie | 小米MIMO |
|------|---------|-----------|----------|
| **事件绑定位置** | ✅ ListItem | ✅ ListItem | ✅ ListItem |
| **Set 类型问题** | ❌ 不触发更新 | ❌ 不触发更新 | ✅ 会触发更新 |
| **建议方案** | 改用数组 | 改用数组 | 保持 Set |

**共识结论**:
1. ✅ **100% 确认**: 事件绑定位置错误是根本原因
2. ⚠️ **有争议**: Set 类型是否能正常工作（建议先修复事件绑定，如果仍有问题再改用数组）

### 实施优先级

| 优先级 | 任务 | 预估时间 | 状态 |
|---------|------|----------|------|
| **P0** | 修正 onClick 绑定位置 | 5分钟 | ⏳ 待实施 |
| **P1** | 验证功能是否正常 | 5分钟 | ⏳ 待验证 |
| **P2** | (如果需要)改用数组管理状态 | 10分钟 | ⏳ 备选 |

---

## 城市名格式匹配问题（getCityWithDistricts）

> ⏳ **待验证**: 2026-01-14  
> **场景**: 城市名查询匹配失败  
> **问题**: 不同数据源的城市名格式不一致  
> **来源**: 小米MIMO + 豆包 + CodeGenie + 小艺（四专家共识）

### 问题根因

| 数据源 | 城市名格式 | 来源 |
|-------|-----------|------|
| `this.cityList` | `"浙江省, 杭州市"` | 页面展示数据（26个热门城市） |
| `this.allCitiesData` | `"杭州市"` | JSON加载的完整数据（369个城市） |

**匹配失败可能原因**:
1. 数据中存在空格（`"杭州市 "` vs `"杭州市"`）
2. 全角/半角字符混用
3. 重复后缀（`"杭州市市"`）
4. 异步加载时机问题

### 解决方案：增强匹配逻辑（豆包方案，最全面）

```typescript
export function getCityWithDistricts(cities: CityItem[], cityName: string): CityItem | null {
  if (!cities || cities.length === 0 || !cityName) {
    console.error(`[getCityWithDistricts] 入参无效`)
    return null
  }

  // 预处理：去空格、全角转半角、转小写
  const processedQueryName = cityName
    .trim() // 🔥 关键：去除空格
    .replace(/[\uFF01-\uFF5E]/g, (ch) => String.fromCharCode(ch.charCodeAt(0) - 65248))
    .toLowerCase()

  // 1. 精确匹配
  for (const city of cities) {
    const processedCityName = city.name
      .trim()
      .replace(/[\uFF01-\uFF5E]/g, (ch) => String.fromCharCode(ch.charCodeAt(0) - 65248))
      .toLowerCase()
    if (processedCityName === processedQueryName) return city
  }

  // 2. 模糊匹配：去除行政区划后缀
  const suffixes = ['市', '地区', '自治州', '盟', '自治县', '县', '区']
  let normalizedSearchName = processedQueryName
  suffixes.forEach(suffix => {
    if (normalizedSearchName.endsWith(suffix)) {
      normalizedSearchName = normalizedSearchName.slice(0, -suffix.length)
    }
  })

  for (const city of cities) {
    let normalizedCityName = city.name.trim().toLowerCase()
    suffixes.forEach(suffix => {
      if (normalizedCityName.endsWith(suffix)) {
        normalizedCityName = normalizedCityName.slice(0, -suffix.length)
      }
    })
    if (normalizedCityName === normalizedSearchName || normalizedCityName.includes(normalizedSearchName)) {
      return city
    }
  }

  // 3. 兜底日志
  console.warn(`[getCityWithDistricts] 未找到匹配城市：${cityName}`)
  console.warn(`[getCityWithDistricts] 示例城市：${cities.slice(0, 3).map(c => c.name).join(', ')}`)
  return null
}
```

### 调试方法（小艺建议）

```typescript
selectCity(cityName: string): void {
  console.info(`[RegionView] 选择城市: ${cityName}`)
  console.info(`[RegionView] allCitiesData 长度: ${this.allCitiesData.length}`)
  
  // 打印前5个城市名，验证数据格式
  if (this.allCitiesData.length > 0) {
    const names = this.allCitiesData.slice(0, 5).map(c => c.name).join(', ')
    console.info(`[RegionView] 前5个城市名: ${names}`)
  }
  
  // 检查完全匹配
  const exactMatch = this.allCitiesData.find(city => city.name === cityName)
  console.info(`[RegionView] 完全匹配 "${cityName}": ${exactMatch ? '找到' : '未找到'}`)
  
  const cityData = getCityWithDistricts(this.allCitiesData, cityName)
  console.info(`[RegionView] getCityWithDistricts 返回: ${cityData ? '有数据' : '无数据'}`)
}
```

### 响应式更新注意（豆包提醒）

```typescript
async loadCityData() {
  try {
    const allCitiesWithDistricts = await loadChinaAreaData(getContext(this))
    // 🔥 关键：创建新数组，触发响应式更新
    this.allCitiesData = [...allCitiesWithDistricts]
    
    // 验证查询
    const testCity = getCityWithDistricts(this.allCitiesData, '杭州市')
    console.info(`[RegionView] 测试查询杭州市：${testCity ? '成功' : '失败'}`)
  } catch (e) {
    console.error(`[RegionView] 加载失败：${e}`)
    this.allCitiesData = []
  }
}
```

### 四专家共识度

| 诊断点 | 小米MIMO | CodeGenie | 豆包 | 小艺 | 共识度 |
|-------|---------|-----------|------|------|--------|
| 数据加载成功 | ✅ | ✅ | ✅ | ✅ | 100% |
| 根本原因：城市名格式不匹配 | ✅ | ✅ | ✅ | ✅ | 100% |
| 空格/特殊字符问题 | ⚠️ 未提及 | ⚠️ 未提及 | ✅ **重点强调** | ✅ | 50% |
| 需要添加调试日志 | ✅ | ✅ | ✅ | ✅ **最详细** | 100% |
| 响应式更新问题 | ⚠️ 未提及 | ⚠️ 未提及 | ✅ | ⚠️ 未提及 | 25% |

---

## 🔗 相关主题

- **UI组件** → [UI组件.md](./UI组件.md)
- **Native集成** → [Native集成.md](./Native集成.md)
- **完整知识库** → [知识库_完整版_20251226.md](../知识库_完整版_20251226.md)

