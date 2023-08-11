//
//  FCNetworking.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/8.
//

#import "FCNetworking.h"
#import <AFNetworking.h>

#define kServiceHost    @"http://ft-cn.hetangsmart.com/"
//http://ssmartlink.com/v2/weather/getCoordByIp

@implementation FCNetworking

+(AFHTTPSessionManager*)manager {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"iOS demo" forHTTPHeaderField:@"X-App-Name"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    // 2.设置非校验证书模式
//    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    [manager.securityPolicy setValidatesDomainName:NO];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
    
    return manager;
}

+ (PAURLSessionDataTask *)POST:(NSString *)key parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", kServiceHost, key];
    return [[FCNetworking manager] POST:url parameters:parameters headers:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
}


+ (void)downLoadFile:(NSString *)url fileName:(nonnull NSString *)fileName finished:(nonnull finishedBlock)finished {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFImageResponseSerializer serializer];

    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%f", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSArray *arrDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentPath = [arrDocumentPaths objectAtIndex:0];
        NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];

        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        finished(error);
    }];
    [task resume];
}


@end
