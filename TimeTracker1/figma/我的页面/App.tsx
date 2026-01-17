import { UserCard } from "./components/UserCard";
import { SettingsListItem } from "./components/SettingsListItem";
import { VIPBanner } from "./components/VIPBanner";
import { BottomNavigation } from "./components/BottomNavigation";
import { DollarSign, Calendar, Palette, HardDrive, Smartphone, Settings } from "lucide-react";

export default function App() {
  return (
    <div className="w-full min-h-screen" style={{ backgroundColor: '#F8F9FA', maxWidth: '360px', margin: '0 auto', height: '812px', overflow: 'hidden' }}>
      {/* Header Section - 56px height */}
      <header className="bg-white" style={{ height: '56px', padding: '0 16px', display: 'flex', alignItems: 'center' }}>
        <h1 style={{ fontSize: '24px', fontWeight: '700', color: '#212121', margin: 0 }}>个人中心</h1>
      </header>

      {/* Scrollable Content Area */}
      <div style={{ height: 'calc(812px - 56px - 76px)', overflowY: 'auto', overflowX: 'hidden' }}>
        {/* User Card - 140px height + 16px top margin */}
        <div style={{ margin: '16px 16px 0 16px' }}>
          <UserCard />
        </div>

        {/* Settings List Section */}
        <div style={{ margin: '0 16px', marginTop: '16px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: '700', color: '#212121', margin: '16px 0 12px 0' }}>设置</h2>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <SettingsListItem
              icon={<DollarSign size={24} color="#757575" />}
              label="时薪设置"
              value="¥30/小时"
            />
            <SettingsListItem
              icon={<Calendar size={24} color="#757575" />}
              label="考勤周期"
              value="每周"
            />
            <SettingsListItem
              icon={<Palette size={24} color="#757575" />}
              label="主题设置"
              value="跟随系统"
            />
            <SettingsListItem
              icon={<HardDrive size={24} color="#757575" />}
              label="数据备份"
            />
            <SettingsListItem
              icon={<Smartphone size={24} color="#757575" />}
              label="关于应用"
              value="v1.0.0"
            />
            <SettingsListItem
              icon={<Settings size={24} color="#757575" />}
              label="高级设置"
            />
          </div>
        </div>

        {/* VIP Banner - 80px height + margins */}
        <div style={{ margin: '16px 16px 0 16px' }}>
          <VIPBanner />
        </div>

        {/* Extra bottom spacing */}
        <div style={{ height: '16px' }} />
      </div>

      {/* Bottom Navigation - 76px total (56px nav + 20px safe area) */}
      <BottomNavigation activeTab="profile" />
    </div>
  );
}
