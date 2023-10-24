//
//  FCDialLibraryModel.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCDialLibraryModel : NSObject

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) int id;
@property (nonatomic, assign) int dialNum;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) int lcd;
@property (nonatomic, copy) NSString *toolVersion;
@property (nonatomic, copy) NSString *bindUrl;
@property (nonatomic, assign) int bindVersion;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *deviceImgUrl;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int downloadCount;
@property (nonatomic, copy) NSString *createId;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *previewImgUrl;
@property (nonatomic, assign) int hasComponent;
@property (nonatomic, copy) NSString *componentsRaw;
@property (nonatomic, copy) NSString *relatedProject;
@property (nonatomic, strong) NSArray *components;
@property (nonatomic, assign) int bindSize;

// 运动数据
@property (nonatomic, assign) int binSize;
@property (nonatomic, copy) NSString *binUrl;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *sportUiName;
@property (nonatomic, copy) NSString *sportUiNameCn;
@property (nonatomic, strong) NSDictionary *uiType;


@end

NS_ASSUME_NONNULL_END
