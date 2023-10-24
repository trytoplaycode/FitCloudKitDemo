//
//  FCWeatherViewController.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/27.
//

#import "FCWeatherViewController.h"
#import "FCDefinitions.h"
#import <Masonry.h>
#import "FCFuncListTableViewCell.h"
#import "FCCommenCellModel.h"
#import <BRPickerView.h>
#import <FitCloudKit/FitCloudKit.h>
#import <Toast.h>
#import "FCWeatherForecastViewController.h"

@interface FCWeatherViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *temperatureArr;
@property (nonatomic, strong) NSMutableArray *weatherArr;
@property (nonatomic, strong) NSMutableArray *pressureArr;
@property (nonatomic, strong) NSMutableArray *windScalArr;
@property (nonatomic, strong) NSMutableArray *visiableArr;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) NSMutableArray *forestArr;

@end

static NSString *identifier = @"list";

@implementation FCWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBar:NSLocalizedString(@"Weather", nil)];
    [self initialization];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initialization {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.sureButton];
}

- (WEATHERTYPE)getWeatherType {
    WEATHERTYPE type = WEATHERTYPE_UNKNOWN;
    FCCommenCellModel *model = self.dataArr[4];
    if ([model.value isEqualToString:self.weatherArr[0]]) {
        type = WEATHERTYPE_SUNNY;
    }else if ([model.value isEqualToString:self.weatherArr[1]]) {
        type = WEATHERTYPE_CLOUDY;
    }else if ([model.value isEqualToString:self.weatherArr[2]]) {
        type = WEATHERTYPE_OVERCAST;
    }else if ([model.value isEqualToString:self.weatherArr[3]]) {
        type = WEATHERTYPE_SHOWERS;
    }else if ([model.value isEqualToString:self.weatherArr[4]]) {
        type = WEATHERTYPE_THUNDERSHOWERSWITHHAIL;
    }else if ([model.value isEqualToString:self.weatherArr[5]]) {
        type = WEATHERTYPE_LIGHTRAIN;
    }else if ([model.value isEqualToString:self.weatherArr[6]]) {
        type = WEATHERTYPE_MHSRAIN;
    }else if ([model.value isEqualToString:self.weatherArr[7]]) {
        type = WEATHERTYPE_SLEET;
    }else if ([model.value isEqualToString:self.weatherArr[8]]) {
        type = WEATHERTYPE_LIGHTSNOW;
    }else if ([model.value isEqualToString:self.weatherArr[9]]) {
        type = WEATHERTYPE_HEAVYSNOW;
    }else if ([model.value isEqualToString:self.weatherArr[10]]) {
        type = WEATHERTYPE_SANDSTORM;
    }else if ([model.value isEqualToString:self.weatherArr[11]]) {
        type = WEATHERTYPE_FOGORHAZE;
    }
    
    return type;
}

