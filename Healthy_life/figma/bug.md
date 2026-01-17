"C:\Program Files\Huawei\DevEco Studio2\DevEco Studio\tools\node\node.exe" "C:\Program Files\Huawei\DevEco Studio2\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor hvigor client: Starting hvigor daemon.
> hvigor Hvigor Daemon started in 1.32 s
> hvigor UP-TO-DATE :entry:default@PreBuild...  
> hvigor Finished :entry:default@CreateModuleInfo... after 3 ms 
> hvigor UP-TO-DATE :entry:default@GenerateMetadata...  
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MergeProfile...  
> hvigor UP-TO-DATE :entry:default@CreateBuildProfile...  
> hvigor Finished :entry:default@PreCheckSyscap... after 1 ms 
> hvigor Finished :entry:default@GeneratePkgContextInfo... after 12 ms 
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 2 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MakePackInfo...  
> hvigor Finished :entry:default@SyscapTransform... after 19 ms 
> hvigor UP-TO-DATE :entry:default@ProcessProfile...  
> hvigor UP-TO-DATE :entry:default@ProcessRouterMap...  
> hvigor UP-TO-DATE :entry:default@ProcessShareConfig...  
> hvigor Finished :entry:default@ProcessStartupConfig... after 4 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 2 ms 
> hvigor UP-TO-DATE :entry:default@ProcessResource...  
> hvigor UP-TO-DATE :entry:default@GenerateLoaderJson...  
> hvigor UP-TO-DATE :entry:default@ProcessLibs...  
> hvigor Finished :entry:default@CompileResource... after 636 ms 
> hvigor UP-TO-DATE :entry:default@DoNativeStrip...  
> hvigor Finished :entry:default@BuildJS... after 7 ms 
> hvigor UP-TO-DATE :entry:default@CacheNativeLibs...  
> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor WARN: 
1 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:55:12
 Function may throw exceptions. Special handling is required.

2 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:147:12
 Function may throw exceptions. Special handling is required.

3 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:152:12
 Function may throw exceptions. Special handling is required.

4 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:157:12
 Function may throw exceptions. Special handling is required.

5 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:162:12
 Function may throw exceptions. Special handling is required.

6 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbHelperImp.ets:167:12
 Function may throw exceptions. Special handling is required.

7 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/database/rdb/RdbUtils.ets:58:12
 Function may throw exceptions. Special handling is required.

8 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/SplashPage.ets:50:22
 Function may throw exceptions. Special handling is required.

9 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/SplashPage.ets:63:5
 Function may throw exceptions. Special handling is required.

10 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/SplashPage.ets:73:22
 Function may throw exceptions. Special handling is required.

11 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/AdvertisingPage.ets:27:5
 Function may throw exceptions. Special handling is required.

12 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/HomeComponent.ets:88:7
 Function may throw exceptions. Special handling is required.

13 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/HomeComponent.ets:118:7
 Function may throw exceptions. Special handling is required.

14 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/dialog/TaskSettingDialog.ets:36:7
 Function may throw exceptions. Special handling is required.

15 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/statistics/CalendarHeatmap.ets:145:19
 'show' has been deprecated.

16 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/ReminderSettingsPage.ets:28:64
 'getContext' has been deprecated.

17 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/ReminderSettingsPage.ets:43:64
 'getContext' has been deprecated.

18 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/common/utils/DataExportService.ets:150:21
 'getContext' has been deprecated.

19 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/DataExportPage.ets:27:20
 'showToast' has been deprecated.

20 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/DataExportPage.ets:32:7
 Function may throw exceptions. Special handling is required.

21 WARN: ArkTS:WARN File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/DataExportPage.ets:32:20
 'showToast' has been deprecated.

> hvigor ERROR: ArkTS Compiler Error
1 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/AchievementPage.ets:58:5


2 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/pages/AchievementPage.ets:59:5


3 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/statistics/CalendarHeatmap.ets:130:5


4 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: C:/HarmonyOS_App_Plans/Healthy_life/entry/src/main/ets/view/statistics/CalendarHeatmap.ets:131:5


COMPILE RESULT:FAIL {ERROR:5 WARN:21}

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --debug option to get more log output.

> hvigor ERROR: BUILD FAILED in 17 s 140 ms 

Process finished with exit code -1
