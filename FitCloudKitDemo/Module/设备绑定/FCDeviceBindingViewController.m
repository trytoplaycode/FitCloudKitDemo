//
//  FCDeviceBindingViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/21.
//

#import "FCDeviceBindingViewController.h"
#import <FitCloudKit/FitCloudKit.h>
#import "MoView.h"
#import "LocalizedLabel.h"
#import "LocalizedButton.h"
#import <NSDictionary+YYAdd.h>
#import "FCSearchViewController.h"
#import "FCFuncListViewController.h"
#import "FCSearchViewController.h"
#define USER_ID @"10000"

@interface FCDeviceBindingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bindingImageView;
@property (weak, nonatomic) IBOutlet MoView *resultView;

@property (weak, nonatomic) IBOutlet LocalizedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnEnjoy;
@property (weak, nonatomic) IBOutlet UIButton *btnTryLater;
@property (weak, nonatomic) IBOutlet UILabel *tipProgressLabel;

@property (nonatomic, assign) BOOL   bBindSuccess;
@property (nonatomic, assign) BOOL   bShouldUnBindFirst;

@end

@implementation FCDeviceBindingViewController

- (IBAction)enjoyNow:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tryLater:(id)sender {
    
}

-(instancetype)init
{
    if(self = [super init])
    {
        _bBindSuccess = NO;
        _bShouldUnBindFirst = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self beginAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBackView.backgroundColor = [UIColor blackColor];
    [self setNavBackWhite];
    [self addNavBar:NSLocalizedString(@"Binding Device", nil)];
    self.view.backgroundColor = [UIColor blackColor];
    [self initControls];
    [self registerNotificationObserver];
}

- (void)backAction {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)dealloc
{
    if(![FitCloudKit alreadyBound])[FitCloudKit ignoreConnectedPeripheral:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) initControls
{
    
    {
        self.bindingImageView.alpha = 0.0f;
        NSMutableArray *images = [NSMutableArray array];
        for(NSInteger i = 300; i < 319; i++)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"绑定手环_%@",@(i)]]];
        }
        self.bindingImageView.animationImages = images;
        self.bindingImageView.animationDuration = [images count]*2/25.0f;//设置动画时间
        self.bindingImageView.animationRepeatCount = 0;//设置动画次数 0 表示无限
        [self.bindingImageView startAnimating];
    }
    
    {
        self.titleLabel.alpha = 0.0f;
    }
    
    {
        self.subTitleLabel.alpha = 0.0f;
    }
    
    {
        self.btnEnjoy.hidden = YES;
        self.btnEnjoy.alpha = 0.0f;
    }
    
    {
        self.btnTryLater.hidden = YES;
        [self.btnTryLater setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        [self.btnTryLater setTitle:NSLocalizedString(@"Try Later", nil) forState:UIControlStateNormal];
        self.btnTryLater.alpha = 0.0f;
    }
}

-(void) registerNotificationObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudBindUserObjectBegin:) name:FITCLOUDEVENT_BINDUSEROBJECT_BEGIN_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudBindUserObjectResult:) name:FITCLOUDEVENT_BINDUSEROBJECT_RESULT_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudGetAllConfigBegin:) name:FITCLOUDEVENT_GETALLCONFIG_BEGIN_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudGetAllConfigResult:) name:FITCLOUDEVENT_GETALLCONFIG_RESULT_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnFitCloudInitializeResult:) name:FITCLOUDEVENT_INITIALIZE_RESULT_NOTIFY object:nil];
}


-(void)OnFitCloudBindUserObjectBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipProgressLabel.text = NSLocalizedString(@"Binding User Object", nil);
    });
}

-(void)OnFitCloudBindUserObjectResult:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL result = NO;
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo isKindOfClass:[NSDictionary class]])
        {
            result = [userInfo boolValueForKey:@"result" default:NO];
        }
        self.tipProgressLabel.text = result ? NSLocalizedString(@"Bind User Object Success", nil) : NSLocalizedString(@"Bind User Object Failure", nil);
    });
}

-(void)OnFitCloudGetAllConfigBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipProgressLabel.text = NSLocalizedString(@"Getting Smart Watch All Config", nil);
    });
}

-(void)OnFitCloudGetAllConfigResult:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL result = NO;
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo isKindOfClass:[NSDictionary class]])
        {
            result = [userInfo boolValueForKey:@"result" default:NO];
        }
        self.tipProgressLabel.text = result ? NSLocalizedString(@"Get Smart Watch All Config Success", nil) : NSLocalizedString(@"Get Smart Watch All Config Failure", nil);
    });
}