- (void)sureAction {
    FitCloudWeatherObject *weather = [FitCloudWeatherObject new];
    FCCommenCellModel *cityModel = self.dataArr[0];
    weather.city = cityModel.value?:@"";
    FCCommenCellModel *tempModel = self.dataArr[1];
    weather.temperature = [tempModel.value integerValue];
    FCCommenCellModel *minTempModel = self.dataArr[2];
    weather.min = [minTempModel.value integerValue];
    FCCommenCellModel *maxTempModel = self.dataArr[3];
    weather.max = [maxTempModel.value integerValue];
    weather.weathertype = [self getWeatherType];
    FCCommenCellModel *pressureModel = self.dataArr[5];
    weather.pressure = [pressureModel.value intValue];
    FCCommenCellModel *windModel = self.dataArr[6];
    weather.windScale = [windModel.value integerValue];
    FCCommenCellModel *visModel = self.dataArr[7];
    weather.vis = [visModel.value integerValue];
    weather.forecast = @[self.forestArr];
    
    [FitCloudKit syncWeather:weather block:^(BOOL succeed, NSError *error) {
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
    [cell configCellStyle:FCCellStyleNormal];
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    cell.nameLabel.text = model.title;
    cell.valueLabel.text = model.value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCCommenCellModel *model = self.dataArr[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            [BRAddressPickerView showAddressPickerWithMode:BRAddressPickerModeCity selectIndexs:@[@(0)] isAutoSelect:NO resultBlock:^(BRProvinceModel * _Nullable province, BRCityModel * _Nullable city, BRAreaModel * _Nullable area) {
                model.value = city.name;
                [self.tableView reloadData];
            }];
        }
            break;
        case 1:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.temperatureArr selectIndex:100 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 2:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.temperatureArr selectIndex:100 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 3:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.temperatureArr selectIndex:100 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 4:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.weatherArr selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 5:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.pressureArr selectIndex:10 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 6:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.windScalArr selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 7:
        {
            [BRStringPickerView showPickerWithTitle:model.title dataSourceArr:self.visiableArr selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
                model.value = resultModel.value;
                [self.tableView reloadData];
            }];
        }
            break;
        case 8:
        {
            FCWeatherForecastViewController *weather = [FCWeatherForecastViewController new];
            weather.arr = self.forestArr;
            weakSelf(weakSelf);
            weather.refreshCallback = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    FCCommenCellModel *model = weakSelf.dataArr[8];
                    model.value = [NSString stringWithFormat:@"%ld%@", weakSelf.forestArr.count, NSLocalizedString(@"Day", nil)];
                    [weakSelf.tableView reloadData];
                });
            };
            [self.navigationController pushViewController:weather animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 懒加载
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
        NSArray *arr = @[NSLocalizedString(@"City", nil),
                         NSLocalizedString(@"Temperature", nil),
                         NSLocalizedString(@"Minimum Temperature", nil),
                         NSLocalizedString(@"Maximum Temperature", nil),
                         NSLocalizedString(@"Weather", nil),
                         NSLocalizedString(@"Pressure", nil),
                         NSLocalizedString(@"WindScale", nil),
                         NSLocalizedString(@"Visiable", nil),
                         NSLocalizedString(@"Forecast", nil)];
        for (NSInteger i = 0; i < arr.count; i++) {
            FCCommenCellModel *model = [FCCommenCellModel new];
            model.title = arr[i];
            [_dataArr addObject:model];
        }
    }
    
    return _dataArr;
}

- (NSMutableArray *)temperatureArr {
    if (!_temperatureArr) {
        _temperatureArr = @[].mutableCopy;
        for (NSInteger i = -100; i < 100; i++) {
            [_temperatureArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _temperatureArr;
}

- (NSMutableArray *)weatherArr {
    if (!_weatherArr) {
        _weatherArr = @[NSLocalizedString(@"Sunny", nil),NSLocalizedString(@"Cloudy", nil),NSLocalizedString(@"OverCast", nil),NSLocalizedString(@"Showers", nil),NSLocalizedString(@"ThunderShowersWithHail", nil),NSLocalizedString(@"LightRain", nil),NSLocalizedString(@"MHSRain", nil),NSLocalizedString(@"Sleet", nil),NSLocalizedString(@"LightSnow", nil),NSLocalizedString(@"HeavySnow", nil),NSLocalizedString(@"SANDSTORM", nil),NSLocalizedString(@"FOGORHAZE", nil),NSLocalizedString(@"UNKNOWN", nil)].mutableCopy;
    }
    
    return _weatherArr;
}


- (NSMutableArray *)pressureArr {
    if (!_pressureArr) {
        _pressureArr = @[].mutableCopy;
        for (NSInteger i = 0; i < 1001; i++) {
            [_pressureArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _pressureArr;
}


- (NSMutableArray *)windScalArr {
    if (!_windScalArr) {
        _windScalArr = @[].mutableCopy;
        for (NSInteger i = 1; i < 20; i++) {
            [_windScalArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _windScalArr;
}


- (NSMutableArray *)visiableArr {
    if (!_visiableArr) {
        _visiableArr = @[].mutableCopy;
        for (NSInteger i = 0; i < 100; i++) {
            [_visiableArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    return _visiableArr;
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

- (NSMutableArray *)forestArr {
    if (!_forestArr) {
        _forestArr = @[].mutableCopy;
    }
    
    return _forestArr;
}
@end
