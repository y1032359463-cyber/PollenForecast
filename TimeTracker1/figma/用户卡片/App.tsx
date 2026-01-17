import { UserProfileCard } from "./components/user-profile-card";

export default function App() {
  return (
    <div className="flex flex-col items-center" style={{ gap: "32px" }}>
      <h1 style={{ marginBottom: "8px" }}>用户资料卡片组件</h1>
      
      {/* Variant 1: Default */}
      <div className="flex flex-col items-center" style={{ gap: "12px" }}>
        <p style={{ color: "#666", fontSize: "14px" }}>默认样式</p>
        <UserProfileCard
          name="User Name"
          role="Hourly Worker"
          memberSince="Since Nov 2025"
        />
      </div>

      {/* Variant 2: Long name */}
      <div className="flex flex-col items-center" style={{ gap: "12px" }}>
        <p style={{ color: "#666", fontSize: "14px" }}>长名字</p>
        <UserProfileCard
          name="王小明"
          role="自由职业者"
          memberSince="2025年1月起"
        />
      </div>

      {/* Variant 3: VIP user */}
      <div className="flex flex-col items-center" style={{ gap: "12px" }}>
        <p style={{ color: "#666", fontSize: "14px" }}>VIP用户</p>
        <UserProfileCard
          name="John Doe"
          role="VIP会员 ⭐"
          memberSince="2024年10月起"
        />
      </div>
    </div>
  );
}