-(void)OnFitCloudInitializeResult:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo isKindOfClass:[NSDictionary class]])
        {
            BOOL result = [userInfo boolValueForKey:@"result" default:NO];
            self.bBindSuccess = result;
            if (result) {
                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"bindStatus"];
            }
            NSError * error = [userInfo objectForKey:@"error"];
            if([error isKindOfClass:[NSError class]] && error.code == FITCLOUDKITERROR_USEROBJECTALREADYBOUND)
            {
                self.bShouldUnBindFirst = YES;
            }
            [self.btnEnjoy setTitle:result ? NSLocalizedString(@"Enjoy Now", nil) : (self.bShouldUnBindFirst ? NSLocalizedString(@"Unbind And Retry", nil) : NSLocalizedString(@"Retry", nil)) forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
            __weak typeof (self) weakSelf = self;
            [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) return;
                if(result)
                {
                    strongSelf.titleLabel.text = NSLocalizedString(@"Smart Watch Bind Success", nil);
                    strongSelf.subTitleLabel.text = NSLocalizedString(@"Your Smart Watch Complete Bind...", nil);
                }
                else
                {
                    strongSelf.titleLabel.text = NSLocalizedString(@"Smart Watch Bind Failure", nil);
                    strongSelf.subTitleLabel.text = NSLocalizedString(@"Your Smart Watch Complete Failed to Bind...", nil);
                }
                strongSelf.bindingImageView.hidden = YES;
                strongSelf.resultView.alpha = 0.8f;
                [strongSelf.resultView startLoading];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(result)
                    {
                        [strongSelf.resultView success:^{
                            strongSelf.btnEnjoy.hidden = NO;
                            strongSelf.btnEnjoy.alpha = 1.0f;
                            self.tipProgressLabel.text = @"";
                            strongSelf.btnTryLater.hidden = YES;
                            strongSelf.btnTryLater.alpha = 0.0f;
                            [strongSelf.view layoutIfNeeded];
                        }];
                    }
                    else
                    {
                        [strongSelf.resultView error:^{
                            strongSelf.btnEnjoy.hidden = NO;
                            strongSelf.btnEnjoy.alpha = 1.0f;
                            self.tipProgressLabel.text = @"";
                            strongSelf.btnTryLater.hidden = NO;
                            strongSelf.btnTryLater.alpha = 1.0f;
                            [strongSelf.view layoutIfNeeded];
                        }];
                    }
                });
                
                [strongSelf.view layoutIfNeeded];
                
            }completion:^(BOOL finished) {
                
            }];
        }
    });
    
}

-(void) beginAnimation
{
    [self.view layoutIfNeeded];
    [self initControls];
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [FitCloudKit bindUserObject:USER_ID abortIfExist:YES block:^(BOOL succeed, NSError *error) {
            }];
        });
        [UIView animateWithDuration:1.45 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.titleLabel.alpha = 1.0f;
            strongSelf.subTitleLabel.alpha = 1.0f;
            strongSelf.bindingImageView.alpha = 1.0f;
            [strongSelf.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnEnjoyNow:(id)sender {
    self.btnEnjoy.hidden = YES;
    self.btnTryLater.hidden = YES;
    self.btnEnjoy.alpha = 0.0f;
    if(!self.bBindSuccess)
    {
        self.titleLabel.text = NSLocalizedString(@"Binding Smart Watch", nil);
        self.subTitleLabel.text = NSLocalizedString(@"Please keep the smart watch nearby your iPhone.", nil);
        self.bindingImageView.hidden = NO;
        self.resultView.alpha = 0.0f;
        [FitCloudKit bindUserObject:USER_ID abortIfExist:NO block:^(BOOL succeed, NSError *error) {
        }];
    }
    else
    {
        FCFuncListViewController *func = [FCFuncListViewController new];
        [self.navigationController pushViewController:func animated:YES];
        
//        [self dismissViewControllerAnimated:NO completion:^{
//            //[[NSNotificationCenter defaultCenter] postNotificationName:SKIPTOMETABNOTIFICATION object:nil];
//        }];
    }
}

- (IBAction)OnTryLater:(id)sender {
    [FitCloudKit ignoreConnectedPeripheral:YES];
    //[[NSNotificationCenter defaultCenter] postNotificationName:IGNORECONNECTEDPERIPHERALNOTIFICATION object:nil];
//    [self dismissViewControllerAnimated:NO completion:^{
        //[[NSNotificationCenter defaultCenter] postNotificationName:SKIPTOAPPHOMENOTIFICATION object:nil];
//    }];
    FCFuncListViewController *func = [FCFuncListViewController new];
    [self.navigationController pushViewController:func animated:YES];
}
@end
