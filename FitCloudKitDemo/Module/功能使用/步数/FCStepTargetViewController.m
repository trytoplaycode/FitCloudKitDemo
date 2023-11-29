//
//  FCStepTargetViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCStepTargetViewController.h"
#import <FitCloudKit/FitCloudKit.h>
#import <BRPickerView/BRStringPickerView.h>
#import "LocalizedButton.h"
#import "LocalizedLabel.h"
#import "FCDefinitions.h"
#import <MBProgressHUD.h>
#import <Masonry.h>
@interface FCStepTargetViewController ()
@property (weak, nonatomic) IBOutlet LocalizedLabel *targetLabel;
@property (weak, nonatomic) IBOutlet LocalizedButton *updateButton;
@property (strong, nonatomic) NSMutableArray *dataArr;

@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIButton *distanceButton;
@property (strong, nonatomic) NSMutableArray *distanceArr;

@property (nonatomic, strong) UILabel *caloryLabel;
@property (nonatomic, strong) UIButton *caloryButton;
@property (strong, nonatomic) NSMutableArray *caloryArr;

@end

@implementation FCStepTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Step Target", nil)];
    [self initialization];
    [self setNavBackWhite];
    [self loadTaget];
}

- (void)initialization {
    [self addSubViews];
    [self layout];
}

- (void)addSubViews {
    self.targetLabel.clipsToBounds = YES;
    self.targetLabel.layer.cornerRadius = 6;
    self.targetLabel.layer.borderWidth = 1;
    self.targetLabel.layer.borderColor = UIColorFromRGB(0x999999, 1.f).CGColor;
    [self.view addSubview:self.distanceLabel];
    [self.view addSubview:self.distanceButton];
    [self.view addSubview:self.caloryLabel];
    [self.view addSubview:self.caloryButton];
}

- (void)layout {
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(30);
        make.top.mas_equalTo(self.view.mas_top).offset(230);
        make.size.mas_equalTo(CGSizeMake(130, 30));
    }];
    [self.distanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.distanceLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
        make.centerY.mas_equalTo(self.distanceLabel.mas_centerY).offset(0);
        make.height.mas_equalTo(30);
    }];
    [self.caloryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(30);
        make.top.mas_equalTo(self.view.mas_top).offset(280);
        make.size.mas_equalTo(CGSizeMake(130, 30));
    }];
    [self.caloryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.caloryLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
        make.centerY.mas_equalTo(self.caloryLabel.mas_centerY).offset(0);
        make.height.mas_equalTo(30);
    }];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadTaget {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit getDailyGoalWithBlock:^(BOOL succeed, FitCloudDailyGoalObject *goal, NSError *error) {
        NSLog(@"%d==%@", succeed, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (goal) {
                weakSelf.targetLabel.text = [NSString stringWithFormat:@"%d", goal.stepCountGoal];
            }else {
                NSDictionary *target = [[NSUserDefaults standardUserDefaults] objectForKey:kTargetSettings];
                int step = 0;
                int distance = 0;
                int calory = 0;
                if (target) {
                    step = [[target objectForKey:@"step"] intValue];
                    distance = [[target objectForKey:@"distance"] intValue];
                    calory = [[target objectForKey:@"calory"] intValue];
                }
                weakSelf.targetLabel.text = [NSString stringWithFormat:@"%d", step];
                [weakSelf.distanceButton setTitle:[NSString stringWithFormat:@"%d", distance] forState:UIControlStateNormal];
                [weakSelf.caloryButton setTitle:[NSString stringWithFormat:@"%d", calory] forState:UIControlStateNormal];;
            }
        });
    }];
}
- (IBAction)selectTargetAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSInteger index = 0;
    if ([sender isEqual:self.distanceButton]) {
        index = [self.distanceButton.titleLabel.text intValue]/10;
    }else if ([sender isEqual:self.caloryButton]) {
        index = [self.caloryButton.titleLabel.text intValue]/10;
    }else {
        index = [self.targetLabel.text intValue]/10;
    }
    [BRStringPickerView showPickerWithTitle:NSLocalizedString(@"Step Target", nil) dataSourceArr:self.dataArr selectIndex:index/10 resultBlock:^(BRResultModel * _Nullable resultModel) {
        if ([sender isEqual:self.distanceButton]) {
            [weakSelf.distanceButton setTitle:resultModel.value forState:UIControlStateNormal];
        }else if ([sender isEqual:self.caloryButton]) {
            [weakSelf.caloryButton setTitle:resultModel.value forState:UIControlStateNormal];
        }else {
            weakSelf.targetLabel.text = resultModel.value;
        }
    }];
}

