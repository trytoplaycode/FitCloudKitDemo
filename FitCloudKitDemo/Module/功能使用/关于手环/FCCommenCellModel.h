//
//  FCCommenCellModel.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCCommenCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
