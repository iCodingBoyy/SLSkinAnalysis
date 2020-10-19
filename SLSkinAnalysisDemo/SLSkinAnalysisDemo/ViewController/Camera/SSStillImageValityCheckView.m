//
//  SSStillImageValityCheckView.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import "SSStillImageValityCheckView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface SSStillImageValityCheckView ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *checkingLabel;
@end

@implementation SSStillImageValityCheckView
@synthesize checking = _checking;

- (BOOL)isChecking {
    return _checking;
}

- (void)setChecking:(BOOL)checking {
    _checking = checking;
    _checkingLabel.hidden = !_checking;
}

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

- (void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    _textLabel = [[UILabel alloc]init];
    _textLabel.font = [UIFont systemFontOfSize:15];
    _textLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self).offset(25);
        make.left.right.equalTo(self);
    }];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.titleLabel.font = [UIFont systemFontOfSize:18];
    _button.backgroundColor = [UIColor qmui_colorWithHexString:@"ff4275"];
    [_button setTitleColor:[UIColor qmui_colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    [_button setTitle:@"重新拍照" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(clickToReset) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self);
        make.top.equalTo(self.textLabel.mas_bottom).offset(21);
        make.width.equalTo(@(120));
        make.height.equalTo(@(44));
    }];
    
    _checkingLabel = [[UILabel alloc]init];
    _checkingLabel.text = @"正在识别照片...";
    _checkingLabel.backgroundColor = [UIColor whiteColor];
    _checkingLabel.font = [UIFont systemFontOfSize:15];
    _checkingLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _checkingLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_checkingLabel];
    [self.checkingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
}

- (void)clickToReset {
    if (self.buttonDidClickBlock) {
        self.buttonDidClickBlock();
    }
}

- (void)setText:(NSString*)text {
    _textLabel.text = text;
}
@end