- (void)updateStepTarget {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    uint32_t step = [self.targetLabel.text intValue];
    uint32_t distance = [self.distanceButton.titleLabel.text intValue];
    uint32_t calory = [self.caloryButton.titleLabel.text intValue];
    __weak typeof(self) weakSelf = self;
    [FitCloudKit setDailyGoalWithStepCount:(UInt32)(step) distance:(UInt32)(distance*100000) calory:(UInt32)(calory*1000) timestamp:nil block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *target = @{@"step":@(step), @"distance":@(distance), @"calory":@(calory)};
            [[NSUserDefaults standardUserDefaults] setObject:target forKey:kTargetSettings];
            weakSelf.targetLabel.text = [NSString stringWithFormat:@"%d", step];
            [weakSelf.distanceButton setTitle:[NSString stringWithFormat:@"%d", distance] forState:UIControlStateNormal];
            [weakSelf.caloryButton setTitle:[NSString stringWithFormat:@"%d", calory] forState:UIControlStateNormal];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            OpResultToastTip(self.view, succeed);
        });
    }];
}


- (IBAction)updateAction:(id)sender {
    [self updateStepTarget];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
        for (int i = 0; i < 10000; i++) {
            [_dataArr addObject:[NSString stringWithFormat:@"%d", i*10]];
        }
    }
    
    return _dataArr;
}

- (NSMutableArray *)distanceArr {
    if (!_distanceArr) {
        _distanceArr = @[].mutableCopy;
        for (int i = 0; i < 10000; i++) {
            [_distanceArr addObject:[NSString stringWithFormat:@"%d", i*10]];
        }
    }
    
    return _distanceArr;
}

- (UILabel *)distanceLabel {
    if (!_distanceLabel) {
        _distanceLabel = [UILabel new];
        _distanceLabel.textColor = [UIColor blackColor];
        _distanceLabel.text = NSLocalizedString(@"Target Distance", nil);
        _distanceLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    
    return _distanceLabel;
}

- (UIButton *)distanceButton {
    if (!_distanceButton) {
        _distanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _distanceButton.backgroundColor = [UIColor whiteColor];
        _distanceButton.clipsToBounds = YES;
        _distanceButton.layer.cornerRadius = 6;
        _distanceButton.layer.borderWidth = 1;
        _distanceButton.layer.borderColor = UIColorFromRGB(0x999999, 1.f).CGColor;
        [_distanceButton setTitle:@"0" forState:UIControlStateNormal];
        [_distanceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_distanceButton addTarget:self action:@selector(selectTargetAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _distanceButton;
}

- (NSMutableArray *)caloryArr {
    if (!_caloryArr) {
        _caloryArr = @[].mutableCopy;
        for (int i = 0; i < 10000; i++) {
            [_caloryArr addObject:[NSString stringWithFormat:@"%d", i*10]];
        }
    }
    
    return _caloryArr;
}

- (UILabel *)caloryLabel {
    if (!_caloryLabel) {
        _caloryLabel = [UILabel new];
        _caloryLabel.textColor = [UIColor blackColor];
        _caloryLabel.text = NSLocalizedString(@"Target Calory", nil);
        _caloryLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    
    return _caloryLabel;
}

- (UIButton *)caloryButton {
    if (!_caloryButton) {
        _caloryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _caloryButton.backgroundColor = [UIColor whiteColor];
        _caloryButton.clipsToBounds = YES;
        _caloryButton.layer.cornerRadius = 6;
        _caloryButton.layer.borderWidth = 1;
        _caloryButton.layer.borderColor = UIColorFromRGB(0x999999, 1.f).CGColor;
        [_caloryButton setTitle:@"0" forState:UIControlStateNormal];
        [_caloryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_caloryButton addTarget:self action:@selector(selectTargetAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _caloryButton;
}

@end
