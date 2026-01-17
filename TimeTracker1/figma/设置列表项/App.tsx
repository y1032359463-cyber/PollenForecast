import React from 'react';
import { SettingsListItem } from './components/SettingsListItem';

export default function App() {
  const settingsItems = [
    {
      icon: '💵',
      label: '时薪',
      value: '¥30/小时'
    },
    {
      icon: '📅',
      label: '工作周期',
      value: '每周'
    },
    {
      icon: '🎨',
      label: '主题',
      value: '自动'
    },
    {
      icon: '💾',
      label: '备份数据',
      value: undefined
    },
    {
      icon: '📱',
      label: '关于',
      value: 'v1.0.0'
    },
    {
      icon: '⚙️',
      label: '高级设置',
      value: undefined
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8F8F8] flex items-center justify-center p-6">
      <div className="flex flex-col gap-3">
        {/* Title */}
        <h1 className="text-[#212121] mb-3" style={{ fontSize: '24px', fontWeight: 600 }}>
          设置
        </h1>
        
        {/* Settings List */}
        <div className="flex flex-col gap-3">
          {settingsItems.map((item, index) => (
            <SettingsListItem
              key={index}
              icon={item.icon}
              label={item.label}
              value={item.value}
              onClick={() => console.log(`Clicked: ${item.label}`)}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
