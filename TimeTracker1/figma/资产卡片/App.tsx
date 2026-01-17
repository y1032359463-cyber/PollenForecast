import { CalendarDayCell } from './components/calendar-day-cell';

export default function App() {
  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: '#F8F9FA',
        padding: '48px 24px',
      }}
    >
      {/* Header */}
      <div style={{ marginBottom: '48px', textAlign: 'center' }}>
        <h1
          style={{
            fontSize: '32px',
            fontWeight: 700,
            lineHeight: '40px',
            color: '#212121',
            marginBottom: '8px',
          }}
        >
          日历日期组件
        </h1>
        <p
          style={{
            fontSize: '16px',
            fontWeight: 400,
            lineHeight: '24px',
            color: '#757575',
          }}
        >
          TimeTracker 应用日历单元格状态展示
        </p>
      </div>

      {/* Component States Grid */}
      <div
        style={{
          maxWidth: '800px',
          margin: '0 auto',
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '32px',
        }}
      >
        {/* State 1: Default */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            padding: '24px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <h3
            style={{
              fontSize: '18px',
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
              marginBottom: '16px',
            }}
          >
            1. 默认状态
          </h3>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <CalendarDayCell date={15} />
          </div>
          <div
            style={{
              marginTop: '12px',
              fontSize: '14px',
              fontWeight: 400,
              lineHeight: '20px',
              color: '#757575',
              textAlign: 'center',
            }}
          >
            白色背景 · 灰色边框
          </div>
        </div>

        {/* State 2: Today */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            padding: '24px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <h3
            style={{
              fontSize: '18px',
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
              marginBottom: '16px',
            }}
          >
            2. 今日状态
          </h3>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <CalendarDayCell date={13} isToday={true} />
          </div>
          <div
            style={{
              marginTop: '12px',
              fontSize: '14px',
              fontWeight: 400,
              lineHeight: '20px',
              color: '#757575',
              textAlign: 'center',
            }}
          >
            蓝色边框 · 蓝色文字
          </div>
        </div>

        {/* State 3: Selected */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            padding: '24px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <h3
            style={{
              fontSize: '18px',
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
              marginBottom: '16px',
            }}
          >
            3. 选中状态
          </h3>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <CalendarDayCell date={20} isSelected={true} />
          </div>
          <div
            style={{
              marginTop: '12px',
              fontSize: '14px',
              fontWeight: 400,
              lineHeight: '20px',
              color: '#757575',
              textAlign: 'center',
            }}
          >
            蓝色背景 · 白色文字 · 阴影
          </div>
        </div>

        {/* State 4: Has Data */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            padding: '24px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <h3
            style={{
              fontSize: '18px',
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
              marginBottom: '16px',
            }}
          >
            4. 有数据状态
          </h3>
          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              gap: '16px',
              flexWrap: 'wrap',
            }}
          >
            <CalendarDayCell date={5} hasData={true} />
            <CalendarDayCell date={18} isToday={true} hasData={true} />
            <CalendarDayCell date={25} isSelected={true} hasData={true} />
          </div>
          <div
            style={{
              marginTop: '12px',
              fontSize: '14px',
              fontWeight: 400,
              lineHeight: '20px',
              color: '#757575',
              textAlign: 'center',
            }}
          >
            日期下方显示蓝点标记
          </div>
        </div>

        {/* State 5: Inactive */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            padding: '24px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <h3
            style={{
              fontSize: '18px',
              fontWeight: 600,
              lineHeight: '26px',
              color: '#212121',
              marginBottom: '16px',
            }}
          >
            5. 非当月状态
          </h3>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <CalendarDayCell date={28} isInactive={true} />
          </div>
          <div
            style={{
              marginTop: '12px',
              fontSize: '14px',
              fontWeight: 400,
              lineHeight: '20px',
              color: '#757575',
              textAlign: 'center',
            }}
          >
            透明背景 · 灰色文字
          </div>
        </div>
      </div>

      {/* Full Calendar Example */}
      <div
        style={{
          maxWidth: '375px',
          margin: '64px auto 0',
          backgroundColor: '#FFFFFF',
          padding: '24px',
          borderRadius: '12px',
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
        }}
      >
        <h2
          style={{
            fontSize: '24px',
            fontWeight: 600,
            lineHeight: '32px',
            color: '#212121',
            marginBottom: '24px',
            textAlign: 'center',
          }}
        >
          2025年11月
        </h2>

        {/* Week Header */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            gap: '4px',
            marginBottom: '8px',
          }}
        >
          {['一', '二', '三', '四', '五', '六', '日'].map((day) => (
            <div
              key={day}
              style={{
                fontSize: '12px',
                fontWeight: 400,
                lineHeight: '16px',
                color: '#9E9E9E',
                textAlign: 'center',
                height: '32px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {day}
            </div>
          ))}
        </div>

        {/* Calendar Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            gap: '4px',
          }}
        >
          {/* Previous month days */}
          <CalendarDayCell date={28} isInactive={true} />
          <CalendarDayCell date={29} isInactive={true} />
          <CalendarDayCell date={30} isInactive={true} />
          <CalendarDayCell date={31} isInactive={true} />

          {/* November 2025 - Week 1 */}
          <CalendarDayCell date={1} hasData={true} />
          <CalendarDayCell date={2} />
          <CalendarDayCell date={3} hasData={true} />

          {/* Week 2 */}
          <CalendarDayCell date={4} />
          <CalendarDayCell date={5} hasData={true} />
          <CalendarDayCell date={6} />
          <CalendarDayCell date={7} hasData={true} />
          <CalendarDayCell date={8} />
          <CalendarDayCell date={9} />
          <CalendarDayCell date={10} hasData={true} />

          {/* Week 3 */}
          <CalendarDayCell date={11} />
          <CalendarDayCell date={12} hasData={true} />
          <CalendarDayCell date={13} isToday={true} hasData={true} />
          <CalendarDayCell date={14} />
          <CalendarDayCell date={15} />
          <CalendarDayCell date={16} />
          <CalendarDayCell date={17} />

          {/* Week 4 */}
          <CalendarDayCell date={18} hasData={true} />
          <CalendarDayCell date={19} />
          <CalendarDayCell date={20} isSelected={true} hasData={true} />
          <CalendarDayCell date={21} />
          <CalendarDayCell date={22} hasData={true} />
          <CalendarDayCell date={23} />
          <CalendarDayCell date={24} />

          {/* Week 5 */}
          <CalendarDayCell date={25} hasData={true} />
          <CalendarDayCell date={26} />
          <CalendarDayCell date={27} />
          <CalendarDayCell date={28} />
          <CalendarDayCell date={29} />
          <CalendarDayCell date={30} />

          {/* Next month days */}
          <CalendarDayCell date={1} isInactive={true} />
        </div>
      </div>
    </div>
  );
}
