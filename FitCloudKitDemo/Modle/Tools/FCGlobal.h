//
//  FCGlobal.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FCGlobal : NSObject

+ (FCGlobal *)shareInstance;

@property (nonatomic, strong) CBPeripheral *currentPeripheral;


@end

NS_ASSUME_NONNULL_END
