//
//  FCStepTargetViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCStepTargetViewController.h"
#import <FitCloudKit/FitCloudKit.h>
#import <BRPickerView/BRStringPickerView.h>

@interface FCStepTargetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) FitCloudDailyGoalObject *target;

@end

@implementation FCStepTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Step Target", nil)];
    [self setNavBackWhite];
    [self loadTaget];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadTaget {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit getDailyGoalWithBlock:^(BOOL succeed, FitCloudDailyGoalObject *goal, NSError *error) {
        NSLog(@"%d==%@", succeed, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.target = goal;
            weakSelf.targetLabel.text = [NSString stringWithFormat:@"%d", goal.stepCountGoal];
        });
    }];
}

- (IBAction)updateAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSString *defaultValue = [self.targetLabel.text stringByReplacingOccurrencesOfString:NSLocalizedString(@"step", nil) withString:@""];
    NSInteger index = [defaultValue integerValue];
    [BRStringPickerView showPickerWithTitle:NSLocalizedString(@"Step Target", nil) dataSourceArr:self.dataArr selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
        [weakSelf updateStepTarget:resultModel];
    }];
}

- (void)updateStepTarget:(BRResultModel *)model {
    __weak typeof(self) weakSelf = self;
    NSInteger stepGoal = [model.value integerValue];
    CGFloat distanceGoalInKM = self.target.distanceGoal;
    CGFloat caloryGoalInKCal = self.target.caloryGoal;
    
    [FitCloudKit setDailyGoalWithStepCount:(UInt32)(stepGoal) distance:(UInt32)(distanceGoalInKM*100000) calory:(UInt32)(caloryGoalInKCal*1000) timestamp:nil block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadTaget];
        });
        
    }];
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
@end
