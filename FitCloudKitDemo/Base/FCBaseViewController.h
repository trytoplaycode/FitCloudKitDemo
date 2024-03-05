//
//  FCBaseViewController.h
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCBaseViewController : UIViewController

@property (nonatomic, assign) BOOL needBack;

@property (nonatomic, assign) BOOL needBottomLine;

@property (nonatomic, strong) UIView *navBackView;

@property (nonatomic, strong) UIButton *rightButton;


- (void)initialization;

- (void)layout;

- (void)addNavBar:(NSString *)title;

- (void)addNavRightButton:(NSString *)right isImage:(BOOL)isImage;

- (void)addNavRightViewWithView:(UIView *)rightView;

- (void)setNavBackWhite;

- (void)setNavBarClear;

- (void)backAction;

- (void)rightButtonAction;


@end

NS_ASSUME_NONNULL_END
