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
 * 添加tabbar（add child controller）
 * @param controller          需要管理的控制器（controller）
 * @param title               底部文字（title for tabbar）
 * @param imageName           未选中时的图片（unselect image）
 * @param selectedImageName   选中时的图片（select image）
 */
- (void)addChildController:(id)controller
                     title:(NSString *)title
                 imageName:(NSString *)imageName
         selectedImageName:(NSString *)selectedImageName;

/**
 * 添加tabbar（add child controller）
 * @param controller          需要管理的控制器（controller）
 * @param title               底部文字（title for tabbar）
 * @param imageName           未选中时的图片（unselect image）
 * @param selectedImageName   选中时的图片（select image）
 */
- (void)addCenterController:(nullable id)controller
                      bulge:(BOOL)bulge
                      title:(NSString *)title
                  imageName:(NSString *)imageName
          selectedImageName:(NSString *)selectedImageName;

@end

NS_ASSUME_NONNULL_END
