//
//  SSBufferAnalysisStateView.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import "SSBufferAnalysisStateView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface SSBufferAnalysisStateView ()
@property (nonatomic, strong) QMUIButton *statusButton;
@end

@implementation SSBufferAnalysisStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeZero;
    
    CGSize titleSize = self.titleLabel.intrinsicContentSize;
    CGSize statusSize = self.statusButton.intrinsicContentSize;
    size.width = MAX(titleSize.width, statusSize.width);
    size.height = titleSize.height + statusSize.height + 5;
    return size;
}

- (void)setUp
{
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
    
    @weakify(self);
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.textColor = [UIColor qmui_colorWithHexString:@"#FFFFFF"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_centerY).offset(-2.5);
    }];
    _statusButton = [[QMUIButton alloc]init];
    _statusButton.spacingBetweenImageAndTitle = 5.0;
    _statusButton.imagePosition = QMUIButtonImagePositionRight;
    _statusButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:_statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_centerY).offset(2.5);
    }];
}

- (void)setStateValid:(BOOL)isValid description:(NSString*)description {
    [self.statusButton setTitle:description forState:UIControlStateNormal];
    if (isValid) {
        [self.statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.statusButton setImage:[UIImage imageNamed:@"ico_camera_ok"] forState:UIControlStateNormal];
    }
    else {
        [self.statusButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FF4275"] forState:UIControlStateNormal];
        [self.statusButton setImage:nil forState:UIControlStateNormal];
    }
    [self.statusButton setNeedsLayout];
    [self.statusButton layoutIfNeeded];
}

@end
