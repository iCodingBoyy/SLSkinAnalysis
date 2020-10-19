//
//  SSURLInputViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSURLInputViewController.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import <QMUIKit/QMUIKit.h>
#import "SSCloudAnalysisViewController.h"

@interface SSURLInputViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) QMUITextView *textView;
@end

@implementation SSURLInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleView.title = @"URL输入";
    [self makeConstraints];
}

- (void)clickToAnalysisTextViewURL {
    if (self.textView.text.length <= 0) {
        return;
    }
    SSCloudAnalysisViewController *cloudAnalysis = [[SSCloudAnalysisViewController alloc]init];
    cloudAnalysis.imageURL = self.textView.text;
    [self.navigationController pushViewController:cloudAnalysis animated:YES];
}

- (void)clickToAnalysisURL1 {
    SSCloudAnalysisViewController *controller = [[SSCloudAnalysisViewController alloc]init];
//    controller.imageURL = @"https://community-s3-website.marykay.com.cn/PROD/NTS/SkinAnalyzerNative-Android-prod/3f0f022c-01ed-45c4-b9cc-563de67ffa05/8dbb84f0-09a4-43aa-8109-09d398810dad2020-06-08-10-31-52-482_ar.jpg";
//    controller.imageURL = @"https://dev-resource-mx-website.mkapps.com/STAG/NTS/SkinAnalyzerNative-Android-stg/cf1fcde9-004f-47d9-8f82-84546a44f438/db737da0-a64a-440f-a4d2-b3e566bdace3pic_quark_1586508883884.jpg";
//    controller.imageURL = @"http://cos.clife.net/aad9f2829ac14c6899ab222974aa522a.jpeg";
    controller.imageURL = @"https://dev-resource-mx-website.mkapps.com/STAG/NTS/SkinAnalyzerNative-Android-stg/cf1fcde9-004f-47d9-8f82-84546a44f438/db737da0-a64a-440f-a4d2-b3e566bdace3pic_quark_1586508883884.jpg";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)clickToAnalysisURL2 {
    SSCloudAnalysisViewController *controller = [[SSCloudAnalysisViewController alloc]init];
//    controller.imageURL = @"https://community-s3-website.marykay.com.cn/PROD/NTS/SkinAnalyzerNative-Android-prod/cdd7392e-a454-4782-9c6c-b6977bf6aa2e/3614c974-8954-4378-a6a3-392ec33163522020-06-08-10-40-56-671_ar.jpg";
//    controller.imageURL = @"https://dev-resource-mx-website.mkapps.com/STAG/NTS/SkinAnalyzerNative-Android-stg/cf1fcde9-004f-47d9-8f82-84546a44f438/db737da0-a64a-440f-a4d2-b3e566bdace3pic_quark_1586508883884.jpg";
//    controller.imageURL = @"https://mkcorp-s3-us-east-1-ebiz-dev-mdm-la-sa-storage.s3.us-east-1.amazonaws.com/DEV/NTS/SkinAnalyzerNative-Android-stg/01db1e2b-90a1-415d-b124-2f46eb69fdb3/517d9c37-fb6a-4a2f-b455-96cce10b6a3cpic_quark_1587112824839.jpg";
    controller.imageURL = @"https://mkcorp-s3-us-east-1-ebiz-dev-mdm-la-sa-storage.s3.us-east-1.amazonaws.com/DEV/NTS/SkinAnalyzerNative-Android-stg/01db1e2b-90a1-415d-b124-2f46eb69fdb3/517d9c37-fb6a-4a2f-b455-96cce10b6a3cpic_quark_1587112824839.jpg";
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)makeConstraints {
    @weakify(self);
    _scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    _contentView = [[UIView alloc]init];
    [self.scrollView addSubview:_contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    label.text = @"输入图片url";
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView).offset(20);
        make.left.equalTo(self.contentView).offset(16);
    }];
    
    _textView = [[QMUITextView alloc]init];
    _textView.placeholder = @"请输入带有单个高清人脸的图片url";
    _textView.layer.masksToBounds = YES;
    _textView.layer.cornerRadius = 8.0;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.layer.borderWidth = 1.0;
    [self.contentView addSubview:_textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(label.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.equalTo(@(200));
    }];
    
    QMUIFillButton *button = [[QMUIFillButton alloc]init];
    button.fillColor = [UIColor redColor];
    button.titleTextColor = [UIColor whiteColor];
    [button setTitle:@"开始分析" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToAnalysisTextViewURL) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.equalTo(@(120));
        make.height.equalTo(@(34));
    }];
    
    UILabel *label1 = [[UILabel alloc]init];
    label1.font = [UIFont systemFontOfSize:16];
    label1.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    label1.text = @"url1";
    [self.contentView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(button.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(16);
    }];
    
    UIImageView *imageView1 = [[UIImageView alloc]init];
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageView1];
    [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(label1.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.equalTo(@(200));
    }];
    NSString *url1 = @"https://dev-resource-mx-website.mkapps.com/STAG/NTS/SkinAnalyzerNative-Android-stg/cf1fcde9-004f-47d9-8f82-84546a44f438/db737da0-a64a-440f-a4d2-b3e566bdace3pic_quark_1586508883884.jpg";
    [imageView1 setImageURL:[NSURL URLWithString:url1]];
    
    QMUIFillButton *button1 = [[QMUIFillButton alloc]init];
    button1.fillColor = [UIColor redColor];
    button1.titleTextColor = [UIColor whiteColor];
    [button1 setTitle:@"开始分析" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(clickToAnalysisURL1) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(imageView1.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.equalTo(@(120));
        make.height.equalTo(@(34));
    }];
    
    UILabel *label2 = [[UILabel alloc]init];
    label2.font = [UIFont systemFontOfSize:16];
    label2.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    label2.text = @"url2";
    [self.contentView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(button1.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(16);
    }];
    
    UIImageView *imageView2 = [[UIImageView alloc]init];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageView2];
    [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(label2.mas_bottom).offset(10);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.equalTo(@(200));
    }];
    NSString *url2 = @"https://mkcorp-s3-us-east-1-ebiz-dev-mdm-la-sa-storage.s3.us-east-1.amazonaws.com/DEV/NTS/SkinAnalyzerNative-Android-stg/01db1e2b-90a1-415d-b124-2f46eb69fdb3/517d9c37-fb6a-4a2f-b455-96cce10b6a3cpic_quark_1587112824839.jpg";
    [imageView2 setImageURL:[NSURL URLWithString:url2]];
    
    QMUIFillButton *button2 = [[QMUIFillButton alloc]init];
    button2.fillColor = [UIColor redColor];
    button2.titleTextColor = [UIColor whiteColor];
    [button2 setTitle:@"开始分析" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(clickToAnalysisURL2) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(imageView2.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.equalTo(@(120));
        make.height.equalTo(@(34));
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button2.mas_bottom).offset(60);
    }];
}

@end
