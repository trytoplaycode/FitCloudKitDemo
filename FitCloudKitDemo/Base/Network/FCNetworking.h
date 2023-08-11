//
//  FCNetworking.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/8.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^finishedBlock)(NSError * _Nullable error);
typedef NSURLSessionDataTask PAURLSessionDataTask;

NS_ASSUME_NONNULL_BEGIN

@interface FCNetworking : NSObject


+ (nullable PAURLSessionDataTask *)POST:(NSString *)key
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


+ (void)downLoadFile:(NSString *)url fileName:(NSString *)fileName finished:(finishedBlock)finished;

@end

NS_ASSUME_NONNULL_END
