import { useState, useEffect } from 'react';
import { 
  X, 
  Check, 
  Clock, 
  Calendar, 
  Briefcase,
  Code,
  Pen,
  Bug,
  Users,
  FileText,
  BookOpen,
  Search,
  MessageCircle,
  MoreHorizontal
} from 'lucide-react';
import { Button } from './components/ui/button';
import { Input } from './components/ui/input';

type ProjectType = {
  id: string;
  name: string;
  icon: React.ReactNode;
  color: string;
};

const projectTypes: ProjectType[] = [
  { id: 'dev', name: '开发', icon: <Code strokeWidth={2} />, color: '#2196F3' },
  { id: 'design', name: '设计', icon: <Pen strokeWidth={2} />, color: '#9C27B0' },
  { id: 'test', name: '测试', icon: <Bug strokeWidth={2} />, color: '#F44336' },
  { id: 'meeting', name: '会议', icon: <Users strokeWidth={2} />, color: '#FF9800' },
  { id: 'doc', name: '文档', icon: <FileText strokeWidth={2} />, color: '#4CAF50' },
  { id: 'study', name: '学习', icon: <BookOpen strokeWidth={2} />, color: '#00BCD4' },
  { id: 'research', name: '调研', icon: <Search strokeWidth={2} />, color: '#795548' },
  { id: 'comm', name: '沟通', icon: <MessageCircle strokeWidth={2} />, color: '#E91E63' },
  { id: 'other', name: '其他', icon: <MoreHorizontal strokeWidth={2} />, color: '#9E9E9E' },
];

