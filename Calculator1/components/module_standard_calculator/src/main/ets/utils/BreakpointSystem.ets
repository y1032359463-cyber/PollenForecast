import { AppStorageV2, display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';

export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
  LG_WIDE = 'lgWide',
  LG_NORMAL = 'lgNormal',
  TABLET_LANDSCAPE = 'tabletLandscape',
}

export interface BreakpointType<T> {
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
  lgWide?: T;
  lgNormal?: T;
  tabletLandscape?: T;
}


@ObservedV2
export class BreakpointStorage {
  @Trace wight: BreakpointTypeEnum = BreakpointTypeEnum.SM
  @Trace height: BreakpointTypeEnum = BreakpointTypeEnum.LG_NORMAL
  @Trace isTabletLandscape: boolean = false;
}

@ObservedV2
class BreakpointSystem {
  @Trace currentBreakpoint: BreakpointStorage = AppStorageV2.connect(BreakpointStorage, () => new BreakpointStorage())!
  private _uiContext: UIContext | undefined
  private _windowClass: window.Window | undefined
  windowSizeChange = (data: window.Size) => {
    this.updateBreakpoint(data);
  }

  isTablet() {
    let deviceTypeInfo: string = deviceInfo.deviceType;
    return deviceTypeInfo === 'tablet';
  }

  public register(uiContext: UIContext) {
    if (this._uiContext) {
      return;
    }
    this._uiContext = uiContext;
    if (this._uiContext) {
      this.updateBreakpoint();
      window.getLastWindow(this._uiContext.getHostContext()).then((win) => {
        this._windowClass = win;
        this._windowClass.on('windowSizeChange', this.windowSizeChange);
      })
    }
  }

  public async updateBreakpoint(data?: window.Size) {
    let temp: BreakpointTypeEnum = BreakpointTypeEnum.MD
    const curBreakPoint = this._uiContext!.getWindowWidthBreakpoint()
    if (curBreakPoint === WidthBreakpoint.WIDTH_XS || curBreakPoint === WidthBreakpoint.WIDTH_SM) {
      temp = BreakpointTypeEnum.SM
    } else if (curBreakPoint === WidthBreakpoint.WIDTH_MD) {
      temp = BreakpointTypeEnum.MD
    } else if (curBreakPoint === WidthBreakpoint.WIDTH_XL) {
      temp = BreakpointTypeEnum.XL
    } else {
      temp = BreakpointTypeEnum.LG
    }
    this.currentBreakpoint.wight = temp
    let height = AppStorage.get('height') as number || 792
    if (data) {
      height = px2vp(data.height)
    }

    try {
      const defaultDisplay = await display.getDefaultDisplay();
      const orientation = defaultDisplay.orientation;
      if (this.isTablet()) {
        this.currentBreakpoint.isTabletLandscape =
          [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED].includes(orientation);
      } else {
        this.currentBreakpoint.isTabletLandscape = false;
      }
    } catch (err) {
      console.error('监听方向失败：', (err as BusinessError).message);
    }

    if (this.currentBreakpoint.isTabletLandscape) {
      this.currentBreakpoint.height = BreakpointTypeEnum.TABLET_LANDSCAPE;
    } else {
      if (height < 792) {
        this.currentBreakpoint.height = BreakpointTypeEnum.LG_WIDE
      }
    }
  }

  public unregister() {
    if (this._windowClass) {
      this._windowClass.off('windowSizeChange', this.windowSizeChange)
    }
  }
}

export class BreakpointModel<T> {
  private options: BreakpointType<T>;

  constructor(options: BreakpointType<T>) {
    this.options = options;
  }

  public getValue(bp: BreakpointTypeEnum) {
    return Reflect.get(this.options, bp) as T;
  }
}

const breakpointSystem = new BreakpointSystem()

export { breakpointSystem as BreakpointSystem }