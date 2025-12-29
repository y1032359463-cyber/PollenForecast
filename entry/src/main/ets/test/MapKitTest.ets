/**
 * Map Kit API 探测测试
 * 用于确认 API 20 中 Map Kit 的真实可用接口
 */

import { map, mapCommon } from '@kit.MapKit';

// 测试 1: 检查 map 命名空间下有哪些内容
export function testMapNamespace() {
  console.info('[MapKit] map 命名空间类型:', typeof map);
  console.info('[MapKit] map 内容:', JSON.stringify(Object.keys(map)));
}

// 测试 2: 检查 mapCommon 命名空间下有哪些内容
export function testMapCommonNamespace() {
  console.info('[MapKit] mapCommon 命名空间类型:', typeof mapCommon);
  console.info('[MapKit] mapCommon 内容:', JSON.stringify(Object.keys(mapCommon)));
}

// 测试 3: 尝试访问可能的组件名称
export function testPossibleComponents() {
  const possibleNames = [
    'MapComponent',
    'MapView',
    'Map',
    'HWMapComponent',
    'MapController',
    'MapKit'
  ];
  
  possibleNames.forEach(name => {
    try {
      const component = (map as Record<string, unknown>)[name];
      if (component !== undefined) {
        console.info(`[MapKit] ✅ 找到: map.${name}, 类型: ${typeof component}`);
      } else {
        console.info(`[MapKit] ❌ 不存在: map.${name}`);
      }
    } catch (err) {
      console.error(`[MapKit] ⚠️ 访问 map.${name} 出错:`, JSON.stringify(err));
    }
  });
}

// 测试 4: 检查 MapComponentController
export function testMapController() {
  try {
    console.info('[MapKit] MapComponentController 类型:', typeof map.MapComponentController);
  } catch (err) {
    console.error('[MapKit] MapComponentController 不可访问:', JSON.stringify(err));
  }
}