export default function App() {
  const [startTime, setStartTime] = useState('');
  const [endTime, setEndTime] = useState('');
  const [duration, setDuration] = useState({ hours: 0, minutes: 0 });
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [selectedProjectType, setSelectedProjectType] = useState('');
  const [projectName, setProjectName] = useState('');
  const [hourlyRate, setHourlyRate] = useState(30);
  const [showStartTimePicker, setShowStartTimePicker] = useState(false);
  const [showEndTimePicker, setShowEndTimePicker] = useState(false);

  // Calculate duration
  useEffect(() => {
    if (!startTime || !endTime) {
      setDuration({ hours: 0, minutes: 0 });
      return;
    }
    
    const start = parseTime(startTime);
    const end = parseTime(endTime);
    
    let minutes = (end.hours * 60 + end.minutes) - (start.hours * 60 + start.minutes);
    if (minutes < 0) minutes += 24 * 60;
    
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    
    setDuration({ hours, minutes: mins });
  }, [startTime, endTime]);

  const parseTime = (time: string) => {
    const [hours, minutes] = time.split(':').map(Number);
    return { hours, minutes };
  };

  const formatTime = (time: string) => {
    if (!time) return '选择时间';
    const [hours, minutes] = time.split(':');
    const hour = parseInt(hours);
    const period = hour >= 12 ? '下午' : '上午';
    const displayHour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return `${displayHour}:${minutes} ${period}`;
  };

  const formatDate = (date: Date) => {
    const today = new Date();
    const isToday = date.toDateString() === today.toDateString();
    
    if (isToday) {
      return '今天, 11月14日, 2025';
    }
    
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const year = date.getFullYear();
    return `${year}年${month}月${day}日`;
  };

  const handleSave = () => {
    console.log('保存工作记录:', {
      startTime,
      endTime,
      duration,
      date: selectedDate,
      projectType: selectedProjectType,
      projectName,
      hourlyRate
    });
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4" style={{ backgroundColor: '#F5F5F5' }}>
      <div 
        className="w-full bg-white overflow-hidden flex flex-col"
        style={{ 
          maxWidth: '360px', 
          height: '780px',
          borderRadius: '24px',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.12)'
        }}
      >
        {/* Top Bar - 56px */}
        <div 
          className="flex items-center justify-between px-2 shrink-0"
          style={{ height: '56px', borderBottom: '1px solid #E0E0E0' }}
        >
          <button 
            className="flex items-center justify-center rounded-full hover:bg-gray-100 transition-colors"
            style={{ width: '44px', height: '44px' }}
            aria-label="关闭"
          >
            <X style={{ width: '24px', height: '24px', color: '#757575', strokeWidth: 2 }} />
          </button>
          <h1 style={{ fontSize: '18px', fontWeight: 700, color: '#212121' }}>
            添加工时记录
          </h1>
          <button 
            onClick={handleSave}
            className="flex items-center justify-center rounded-full transition-all active:scale-95"
            style={{ 
              width: '44px', 
              height: '44px',
              backgroundColor: '#2196F3'
            }}
            aria-label="保存"
          >
            <Check style={{ width: '24px', height: '24px', color: '#FFFFFF', strokeWidth: 2.5 }} />
          </button>
        </div>

        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto">
          {/* Time Duration Display - 100px */}
          <div 
            className="px-6 text-center"
            style={{ height: '100px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}
          >
            <div style={{ fontSize: '40px', fontWeight: 700, color: '#212121', lineHeight: '48px' }}>
              {duration.hours}小时 {duration.minutes}分钟
            </div>
            <p style={{ fontSize: '14px', color: '#757575', marginTop: '8px' }}>
              工作时长
            </p>
          </div>

          {/* Time Picker Section - ~160px */}
          <div 
            className="mx-4 mb-4 p-4"
            style={{ backgroundColor: '#F8F9FA', borderRadius: '12px' }}
          >
            <h2 style={{ fontSize: '14px', fontWeight: 500, color: '#757575', marginBottom: '16px' }}>
              时间选择
            </h2>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {/* Start Time Row - 48px */}
              <button
                onClick={() => setShowStartTimePicker(!showStartTimePicker)}
                className="w-full flex items-center justify-between transition-colors rounded-lg hover:bg-white"
                style={{ 
                  height: '48px',
                  padding: '0 12px',
                  backgroundColor: '#FFFFFF'
                }}
              >
                <div className="flex items-center" style={{ gap: '12px' }}>
                  <Clock style={{ width: '20px', height: '20px', color: '#2196F3', strokeWidth: 2 }} />
                  <span style={{ fontSize: '16px', color: '#212121' }}>开始时间</span>
                </div>
                <span style={{ fontSize: '16px', color: startTime ? '#2196F3' : '#BDBDBD' }}>
                  {formatTime(startTime)}
                </span>
              </button>

              {showStartTimePicker && (
                <div style={{ padding: '8px' }}>
                  <input
                    type="time"
                    value={startTime}
                    onChange={(e) => {
                      setStartTime(e.target.value);
                      setShowStartTimePicker(false);
                    }}
                    className="w-full px-3 py-2 rounded-lg"
                    style={{ 
                      fontSize: '16px',
                      backgroundColor: '#F5F5F5', 
                      border: '1px solid #E0E0E0', 
                      color: '#212121' 
                    }}
                  />
                </div>
              )}

              {/* End Time Row - 48px */}
              <button
                onClick={() => setShowEndTimePicker(!showEndTimePicker)}
                className="w-full flex items-center justify-between transition-colors rounded-lg hover:bg-white"
                style={{ 
                  height: '48px',
                  padding: '0 12px',
                  backgroundColor: '#FFFFFF'
                }}
              >
                <div className="flex items-center" style={{ gap: '12px' }}>
                  <Clock style={{ width: '20px', height: '20px', color: '#2196F3', strokeWidth: 2 }} />
                  <span style={{ fontSize: '16px', color: '#212121' }}>结束时间</span>
                </div>
                <span style={{ fontSize: '16px', color: endTime ? '#2196F3' : '#BDBDBD' }}>
                  {formatTime(endTime)}
                </span>
              </button>

              {showEndTimePicker && (
                <div style={{ padding: '8px' }}>
                  <input
                    type="time"
                    value={endTime}
                    onChange={(e) => {
                      setEndTime(e.target.value);
                      setShowEndTimePicker(false);
                    }}
                    className="w-full px-3 py-2 rounded-lg"
                    style={{ 
                      fontSize: '16px',
                      backgroundColor: '#F5F5F5', 
                      border: '1px solid #E0E0E0', 
                      color: '#212121' 
                    }}
                  />
                </div>
              )}

              {/* Duration Result */}
              <div 
                className="text-center rounded-lg"
                style={{ 
                  padding: '8px',
                  backgroundColor: '#E3F2FD',
                  marginTop: '8px'
                }}
              >
                <span style={{ fontSize: '14px', color: '#2196F3' }}>
                  时长: {duration.hours}小时 {duration.minutes}分钟
                </span>
              </div>
            </div>
          </div>

          {/* Date Picker - ~56px */}
          <div className="px-4 mb-4">
            <h2 style={{ fontSize: '14px', fontWeight: 500, color: '#757575', marginBottom: '8px' }}>
              日期
            </h2>
            <button 
              className="w-full flex items-center transition-colors rounded-lg hover:opacity-80"
              style={{ 
                height: '48px',
                padding: '0 12px',
                backgroundColor: '#F5F5F5',
                gap: '12px'
              }}
            >
              <Calendar style={{ width: '20px', height: '20px', color: '#2196F3', strokeWidth: 2 }} />
              <span style={{ fontSize: '16px', color: '#212121' }}>
                {formatDate(selectedDate)}
              </span>
            </button>
          </div>

          {/* Work Details Section - ~280px */}
          <div className="px-4 mb-4">
            <h2 style={{ fontSize: '14px', fontWeight: 500, color: '#757575', marginBottom: '16px' }}>
              工作详情
            </h2>
            
            {/* Project Type Grid - 3x3 with 9 items */}
            <div 
              style={{ 
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: '12px',
                marginBottom: '12px'
              }}
            >
              {projectTypes.map((type) => (
                <button
                  key={type.id}
                  onClick={() => setSelectedProjectType(type.id)}
                  className="flex flex-col items-center justify-center transition-all"
                  style={{
                    width: '100%',
                    height: '60px',
                    backgroundColor: '#F5F5F5',
                    border: selectedProjectType === type.id 
                      ? '2px solid #2196F3' 
                      : '2px solid transparent',
                    borderRadius: '12px',
                    padding: '8px'
                  }}
                >
                  <div style={{ color: type.color, width: '24px', height: '24px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    {type.icon}
                  </div>
                  <span style={{ fontSize: '12px', color: '#757575', marginTop: '4px', textAlign: 'center' }}>
                    {type.name}
                  </span>
                </button>
              ))}
            </div>

            {/* Project Name Field - 48px */}
            <div className="relative" style={{ marginTop: '16px' }}>
              <Briefcase 
                className="absolute top-1/2" 
                style={{ 
                  left: '12px',
                  transform: 'translateY(-50%)',
                  width: '20px', 
                  height: '20px', 
                  color: '#757575',
                  strokeWidth: 2
                }} 
              />
              <Input
                type="text"
                placeholder="项目名称"
                value={projectName}
                onChange={(e) => setProjectName(e.target.value)}
                className="w-full border-0 focus-visible:ring-2"
                style={{ 
                  height: '48px',
                  paddingLeft: '44px',
                  paddingRight: '12px',
                  fontSize: '16px',
                  backgroundColor: '#F5F5F5', 
                  color: '#212121',
                  borderRadius: '8px',
                  '--tw-ring-color': '#2196F3'
                } as React.CSSProperties}
              />
            </div>

            {/* Hourly Rate Field - 48px */}
            <div className="relative" style={{ marginTop: '8px' }}>
              <span 
                className="absolute top-1/2"
                style={{ 
                  left: '12px',
                  transform: 'translateY(-50%)',
                  fontSize: '20px', 
                  color: '#757575',
                  fontWeight: 400
                }}
              >
                ¥
              </span>
              <Input
                type="number"
                value={hourlyRate}
                onChange={(e) => setHourlyRate(Number(e.target.value))}
                className="w-full border-0 focus-visible:ring-2"
                style={{ 
                  height: '48px',
                  paddingLeft: '32px',
                  paddingRight: '60px',
                  fontSize: '16px',
                  backgroundColor: '#F5F5F5', 
                  color: '#212121',
                  borderRadius: '8px',
                  '--tw-ring-color': '#2196F3'
                } as React.CSSProperties}
              />
              <span 
                className="absolute top-1/2"
                style={{ 
                  right: '12px',
                  transform: 'translateY(-50%)',
                  fontSize: '16px', 
                  color: '#757575' 
                }}
              >
                /小时
              </span>
            </div>
          </div>

          {/* Spacer */}
          <div style={{ height: '16px' }}></div>
        </div>

        {/* Bottom Action Area - 96px total (48px button + 28px padding + 20px safe area) */}
        <div 
          className="shrink-0"
          style={{ 
            height: '96px',
            borderTop: '1px solid #E0E0E0',
            backgroundColor: '#FFFFFF',
            display: 'flex',
            flexDirection: 'column'
          }}
        >
          <div style={{ padding: '16px 16px 0 16px' }}>
            <Button 
              onClick={handleSave}
              className="w-full transition-all active:scale-[0.98]"
              style={{ 
                height: '48px',
                backgroundColor: '#2196F3',
                color: '#FFFFFF',
                fontSize: '16px',
                fontWeight: 500,
                borderRadius: '8px',
                boxShadow: '0 2px 8px rgba(33, 150, 243, 0.3)',
                border: 'none'
              }}
            >
              保存工作记录
            </Button>
          </div>
          {/* Safe area spacer for HarmonyOS gesture navigation - 20px + 12px padding */}
          <div style={{ height: '32px' }}></div>
        </div>
      </div>
    </div>
  );
}
