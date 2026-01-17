import { BottomNavigation } from './components/bottom-navigation';

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center p-8">
      <div className="w-[375px] h-[812px] bg-white rounded-[3rem] shadow-2xl overflow-hidden relative">
        {/* Phone notch */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-40 h-7 bg-black rounded-b-3xl z-10"></div>
        
        {/* App content area */}
        <div className="h-full bg-gradient-to-b from-blue-50 to-white pt-12 pb-20">
          <div className="px-6 pt-8">
            <h1 className="text-gray-900 mb-2">My Finance</h1>
            <p className="text-gray-500">Welcome back!</p>
          </div>
          
          {/* Sample content */}
          <div className="px-6 mt-8 space-y-4">
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
              <p className="text-gray-500 mb-1">Total Balance</p>
              <p className="text-gray-900">$12,485.50</p>
            </div>
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
              <p className="text-gray-500 mb-1">This Month</p>
              <p className="text-gray-900">+$2,340.00</p>
            </div>
          </div>
        </div>
        
        {/* Bottom Navigation */}
        <BottomNavigation />
      </div>
    </div>
  );
}
