//
//  FCBaseTabBarViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import <UIKit/UIKit.h>
#import "FCTabbar.h"
NS_ASSUME_NONNULL_BEGIN

@interface FCBaseTabBarViewController : UITabBarController

@property (nonatomic, strong) FCTabbar *tabbar;

/**
 * 添加子控制器
 * @param controller          需管理的子控制器
 * @param title               底部文字
 * @param imageName           未选中的图片名
 * @param selectedImageName   选中的图片名
 */
- (void)addChildController:(id)controller
                     title:(NSString *)title
                 imageName:(NSString *)imageName
         selectedImageName:(NSString *)selectedImageName;

/**
 * 设置中间按钮
 * @param controller          需管理的子控制器
 * @param title               底部文字
 * @param imageName           未选中的图片名
 * @param selectedImageName   选中的图片名
 */
- (void)addCenterController:(nullable id)controller
                      bulge:(BOOL)bulge
                      title:(NSString *)title
                  imageName:(NSString *)imageName
          selectedImageName:(NSString *)selectedImageName;

@end

NS_ASSUME_NONNULL_END
