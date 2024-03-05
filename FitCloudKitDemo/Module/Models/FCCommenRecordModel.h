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

/// Record Type（记录类型）
@property (nonatomic, assign) FCHistoryType type;
/// Record date（记录时间）
@property (nonatomic, copy) NSString *recordDate;

/// Step（步数）
@property (nonatomic, assign) int steps;
/// Distance（距离）
@property (nonatomic, assign) int distance;
/// Calory（消耗卡路里）
@property (nonatomic, assign) int calory;

//Blood pressure（血压）
/// Diastolic blood pressure（收缩压）
@property(nonatomic, assign) int diastolic;
/// Systolic blood pressure（收缩压）
@property(nonatomic, assign) int systolic;
@property(nonatomic, assign) int heartRateIfBaseOnPneumaticpump;

/// Heart rate（心率）
@property(nonatomic, assign) int hrValue;

/// Blood oxygen（血氧）
@property(nonatomic, assign) int boValue;

/// Wrist temperature ℃（手腕温度 单位：摄氏度）
@property(nonatomic, assign) CGFloat  wrist;
/// Body temperature ℃（体温，单位：摄氏度）
@property(nonatomic, assign) CGFloat  body;

/// Sleep quality（睡眠质量）
@property(nonatomic, assign) FITCLOUDSLEEPQUALITY quality;

/// Sports type（运动类型）
@property(nonatomic, assign) FITCLOUDSPORTSTYPE genre;
/// Exercise duration Second（运动时长(秒)）
@property(nonatomic, assign) UInt16  duration;

/// Speed（配速(min/km)）
@property(nonatomic, assign) UInt16 pace;
/// Exercise heart rate （Times per minute）（运动心率(次/分)）
@property(nonatomic, assign) UInt8  hr_excercise;

@end

NS_ASSUME_NONNULL_END
