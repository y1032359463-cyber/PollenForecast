/// 设置页面
/// 功能：关于应用、隐私政策、用户协议、主题切换、版本信息

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _version = '';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersionInfo();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('darkMode') ?? false;
    
    setState(() {
      _isDarkMode = darkMode;
      _isLoading = false;
    });
  }

  /// 加载版本信息
  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('❌ 获取版本信息失败: $e');
    }
  }

  /// 保存主题设置
  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    
    setState(() {
      _isDarkMode = value;
    });

    _showToast(_isDarkMode ? '已切换到深色模式' : '已切换到浅色模式');
  }

  /// 显示 Toast
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于应用'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '花粉浓度播报',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '实时花粉浓度预报\n保护您和家人的健康',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '版本: $_version ($_buildNumber)',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 花粉预报',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示隐私政策
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '隐私政策',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '1. 信息收集',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本应用收集以下信息：\n'
                '- 设备定位信息（用于提供本地花粉数据）\n'
                '- 城市选择偏好（用于个性化推荐）',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '2. 信息使用',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '收集的信息仅用于提供花粉预报服务，不会用于其他商业目的。',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '3. 信息保护',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '我们采取合理的技术手段保护您的个人信息安全。',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '4. 第三方服务',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本应用使用第三方定位服务获取您的地理位置。',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示用户协议
  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '用户协议',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '1. 服务说明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本应用提供花粉浓度预报服务，数据来源于第三方气象服务。',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '2. 用户责任',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '用户在使用本应用时，应遵守相关法律法规，不得用于非法目的。',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '3. 免责声明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本应用提供的花粉数据仅供参考，不构成医疗建议。如需医疗帮助，请咨询专业医生。',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '4. 服务变更',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '我们保留随时修改或终止服务的权利。',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                // 主题设置
                _buildSection(
                  title: '外观',
                  children: [
                    _buildSwitchTile(
                      icon: Icons.dark_mode,
                      title: '深色模式',
                      subtitle: '切换应用主题颜色',
                      value: _isDarkMode,
                      onChanged: _saveDarkMode,
                    ),
                  ],
                ),

                // 关于应用
                _buildSection(
                  title: '关于',
                  children: [
                    _buildTile(
                      icon: Icons.info_outline,
                      title: '关于应用',
                      subtitle: '版本 $_version',
                      onTap: _showAboutDialog,
                    ),
                    _buildTile(
                      icon: Icons.privacy_tip_outlined,
                      title: '隐私政策',
                      subtitle: '了解我们如何保护您的隐私',
                      onTap: _showPrivacyPolicy,
                    ),
                    _buildTile(
                      icon: Icons.description_outlined,
                      title: '用户协议',
                      subtitle: '使用本应用的相关条款',
                      onTap: _showUserAgreement,
                    ),
                  ],
                ),

                // 版本信息
                _buildSection(
                  title: '版本信息',
                  children: [
                    _buildInfoTile('版本号', _version),
                    _buildInfoTile('构建号', _buildNumber),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  /// 构建分组
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建开关项
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 构建普通项
  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建信息项
  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
