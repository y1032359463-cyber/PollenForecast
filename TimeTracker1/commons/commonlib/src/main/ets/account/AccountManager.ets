/**
 * AccountManager - 华为账号管理器
 * 
 * 功能说明:
 * 1. 管理华为账号登录状态
 * 2. 存储用户信息(UnionID、用户名等)
 * 3. 提供静默登录和手动登录接口
 * 4. 支持登录状态持久化
 * 
 * 云同步功能规划:
 * - 阶段1(当前): 接口预留,返回未登录状态
 * - 阶段2(开发中): 接入华为Account Kit,实现登录功能
 * - 阶段3(未来): 实现数据云同步、多设备同步
 * 
 * 使用示例:
 * ```typescript
 * const accountManager = AccountManager.getInstance();
 * await accountManager.init(this.context);
 * const isLoggedIn = accountManager.isLoggedIn();
 * const userInfo = accountManager.getUserInfo();
 * ```
 */

import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

/**
 * 用户信息接口
 */
export interface UserInfo {
  unionId: string;        // 华为账号UnionID(唯一标识)
  openId?: string;        // OpenID(可选)
  userName: string;       // 用户名
  avatar?: string;        // 头像URL(可选)
  phone?: string;         // 手机号(可选,需额外权限)
  email?: string;         // 邮箱(可选)
  memberSince: string;    // 注册时间
}

/**
 * 登录状态枚举
 */
export enum LoginStatus {
  NOT_LOGGED_IN = 0,      // 未登录
  LOGGED_IN = 1,          // 已登录
  EXPIRED = 2,            // 登录过期
  ERROR = -1              // 错误状态
}

/**
 * 账号数据接口
 */
interface AccountData {
  userInfo: UserInfo | null;
  loginStatus: LoginStatus;
}

/**
 * AccountManager - 单例模式
 */
export class AccountManager {
  private static instance: AccountManager;
  private context: common.UIAbilityContext | null = null;
  private userInfo: UserInfo | null = null;
  private loginStatus: LoginStatus = LoginStatus.NOT_LOGGED_IN;
  private preferencesKey = 'account_info';

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): AccountManager {
    if (!AccountManager.instance) {
      AccountManager.instance = new AccountManager();
    }
    return AccountManager.instance;
  }

  /**
   * 初始化AccountManager
   * @param context - UIAbilityContext
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    await this.loadAccountInfo();
    console.info('[AccountManager] 初始化完成,登录状态:', this.loginStatus);
  }

  /**
   * 检查是否已登录
   */
  isLoggedIn(): boolean {
    return this.loginStatus === LoginStatus.LOGGED_IN;
  }

  /**
   * 获取登录状态
   */
  getLoginStatus(): LoginStatus {
    return this.loginStatus;
  }

  /**
   * 获取用户信息
   */
  getUserInfo(): UserInfo | null {
    return this.userInfo;
  }

  /**
   * 静默登录(应用启动时自动调用)
   * TODO: 阶段2实现华为Account Kit集成
   */
  async attemptSilentLogin(): Promise<boolean> {
    console.info('[AccountManager] 尝试静默登录...');
    // TODO: 调用华为Account Kit静默登录API
    // const loginRequest = new authentication.HuaweiIDProvider()
    //   .createLoginWithHuaweiIDRequest();
    // loginRequest.forceLogin = false;
    // ...

    // 当前返回false(未登录)
    return false;
  }

  /**
   * 手动登录(用户点击登录按钮)
   * TODO: 阶段2实现华为Account Kit集成
   */
  async login(): Promise<boolean> {
    console.info('[AccountManager] 手动登录...');
    // TODO: 调用华为Account Kit登录API
    // const loginRequest = new authentication.HuaweiIDProvider()
    //   .createLoginWithHuaweiIDRequest();
    // loginRequest.forceLogin = true;
    // ...

    // 当前返回false
    return false;
  }

  /**
   * 登出
   */
  async logout(): Promise<void> {
    console.info('[AccountManager] 登出账号');
    this.userInfo = null;
    this.loginStatus = LoginStatus.NOT_LOGGED_IN;
    await this.saveAccountInfo();
    // TODO: 清除云同步数据缓存
  }

  /**
   * 更新用户信息
   * @param userInfo - 用户信息
   */
  async updateUserInfo(userInfo: UserInfo): Promise<void> {
    this.userInfo = userInfo;
    this.loginStatus = LoginStatus.LOGGED_IN;
    await this.saveAccountInfo();
    console.info('[AccountManager] 用户信息已更新:', userInfo.userName);
  }

  /**
   * 加载账号信息(从本地存储)
   */
  private async loadAccountInfo(): Promise<void> {
    if (!this.context) {
      console.warn('[AccountManager] Context未初始化');
      return;
    }

    try {
      const prefs = await preferences.getPreferences(this.context, 'account_settings');
      const savedInfo = await prefs.get(this.preferencesKey, '{}') as string;
      
      if (savedInfo && savedInfo !== '{}') {
        const parsed = JSON.parse(savedInfo) as AccountData;
        this.userInfo = parsed.userInfo;
        this.loginStatus = parsed.loginStatus;
        console.info('[AccountManager] 账号信息已加载');
      }
    } catch (err) {
      console.error('[AccountManager] 加载账号信息失败:', err);
    }
  }

  /**
   * 保存账号信息(到本地存储)
   */
  private async saveAccountInfo(): Promise<void> {
    if (!this.context) {
      console.warn('[AccountManager] Context未初始化');
      return;
    }

    try {
      const prefs = await preferences.getPreferences(this.context, 'account_settings');
      interface AccountData {
        userInfo: UserInfo | null;
        loginStatus: LoginStatus;
      }
      const data: AccountData = {
        userInfo: this.userInfo,
        loginStatus: this.loginStatus
      };
      await prefs.put(this.preferencesKey, JSON.stringify(data));
      await prefs.flush();
      console.info('[AccountManager] 账号信息已保存');
    } catch (error) {
      console.error('[AccountManager] 保存账号信息失败:', error);
    }
  }

  /**
   * 检查Access Token是否过期
   * TODO: 阶段2实现Token管理
   */
  isTokenExpired(): boolean {
    // TODO: 检查Access Token有效期
    return false;
  }

  /**
   * 刷新Access Token
   * TODO: 阶段2实现Token刷新
   */
  async refreshToken(): Promise<boolean> {
    console.info('[AccountManager] 刷新Token...');
    // TODO: 使用Refresh Token刷新Access Token
    return false;
  }
}
