//
//  FCTodySportsDataViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/23.
//

#import "FCTodySportsDataViewController.h"
#import <FitCloudKit/FitCloudKit.h>

@interface FCTodySportsDataViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;

@end

@implementation FCTodySportsDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Sports Data Today", nil)];
    [self setNavBackWhite];
    [self getSportsDataToday];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getSportsDataToday {
    __weak typeof(self) weakSelf = self;
    [FitCloudKit requestHealthAndSportsDataTodayWithBlock:^(BOOL succeed, NSString* userId, FitCloudDailyHealthAndSportsDataObject *dataObject, NSError *error) {
        if([dataObject isKindOfClass:[FitCloudDailyHealthAndSportsDataObject class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.stepLabel.text = [NSString stringWithFormat:@"%@%@", @(dataObject.steps), NSLocalizedString(@"step", nil)];
                weakSelf.distanceLabel.text = [NSString stringWithFormat:@"%@%@", @(dataObject.distance), NSLocalizedString(@"m", nil)];
                weakSelf.heartRateLabel.text = [NSString stringWithFormat:@"%@%@", @(dataObject.averageHeartRate), NSLocalizedString(@"bmp", nil)];
                weakSelf.caloriesLabel.text = [NSString stringWithFormat:@"%@%@", @(dataObject.calory),NSLocalizedString(@"cal", nil)];
            });
        }
        
    }];
}
@end
