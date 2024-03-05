//
//  FCScreenDisplayViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/28.
//

#import "FCScreenDisplayViewController.h"
#import "FCDefinitions.h"
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
@interface FCScreenDisplayViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *sureButton;
@end

static NSString *identifier = @"display";
@implementation FCScreenDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Screen Display", nil)];
    [self initialization];
    [self loadScreenDisplay];
}

- (void)loadScreenDisplay {
    weakSelf(weakSelf);
    [FitCloudKit getScreenDisplaySettingWithBlock:^(BOOL succeed, FITCLOUDSCREENDISPLAY sdSetting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i = 0; i < weakSelf.dataArr.count; i++) {
                FCCommenCellModel *model = weakSelf.dataArr[i];
                FITCLOUDSCREENDISPLAY current = FITCLOUDSCREENDISPLAY_NONE;
                if (i == 0) {
                    current = FITCLOUDSCREENDISPLAY_DATETIME;
                }else if (i == 1) {
                    current = FITCLOUDSCREENDISPLAY_STEPS;
                }else if (i == 2) {
                    current = FITCLOUDSCREENDISPLAY_DISTANCE;
                }else if (i == 3) {
                    current = FITCLOUDSCREENDISPLAY_CALORIES;
                }else if (i == 4) {
                    current = FITCLOUDSCREENDISPLAY_SLEEP;
                }else if (i == 5) {
                    current = FITCLOUDSCREENDISPLAY_HEARTRATE;
                }else if (i == 6) {
                    current = FITCLOUDSCREENDISPLAY_BLOODOXYGEN;
                }else if (i == 7) {
                    current = FITCLOUDSCREENDISPLAY_BLOODPRESSURE;
                }else if (i == 8) {
                    current = FITCLOUDSCREENDISPLAY_WEATHERFORECAST;
                }else if (i == 9) {
                    current = FITCLOUDSCREENDISPLAY_FINDIPHONE;
                }else if (i == 10) {
                    current = FITCLOUDSCREENDISPLAY_MACID;
                }else if (i == 11) {
                    current = FITCLOUDSCREENDISPLAY_UV;
                }else if (i == 12) {
                    current = FITCLOUDSCREENDISPLAY_DATETIME;
                }else if (i == 13) {
                    current = FITCLOUDSCREENDISPLAY_EARTHMAGNETICFIELD;
                }else if (i == 14) {
                    current = FITCLOUDSCREENDISPLAY_STOPWATCH;
                }
                model.value = [NSString stringWithFormat:@"%d", (sdSetting & current) == current ? 1 : 0];
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

- (void)switchAction:(UISwitch *)switchs {
    NSInteger index = switchs.tag - 1000;
    FCCommenCellModel *model = self.dataArr[index];
    model.value = [NSString stringWithFormat:@"%d", switchs.isOn ? 1 :0];
}

- (void)sureAction {
    FITCLOUDSCREENDISPLAY value = FITCLOUDSCREENDISPLAY_NONE;

    BOOL select = NO;
    for (FCCommenCellModel *model in self.dataArr) {
        if ([model.value intValue] == 1) {
            select = YES;
            break;
        }
    }
    
    if (!select) {
        value = FITCLOUDSCREENDISPLAY_NONE;
    }
    
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        FCCommenCellModel *model = self.dataArr[i];
        if ([model.value isEqualToString:@"1"]) {
            FITCLOUDSCREENDISPLAY current = FITCLOUDSCREENDISPLAY_NONE;
            if (i == 0) {
                current = FITCLOUDSCREENDISPLAY_DATETIME;
            }else if (i == 1) {
                current = FITCLOUDSCREENDISPLAY_STEPS;
            }else if (i == 2) {
                current = FITCLOUDSCREENDISPLAY_DISTANCE;
            }else if (i == 3) {
                current = FITCLOUDSCREENDISPLAY_CALORIES;
            }else if (i == 4) {
                current = FITCLOUDSCREENDISPLAY_SLEEP;
            }else if (i == 5) {
                current = FITCLOUDSCREENDISPLAY_HEARTRATE;
            }else if (i == 6) {
                current = FITCLOUDSCREENDISPLAY_BLOODOXYGEN;
            }else if (i == 7) {
                current = FITCLOUDSCREENDISPLAY_BLOODPRESSURE;
            }else if (i == 8) {
                current = FITCLOUDSCREENDISPLAY_WEATHERFORECAST;
            }else if (i == 9) {
                current = FITCLOUDSCREENDISPLAY_FINDIPHONE;
            }else if (i == 10) {
                current = FITCLOUDSCREENDISPLAY_MACID;
            }else if (i == 11) {
                current = FITCLOUDSCREENDISPLAY_UV;
            }else if (i == 12) {
                current = FITCLOUDSCREENDISPLAY_DATETIME;
            }else if (i == 13) {
                current = FITCLOUDSCREENDISPLAY_EARTHMAGNETICFIELD;
            }else if (i == 14) {
                current = FITCLOUDSCREENDISPLAY_STOPWATCH;
            }
            if (value == FITCLOUDSCREENDISPLAY_NONE) {
                value = current;
            }else {
                value = value | current;
            }
        }
    }
    
    [FitCloudKit setScreenDisplay:value block:^(BOOL succeed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OpResultToastTip(self.view, succeed);
        });
    }];

}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFuncListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configCellStyle:FCCellStyleSwitchs];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.switchs.tag = indexPath.row + 1000;
    [cell.switchs setOn:[model.value boolValue]];
    
    [cell.switchs addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kScreenHeight-kTopBarHeight-100)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        [_tableView registerClass:[FCFuncListTableViewCell class] forCellReuseIdentifier:identifier];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
        NSArray *arr = @[NSLocalizedString(@"Date Time", nil),NSLocalizedString(@"Steps", nil),NSLocalizedString(@"Distance", nil),NSLocalizedString(@"Calories", nil),NSLocalizedString(@"Sleep", nil),NSLocalizedString(@"Heart Rate", nil),NSLocalizedString(@"Blood Oxygen", nil),NSLocalizedString(@"Blood Pressure", nil),NSLocalizedString(@"Weather Forecast", nil),NSLocalizedString(@"Find iPhone", nil),NSLocalizedString(@"Mac ID", nil),NSLocalizedString(@"UV", nil),NSLocalizedString(@"Geomagnetism", nil),NSLocalizedString(@"Stop Watch", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame)+20, kScreenWidth-100, 50);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:NSLocalizedString(@"Set", nil) forState:UIControlStateNormal];
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 8;
        _sureButton.backgroundColor = [UIColor systemBlueColor];
        [_sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sureButton;
}
@end
