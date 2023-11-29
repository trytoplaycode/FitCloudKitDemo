//
//  FCDefinitions.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import <Toast.h>
#ifndef FCDefinitions_h
#define FCDefinitions_h

typedef NS_ENUM(NSInteger, FCHistoryType) {
    FCHistoryTypeStep,
    FCHistoryTypeHeartRate,
    FCHistoryTypeBloodOxygen,
    FCHistoryTypeBloodPressure,
    FCHistoryTypeSleep,
    FCHistoryTypeSports,
};

//appdelegate
#define appdelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]
//weakSelf
#define weakSelf(weakSelf) __weak typeof(self) weakSelf = self
//图片
#define IMAGENAME(name) [UIImage imageNamed:name]
//常规苹方
#define FONT_REGULAR(font)    [UIFont systemFontOfSize:font]
//加粗苹方
#define FONT_MEDIUM(font) [UIFont systemFontOfSize:font weight:UIFontWeightMedium]
//颜色十六进制
#define UIColorWithRGB(rgbValue, a)         [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
// 随机颜色
#define RANDOM_UICOLOR [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
//横向比例
#define ScaleW(s) ([UIScreen mainScreen].bounds.size.width/375*(s))
//纵向比例
#define ScaleH(number) ([UIScreen mainScreen].bounds.size.height/480*(number))
//系统版本
#define SYSTEM_VERSION [UIDevice currentDevice].systemVersion.doubleValue
//build version
#define BUNDLE_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define BUILD_VERSION  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
// 适配iPhone x 状态栏
#define kTopBarHeight (iPhoneX ? 88.f : 64.f)
#define kTopOffset (iPhoneX ? 22.f : 0)
#define kStatusBarHeight (iPhoneX ? 44 : 20)
// 适配iPhone x 底栏高度
#define kTabbarHeight  (iPhoneX ? 83 : 49)
#define kBottomHeight  (iPhoneX ? 34 : 0)
#define kBottomOffset  (iPhoneX ? 30 : 0)


#define IOS12_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS11_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS10_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS9_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending )

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

#define kColorWithHexString(hex)  [UIColor colorWithHexString:hex]

#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width

//iPhoneX顶部部偏移量
#define Top_SN_iPhoneX_SPACE            (iPhoneX ? 24.f : 0)
//iPhoneX底部偏移量
#define Bottom_SN_iPhoneX_SPACE         (iPhoneX ? 34.f : 0)
//iPhoneX navigationview底部Y坐标
#define NavigationBar_Bottom_Y     (iPhoneX ? 88.0 : 64.0)

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define iOS7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)?YES:NO)
#define ApplicationScreenHeight ([[UIScreen mainScreen] bounds].size.height - (iOS7?0:20))
#define ApplicationScreenWidth ([[UIScreen mainScreen] bounds].size.width)
//==================================================
// 判断是否为iPhone X 系列(XMax XR XS)
#define IPHONE_X_OR_LATER (CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(750,1624), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242,2688), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(828,1792), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1284,2778), [[UIScreen mainScreen] currentMode].size))

////打印
#ifdef DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#       define DLog(...)
#endif

//字符串是否为空
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
//数组是否为空
#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

#define OC(str) [NSString stringWithCString:(str) encoding:NSUTF8StringEncoding]

//16进制色值参数转换
#define UIColorFromRGB(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define APP_NAME ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] ? [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
#define APP_CHANNELID ([[[NSBundle mainBundle] infoDictionary] integerValueForKey:@"CHANNELID" default:0])
#define APP_BUNDLEIDENTIFIER ([[NSBundle mainBundle] bundleIdentifier])

#define APP_LOG_STRING(format, ...) [NSString stringWithFormat:@"[🏃‍♀️%@] %s (line %d) " format, APP_NAME, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

///用户信息列表
#define kUserInfoList @"userInfoList"
///账号密码
#define kUserNameAndPwd @"userNameAndPwd"
/// 登陆标记
#define kLoginFlag  @"loginFlag"
/// 当前绑定的设备
#define kBindDevice @"bindDevice"
/// 目标步数
#define kTargetSettings @"targetSettings"
/// 女性健康
#define kWomenHealthy @"womenHealthy"
/// 表盘风格
#define kDailStyle @"dailStyle"
/// 二维码
#define kQRCode @"qrCode"
/// 社交
#define kSocial @"socail"
/// 天气
#define kWeather @"weather"

#define OpResultToastTip(v, success) [v makeToast:success ? NSLocalizedString(@"Op success.", nil) : NSLocalizedString(@"Op failure.", nil) duration:3.0f position:CSToastPositionTop]

// 步数
#define kStepRecordList    @"kStepRecordList"
// 血氧
#define kBORecordList    @"kBORecordList"
// 心率
#define kHRRecordList    @"kHRRecordList"
// 血压
#define kBPRecordList    @"kBPRecordList"
// 体温
#define kBTRecordList   @"kBTRecordList"
// 睡眠
#define kSleepRecordList    @"kSleepRecordList"
// 运动数据
#define kSportsRecordList    @"kSportsRecordList"

#endif /* FCDefinitions_h */
