import React from 'react';
import { WorkSessionListItem, WorkSession } from './components/WorkSessionListItem';
import { Clock, Calendar, TrendingUp } from 'lucide-react';

const sampleSessions: WorkSession[] = [
  {
    id: '1',
    date: 14,
    weekday: '周四',
    duration: '8h 30m',
    startTime: '09:00',
    endTime: '17:30',
    project: '项目 ABC',
    earnings: 255,
  },
  {
    id: '2',
    date: 13,
    weekday: '周三',
    duration: '7h 15m',
    startTime: '09:30',
    endTime: '16:45',
    project: '客户支持',
    earnings: 217.5,
  },
  {
    id: '3',
    date: 12,
    weekday: '周二',
    duration: '9h 0m',
    startTime: '08:00',
    endTime: '17:00',
    earnings: 270,
  },
  {
    id: '4',
    date: 11,
    weekday: '周一',
    duration: '8h 0m',
    startTime: '09:00',
    endTime: '17:00',
    project: '项目 XYZ',
    earnings: 240,
  },
  {
    id: '5',
    date: 10,
    weekday: '周日',
    duration: '5h 30m',
    startTime: '10:00',
    endTime: '15:30',
    project: '加班任务',
    earnings: 165,
  },
  {
    id: '6',
    date: 9,
    weekday: '周六',
    duration: '6h 45m',
    startTime: '09:00',
    endTime: '15:45',
    earnings: 202.5,
  },
  {
    id: '7',
    date: 8,
    weekday: '周五',
    duration: '8h 15m',
    startTime: '09:00',
    endTime: '17:15',
    project: '项目 ABC',
    earnings: 247.5,
  },
];

export default function App() {
  const handleSessionClick = (session: WorkSession) => {
    console.log('工作记录已点击:', session);
    // 在实际应用中，这会打开编辑对话框
  };

  // 计算统计数据
  const totalHours = sampleSessions.reduce((sum, session) => {
    const [hours, minutes] = session.duration.replace('h', '').replace('m', '').split(' ').map(s => parseFloat(s.trim()));
    return sum + hours + (minutes / 60);
  }, 0);
  
  const totalEarnings = sampleSessions.reduce((sum, session) => sum + session.earnings, 0);

  return (
    <div className="min-h-screen" style={{ backgroundColor: '#F8F9FA' }}>
      {/* Header */}
      <div style={{ backgroundColor: '#FFFFFF', borderBottom: '1px solid #E0E0E0' }}>
        <div className="max-w-md mx-auto px-4 py-4 flex items-center justify-between">
          <h1 
            style={{ 
              fontSize: '24px',
              fontWeight: '700',
              lineHeight: '1.33',
              color: '#212121'
            }}
          >
            工作记录
          </h1>
          <button 
            className="flex items-center justify-center transition-colors hover:bg-gray-100 active:bg-gray-200"
            style={{ 
              width: '40px',
              height: '40px',
              borderRadius: '8px'
            }}
          >
            <Calendar size={24} style={{ color: '#757575' }} />
          </button>
        </div>
      </div>

      <div className="max-w-md mx-auto">
        {/* Summary Cards */}
        <div className="px-4 py-4" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          {/* Total Hours Card */}
          <div 
            className="p-4"
            style={{ 
              backgroundColor: '#FFFFFF',
              borderRadius: '12px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div className="flex items-center" style={{ gap: '8px', marginBottom: '8px' }}>
              <Clock size={20} style={{ color: '#2196F3' }} />
              <p 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '400',
                  lineHeight: '1.43',
                  color: '#757575'
                }}
              >
                总时长
              </p>
            </div>
            <p 
              style={{ 
                fontSize: '24px',
                fontWeight: '700',
                lineHeight: '1.33',
                color: '#212121'
              }}
            >
              {totalHours.toFixed(1)}h
            </p>
            <p 
              style={{ 
                fontSize: '12px',
                fontWeight: '400',
                lineHeight: '1.33',
                color: '#9E9E9E',
                marginTop: '4px'
              }}
            >
              本周记录
            </p>
          </div>

          {/* Total Earnings Card */}
          <div 
            className="p-4"
            style={{ 
              backgroundColor: '#FFFFFF',
              borderRadius: '12px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)'
            }}
          >
            <div className="flex items-center" style={{ gap: '8px', marginBottom: '8px' }}>
              <TrendingUp size={20} style={{ color: '#4CAF50' }} />
              <p 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '400',
                  lineHeight: '1.43',
                  color: '#757575'
                }}
              >
                总收入
              </p>
            </div>
            <p 
              style={{ 
                fontSize: '24px',
                fontWeight: '700',
                lineHeight: '1.33',
                color: '#212121'
              }}
            >
              ¥{totalEarnings.toFixed(0)}
            </p>
            <p 
              style={{ 
                fontSize: '12px',
                fontWeight: '400',
                lineHeight: '1.33',
                color: '#4CAF50',
                marginTop: '4px'
              }}
            >
              +12% 环比
            </p>
          </div>
        </div>

        {/* Section Header */}
        <div className="px-4 py-3">
          <p 
            style={{ 
              fontSize: '14px',
              fontWeight: '600',
              lineHeight: '1.43',
              color: '#757575',
              textTransform: 'uppercase',
              letterSpacing: '0.5px'
            }}
          >
            最近记录
          </p>
        </div>

        {/* Work Session List */}
        <div style={{ backgroundColor: '#FFFFFF' }}>
          {sampleSessions.map((session) => (
            <WorkSessionListItem
              key={session.id}
              session={session}
              onClick={handleSessionClick}
            />
          ))}
        </div>

        {/* Info Text */}
        <div className="px-4 py-6">
          <p 
            className="text-center"
            style={{ 
              fontSize: '14px',
              fontWeight: '400',
              lineHeight: '1.43',
              color: '#9E9E9E'
            }}
          >
            点击任意记录查看详情或编辑
          </p>
        </div>
      </div>
    </div>
  );
}
