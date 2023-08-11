//
//  FCSportTypeTableViewCell.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCSportTypeTableViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry.h>
#import "FCDefinitions.h"
@interface FCSportTypeTableViewCell()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *sizeLabel;
@property (strong, nonatomic) UIImageView *selectImageView;

@end

@implementation FCSportTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.selectImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50);
    }];
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-50);
    }];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)configSport:(FCDialLibraryModel *)model {
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.iconUrl?:@""]];
    self.nameLabel.text = model.sportUiName;
    self.sizeLabel.text = [NSString stringWithFormat:@"%.2fKB", model.binSize/1024.f];
    self.selectImageView.image = model.isSelected ? IMAGENAME(@"selected") : IMAGENAME(@"unselected");
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = UIColorFromRGB(0x333333, 1.f);
        _nameLabel.font = FONT_MEDIUM(16);
    }
    
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [UILabel new];
        _sizeLabel.textColor = UIColorFromRGB(0x999999, 1.f);
        _sizeLabel.font = FONT_REGULAR(15);
    }
    
    return _sizeLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [UIImageView new];
        _selectImageView.image = IMAGENAME(@"unselected");
    }
    
    return _selectImageView;
}
@end
