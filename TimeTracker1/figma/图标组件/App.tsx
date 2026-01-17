import { SpendingBreakdown } from './components/SpendingBreakdown';
import { WeeklyTrendChart } from './components/WeeklyTrendChart';

export default function App() {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-8">
      <div className="flex gap-8 flex-wrap justify-center">
        {/* Spending Breakdown Component */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h1 
            className="mb-6 text-center"
            style={{
              fontSize: '24px',
              fontWeight: 600,
              color: '#1C1C1E',
              lineHeight: '32px',
              margin: 0,
              marginBottom: '24px',
              padding: 0
            }}
          >
            Spending Breakdown
          </h1>
          <SpendingBreakdown />
        </div>

        {/* Weekly Trend Chart Component */}
        <div className="flex items-center">
          <WeeklyTrendChart />
        </div>
      </div>
    </div>
  );
}