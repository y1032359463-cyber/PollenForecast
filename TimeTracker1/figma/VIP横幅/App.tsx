import { VipBanner } from './components/vip-banner';

export default function App() {
  return (
    <div 
      className="min-h-screen flex flex-col items-center justify-center gap-6"
      style={{
        background: '#F5F5F7',
        fontFamily: 'HarmonyOS Sans, -apple-system, BlinkMacSystemFont, sans-serif',
        padding: '24px'
      }}
    >
      <div className="flex flex-col gap-6">
        <div>
          <div 
            className="mb-3 text-gray-600"
            style={{ fontSize: '14px' }}
          >
            默认版本 (Default)
          </div>
          <VipBanner variant="default" />
        </div>

        <div>
          <div 
            className="mb-3 text-gray-600"
            style={{ fontSize: '14px' }}
          >
            促销版本 (Promo)
          </div>
          <VipBanner variant="promo" />
        </div>
      </div>

      <div 
        className="text-gray-500 text-center mt-8"
        style={{ fontSize: '12px', maxWidth: '328px' }}
      >
        TimeTracker - 时间记录应用
      </div>
    </div>
  );
}
