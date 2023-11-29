//
//  FCCommenRecordModel.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/30.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKit.h>
#import "FCDefinitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCCommenRecordModel : NSObject

/// 记录类型
@property (nonatomic, assign) FCHistoryType type;
/// 记录时间
@property (nonatomic, copy) NSString *recordDate;

// 步数
/// 步数
@property (nonatomic, assign) int steps;
/// 距离
@property (nonatomic, assign) int distance;
/// 消耗卡路里
@property (nonatomic, assign) int calory;

//血压
/// 收缩压
@property(nonatomic, assign) int diastolic;
/// 收缩压
@property(nonatomic, assign) int systolic;
/// 是否是真实血压
@property(nonatomic, assign) int heartRateIfBaseOnPneumaticpump;

/// 心率
@property(nonatomic, assign) int hrValue;

/// 血氧
@property(nonatomic, assign) int boValue;

// 温度
/// 手腕温度，单位：摄氏度
@property(nonatomic, assign) CGFloat  wrist;
/// 体温，单位：摄氏度
@property(nonatomic, assign) CGFloat  body;

//睡眠
/// 睡眠质量
@property(nonatomic, assign) FITCLOUDSLEEPQUALITY quality;

//运动
/// 运动类型
@property(nonatomic, assign) FITCLOUDSPORTSTYPE genre;
/// 运动时长(秒)
@property(nonatomic, assign) UInt16  duration;

/// 步数、距离(米)、卡路里(小卡)跟步数模块公用

/// 配速(min/km)
@property(nonatomic, assign) UInt16 pace;
/// 运动心率(次/min)
@property(nonatomic, assign) UInt8  hr_excercise;

@end

NS_ASSUME_NONNULL_END
