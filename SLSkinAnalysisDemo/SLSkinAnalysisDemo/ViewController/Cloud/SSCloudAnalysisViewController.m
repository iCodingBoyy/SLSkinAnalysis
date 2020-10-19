//
//  SSCloudAnalysisViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSCloudAnalysisViewController.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#ifdef __QCloud__
    #import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>
#else
    #import <SLSkinAnalysis/SLSkinAnalysis.h>
#endif

@interface SSCloudAnalysisViewController ()
@property (nonatomic, strong) SLSAFaceDataAnalysisEngine *dataEngine;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation SSCloudAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.title = @"肤质分析";
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeConstraints];
    [self analysisFaceData];
}

- (void)makeConstraints {
    _textView = [[UITextView alloc]init];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textColor = [UIColor redColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

- (void)analysisFaceData {
    
    [QMUITips showLoading:@"正在进行肤质分析" inView:self.view];
    _dataEngine = [[SLSAFaceDataAnalysisEngine alloc]init];
#ifdef __QCloud__
    [_dataEngine analysisWithImageURL:self.imageURL result:^(NSDictionary * _Nonnull responseJSON, NSError * _Nonnull error) {
        [QMUITips hideAllTips];
        if (error) {
            NSLog(@"----error----%@",error);
            [QMUITips showError:error.localizedDescription];
            return;
        }
        // url解密
        NSLog(@"----responseJSON----%@",responseJSON);
        [QMUITips showSucceed:@"肤质信息分析成功"];
        if (responseJSON && [responseJSON isKindOfClass:[NSDictionary class]]) {
            NSString *string = [responseJSON modelDescription];
            self.textView.text = string;
        }
    }];
#else
    [_dataEngine analysisWithImageURL:self.imageURL result:^(NSDictionary * _Nonnull responseJSON, NSError * _Nonnull error) {
        [QMUITips hideAllTips];
        if (error) {
            NSLog(@"----error----%@",error);
            [QMUITips showError:error.localizedDescription];
            return;
        }
        NSLog(@"----responseJSON----%@",responseJSON);
        [QMUITips showSucceed:@"肤质信息分析成功"];
        if (responseJSON && [responseJSON isKindOfClass:[NSDictionary class]]) {
            NSString *string = [responseJSON modelDescription];
            self.textView.text = string;
        }
    }];
#endif
}
@end
