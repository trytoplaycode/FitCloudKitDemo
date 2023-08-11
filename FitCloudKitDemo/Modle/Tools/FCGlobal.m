//
//  FCGlobal.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCGlobal.h"

static FCGlobal *_manager = nil;
@implementation FCGlobal
+ (FCGlobal *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[FCGlobal alloc] init];
    });
    
    
    return _manager;
}

@end
