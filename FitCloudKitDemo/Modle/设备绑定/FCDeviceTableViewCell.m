//
//  FCDeviceTableViewCell.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/7/20.
//

#import "FCDeviceTableViewCell.h"
#import "FCDefinitions.h"
#import <Masonry.h>
@interface FCDeviceTableViewCell()

@property (strong, nonatomic) FitCloudPeripheral *peripheral;
@property (assign, nonatomic) BOOL showStatus;

@property (strong, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *macLabel;
@property (strong, nonatomic) IBOutlet UILabel *rssiLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end

@implementation FCDeviceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    [self.contentView addSubview:self.deviceNameLabel];
    [self.contentView addSubview:self.rssiLabel];
    [self.contentView addSubview:self.macLabel];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.activity];
    
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [self.rssiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.deviceNameLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.deviceNameLabel.mas_right).offset(10);
    }];
    [self.macLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.macLabel.mas_centerY).offset(0);
        make.left.mas_equalTo(self.macLabel.mas_right).offset(10);
    }];
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.macLabel.mas_centerY).offset(0);
    }];
}

- (void)configDevice:(FitCloudPeripheral *)peripheral showStatus:(BOOL)showStatus {
//    self.deviceNameLabel.text = peripheral.peripheral.name == nil || peripheral.peripheral.name.length == 0 ? @"UNKNOWN" : peripheral.peripheral.name;
//    if([self.deviceNameLabel.text hasPrefix:@"H"])
//    {
//        self.deviceNameLabel.text = [self.deviceNameLabel.text substringFromIndex:1];
//    }
//    self.rssiLabel.text = peripheral.paired ? @"RSSI" : [NSString stringWithFormat:@"RSSI:%@", peripheral.RSSI];
//    self.macLabel.text = peripheral.paired ? NSLocalizedString(@"SYSTEM PAIRED", nil) : peripheral.macAddr;
    self.peripheral = peripheral;
    _showStatus = showStatus;
    self.deviceNameLabel.text = peripheral.peripheral.name == nil || peripheral.peripheral.name.length == 0 ? @"UNKNOWN" : peripheral.peripheral.name;
    if([self.deviceNameLabel.text hasPrefix:@"H"])
    {
        self.deviceNameLabel.text = [self.deviceNameLabel.text substringFromIndex:1];
    }
    self.rssiLabel.text = peripheral.paired ? @"" : [NSString stringWithFormat:@"RSSI:%@", peripheral.RSSI];
    self.macLabel.text = peripheral.paired ? NSLocalizedString(@"SYSTEM PAIRED", nil) : peripheral.macAddr;
    if(!showStatus)
    {
        if(self.activity.animating)[self.activity stopAnimating];
        self.statusLabel.hidden = self.activity.hidden = YES;
    }
    else
    {
        CBPeripheralState state = peripheral.peripheral.state;
        if(state == CBPeripheralStateConnecting || state == CBPeripheralStateDisconnecting)
        {
            self.activity.hidden = NO;
            self.statusLabel.hidden = YES;
            [self.activity startAnimating];
        }
        else
        {
            if(self.activity.animating)[self.activity stopAnimating];
            self.activity.hidden = YES;
            self.statusLabel.hidden = NO;
            if(state == CBPeripheralStateConnected && !peripheral.paired)
            {
                self.statusLabel.textColor = RGB(0x00, 0xB2, 0x00);
                self.statusLabel.text = NSLocalizedString(@"CONNECTED", nil);
            }
            else if(state == CBPeripheralStateDisconnected || peripheral.paired)
            {
                self.statusLabel.textColor = [UIColor lightGrayColor];
                self.statusLabel.text = NSLocalizedString(@"DISCONNECTED", nil);
            }
        }
    }
}

#pragma mark - 懒加载
- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [UILabel new];
        _deviceNameLabel.textColor = [UIColor blackColor];
        _deviceNameLabel.font = FONT_REGULAR(16);
        _deviceNameLabel.text = NSLocalizedString(@"Device Name", nil);
    }
    
    return _deviceNameLabel;
}

- (UILabel *)rssiLabel {
    if (!_rssiLabel) {
        _rssiLabel = [UILabel new];
        _rssiLabel.textColor = UIColorFromRGB(0x999999, 1.f);
        _rssiLabel.textAlignment = NSTextAlignmentRight;
        _rssiLabel.text = @"RSSI:0";
    }
    
    return _rssiLabel;
}

- (UILabel *)macLabel {
    if (!_macLabel) {
        _macLabel = [UILabel new];
        _macLabel.textColor = UIColorFromRGB(0x999999, 1.f);
        _macLabel.font = FONT_REGULAR(15);
        _macLabel.text = @"00:00:00:00";
    }
    
    return _macLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.textColor = UIColorFromRGB(0x999999, 1.f);
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.text = @"";
    }
    
    return _statusLabel;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _activity;
}
@end
