import React, { useState } from 'react';
import { Calendar as CalendarIcon, ChevronLeft, ChevronRight } from 'lucide-react';
import { CalendarCell } from './components/CalendarCell';
import { SummaryCard } from './components/SummaryCard';
import { BottomNav } from './components/BottomNav';

type TabType = 'time' | 'stats' | 'profile';

export default function App() {
  const [activeTab, setActiveTab] = useState<TabType>('time');
  const [selectedDate, setSelectedDate] = useState<number>(13);
  const [currentMonth] = useState('November 2025');

  // Generate calendar data for November 2025
  const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // November 2025 starts on Saturday (day 6), so we need 6 empty cells
  const firstDayOffset = 5; // Friday is index 4, but Nov 1 is Saturday, so 5 empty cells before
  const daysInMonth = 30;
  
  const calendarDates: (number | null)[] = [
    ...Array(firstDayOffset).fill(null),
    ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
  ];

  // Dates with logged data (example)
  const datesWithData = [3, 4, 5, 10, 11, 12, 13, 17, 18, 19, 24, 25, 26];
  
  const today = 13; // Nov 13, 2025

  return (
    <div className="flex flex-col min-h-screen bg-[#F8F9FA]" style={{ maxWidth: '360px', margin: '0 auto', height: '812px' }}>
      {/* Header */}
      <header className="bg-white px-4 flex items-center justify-between" style={{ height: '56px' }}>
        <h1 
          style={{ 
            fontSize: '24px', 
            fontWeight: 700,
            lineHeight: '32px',
            color: '#212121',
          }}
        >
          Time Log
        </h1>
        <button className="p-2 -mr-2">
          <CalendarIcon size={24} style={{ color: '#757575', strokeWidth: 2 }} />
        </button>
      </header>

      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto pb-[76px]">
        {/* Month Selector */}
        <div className="mx-4 mt-4 bg-[#F5F5F5] rounded-[8px] flex items-center justify-between px-4" style={{ height: '48px' }}>
          <button className="p-2 -ml-2">
            <ChevronLeft size={24} style={{ color: '#757575', strokeWidth: 2 }} />
          </button>
          <span 
            style={{ 
              fontSize: '18px', 
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
            }}
          >
            {currentMonth}
          </span>
          <button className="p-2 -mr-2">
            <ChevronRight size={24} style={{ color: '#757575', strokeWidth: 2 }} />
          </button>
        </div>

        {/* Calendar Grid */}
        <div className="p-4">
          {/* Week headers */}
          <div className="grid grid-cols-7 mb-2" style={{ height: '32px' }}>
            {weekDays.map((day) => (
              <div 
                key={day} 
                className="flex items-center justify-center"
                style={{
                  fontSize: '12px',
                  fontWeight: 400,
                  lineHeight: '16px',
                  color: '#757575',
                }}
              >
                {day}
              </div>
            ))}
          </div>

          {/* Calendar dates */}
          <div className="grid grid-cols-7 gap-1">
            {calendarDates.map((date, index) => (
              <CalendarCell
                key={index}
                date={date}
                isToday={date === today}
                isSelected={date === selectedDate}
                hasData={date ? datesWithData.includes(date) : false}
                onClick={() => date && setSelectedDate(date)}
              />
            ))}
          </div>
        </div>

        {/* Summary Card */}
        <SummaryCard
          label="This Month"
          hours="128 hours"
          amount="¥3,840"
        />

        {/* Bottom spacing */}
        <div style={{ height: '24px' }} />
      </div>

      {/* Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />
    </div>
  );
}