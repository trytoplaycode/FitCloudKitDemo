//
//  FCDailLibraryCollectionViewCell.m
//  FitCloudKitDemo
//
//  Created by Jasper on 2023/8/9.
//

#import "FCDailLibraryCollectionViewCell.h"
#import <Masonry.h>
#import <SDWebImage.h>
@interface FCDailLibraryCollectionViewCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *selectImageView;

@end

@implementation FCDailLibraryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(5);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
            make.top.mas_equalTo(self.contentView.mas_top).offset(5);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        }];
        [self.iconImageView addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.iconImageView.mas_right).offset(-10);
            make.top.mas_equalTo(self.iconImageView.mas_top).offset(10);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        self.selectImageView.hidden = YES;
    }
    
    return self;
}

- (void)configDailLibrary:(FCDialLibraryModel *)model {
    self.selectImageView.hidden = !model.isSelected;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl?:@""] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
}

- (void)configDail:(FCCommenCellModel *)model {
    self.selectImageView.hidden = !model.isSelected;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.value?:@""] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
}
#pragma mark - 懒加载
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconImageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [UIImageView new];
        _selectImageView.image = [UIImage imageNamed:@"choose"];
    }
    
    return _selectImageView;
}
@end
