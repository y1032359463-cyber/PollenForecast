import { useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Cell } from 'recharts';
import { Clock, BarChart3, User, TrendingUp } from 'lucide-react';

const weeklyData = [
  { day: '周一', hours: 8.5 },
  { day: '周二', hours: 7.2 },
  { day: '周三', hours: 9.1 },
  { day: '周四', hours: 6.8 },
  { day: '周五', hours: 8.0 },
  { day: '周六', hours: 4.5 },
  { day: '周日', hours: 3.2 },
];

export default function App() {
  const [selectedPeriod, setSelectedPeriod] = useState('月');
  const [activeTab, setActiveTab] = useState('统计');

  return (
    <div 
      className="min-h-screen"
      style={{ 
        maxWidth: '360px', 
        margin: '0 auto',
        backgroundColor: '#F8F9FA',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}
    >
      {/* Header */}
      <div 
        className="flex items-center"
        style={{
          height: '56px',
          backgroundColor: 'white',
          padding: '0 16px'
        }}
      >
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#212121' }}>
          统计
        </h1>
      </div>

      {/* Period Selector */}
      <div style={{ padding: '0 16px', marginTop: '16px' }}>
        <div 
          className="flex gap-1 p-2 rounded-2xl"
          style={{ backgroundColor: '#F5F5F5' }}
        >
          {['周', '月', '年'].map((period) => (
            <button
              key={period}
              onClick={() => setSelectedPeriod(period)}
              className="flex-1 rounded-2xl transition-all"
              style={{
                height: '32px',
                backgroundColor: selectedPeriod === period ? '#2196F3' : 'transparent',
                color: selectedPeriod === period ? 'white' : '#757575',
                fontSize: '14px',
                fontWeight: '500',
                border: 'none',
                cursor: 'pointer'
              }}
            >
              {period}
            </button>
          ))}
        </div>
      </div>

      {/* Time Overview Card */}
      <div style={{ padding: '0 16px', marginTop: '16px' }}>
        <div 
          className="rounded-xl"
          style={{
            backgroundColor: 'white',
            padding: '20px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
          }}
        >
          <div style={{ fontSize: '48px', fontWeight: 'bold', color: '#2196F3', lineHeight: '1' }}>
            128
          </div>
          <div style={{ fontSize: '16px', color: '#757575', marginTop: '8px' }}>
            小时
          </div>
          <div style={{ fontSize: '14px', color: '#9E9E9E', marginTop: '4px' }}>
            本月统计
          </div>
          <div className="flex items-center gap-1" style={{ marginTop: '12px' }}>
            <TrendingUp size={12} color="#4CAF50" />
            <span style={{ fontSize: '12px', color: '#4CAF50' }}>
              比上月增长 12%
            </span>
          </div>
        </div>
      </div>

      {/* Stats Cards Grid */}
      <div style={{ padding: '0 16px', marginTop: '16px' }}>
        <div 
          className="grid grid-cols-2 gap-4"
        >
          {/* Card 1: Total Earned */}
          <div 
            className="rounded-xl"
            style={{
              backgroundColor: 'white',
              padding: '16px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div style={{ fontSize: '32px', lineHeight: '1', marginBottom: '8px' }}>
              💰
            </div>
            <div style={{ fontSize: '14px', color: '#757575', marginBottom: '4px' }}>
              总收入
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#212121' }}>
              ¥3,840
            </div>
          </div>

          {/* Card 2: Days Worked */}
          <div 
            className="rounded-xl"
            style={{
              backgroundColor: 'white',
              padding: '16px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div style={{ fontSize: '32px', lineHeight: '1', marginBottom: '8px' }}>
              📅
            </div>
            <div style={{ fontSize: '14px', color: '#757575', marginBottom: '4px' }}>
              工作天数
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#212121' }}>
              18
            </div>
          </div>

          {/* Card 3: Avg per Day */}
          <div 
            className="rounded-xl"
            style={{
              backgroundColor: 'white',
              padding: '16px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div style={{ fontSize: '32px', lineHeight: '1', marginBottom: '8px' }}>
              ⏱
            </div>
            <div style={{ fontSize: '14px', color: '#757575', marginBottom: '4px' }}>
              日均时长
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#212121' }}>
              7.1 hrs
            </div>
          </div>

          {/* Card 4: Hourly Wage */}
          <div 
            className="rounded-xl"
            style={{
              backgroundColor: 'white',
              padding: '16px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div style={{ fontSize: '32px', lineHeight: '1', marginBottom: '8px' }}>
              💵
            </div>
            <div style={{ fontSize: '14px', color: '#757575', marginBottom: '4px' }}>
              时薪
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#212121' }}>
              ¥30/hr
            </div>
          </div>
        </div>
      </div>

      {/* Chart Section */}
      <div style={{ padding: '0 16px', marginTop: '16px', marginBottom: '72px' }}>
        <div 
          className="rounded-xl"
          style={{
            backgroundColor: 'white',
            padding: '20px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
          }}
        >
          <h2 style={{ fontSize: '18px', fontWeight: 'bold', color: '#212121', marginBottom: '16px' }}>
            每周趋势
          </h2>
          
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={weeklyData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
              <XAxis 
                dataKey="day" 
                axisLine={false}
                tickLine={false}
                tick={{ fill: '#9E9E9E', fontSize: 12 }}
              />
              <YAxis 
                axisLine={false}
                tickLine={false}
                tick={{ fill: '#9E9E9E', fontSize: 12 }}
                ticks={[0, 2, 4, 6, 8, 10]}
                domain={[0, 10]}
              />
              <Bar 
                dataKey="hours" 
                radius={[4, 4, 0, 0]}
                maxBarSize={32}
              >
                {weeklyData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill="#2196F3" />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div 
        className="fixed bottom-0 left-0 right-0 flex"
        style={{
          maxWidth: '360px',
          margin: '0 auto',
          height: '56px',
          backgroundColor: 'white',
          borderTop: '1px solid #E0E0E0'
        }}
      >
        {/* Time Log Tab */}
        <button
          onClick={() => setActiveTab('时间')}
          className="flex-1 flex flex-col items-center justify-center gap-1"
          style={{
            border: 'none',
            backgroundColor: 'transparent',
            cursor: 'pointer',
            color: activeTab === '时间' ? '#2196F3' : '#9E9E9E'
          }}
        >
          <Clock size={20} />
          <span style={{ fontSize: '11px' }}>时间记录</span>
        </button>

        {/* Statistics Tab */}
        <button
          onClick={() => setActiveTab('统计')}
          className="flex-1 flex flex-col items-center justify-center gap-1"
          style={{
            border: 'none',
            backgroundColor: 'transparent',
            cursor: 'pointer',
            color: activeTab === '统计' ? '#2196F3' : '#9E9E9E'
          }}
        >
          <BarChart3 size={20} />
          <span style={{ fontSize: '11px' }}>统计</span>
        </button>

        {/* Profile Tab */}
        <button
          onClick={() => setActiveTab('个人')}
          className="flex-1 flex flex-col items-center justify-center gap-1"
          style={{
            border: 'none',
            backgroundColor: 'transparent',
            cursor: 'pointer',
            color: activeTab === '个人' ? '#2196F3' : '#9E9E9E'
          }}
        >
          <User size={20} />
          <span style={{ fontSize: '11px' }}>个人</span>
        </button>
      </div>
    </div>
  );
}
