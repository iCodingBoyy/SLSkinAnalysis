//
//  SSRootViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSRootViewController.h"
#import <Masonry/Masonry.h>
#import <QMUIKit/QMUIKit.h>
#import <YYKit/YYKit.h>
#import "SSURLInputViewController.h"
#import "SSStillImageViewController.h"
#import "SSCameraViewController.h"
#if defined(__QCloud__) || defined(__HETSkinAnalysis__)
    #import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>
#else
    #import <SLSkinAnalysis/SLSkinAnalysis.h>
#endif


@interface SSRootViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end


@implementation SSRootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.title = @"拍照测肤";
    [self makeConstraints];
    
#if defined(__HETSkinAnalysis__)
    // 老版本的拍照测肤SDK默认配置
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration defaultConfiguration];
    [config registerWithAppId:@"31298" andSecret:@"145a2540f00147e89dc5e33b6842f74c"];
    [config setYuvLightDetectionEnable:YES];
    [config setDistanceDetectionEnable:YES];
    [config setMaxDetectionDistance:0.85f];
    [config setMinDetectionDistance:0.45f];
    [config setMinYUVLight:60];
    [config setMaxYUVLight:220];
    [config setFaceBoundsDetectionEnable:YES];
    [config setStandardFaceCheckEnable:YES];
    [config setYuvLightDetectionEnable:YES];
    [config setDistanceDetectionEnable:YES];
    [config setCameraBounds:[UIScreen mainScreen].bounds];
#elif defined(__QCloud__)
    //     com.het.skinAnalysis
    SLSARegister(@"31298", @"145a2540f00147e89dc5e33b6842f74c");
#else
    // com.meilianhui.beauty
    SLSARegister(@"31486", @"3438376d97a1486998304170f391a07a");
#endif
}

- (void)makeConstraints {
//    @weakify(self);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"相机拍照";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"静态图片";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"URL输入";
    }
    else {
        cell.textLabel.text = @"设置";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SSCameraViewController *camera = [[SSCameraViewController alloc]init];
        camera.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:camera animated:YES];
    }
    else if (indexPath.row == 1) {
        SSStillImageViewController *stillImage = [[SSStillImageViewController alloc]init];
        stillImage.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:stillImage animated:YES];
    }
    else if (indexPath.row == 2) {
        SSURLInputViewController *urlInput = [[SSURLInputViewController alloc]init];
        urlInput.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:urlInput animated:YES];
    }
    else {
        
    }
}


#pragma mark - Getter

- (UITableView*)tableView
{
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0.0;
    _tableView.estimatedSectionHeaderHeight = 0.0;
    _tableView.estimatedSectionFooterHeight = 0.0;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    return _tableView;
}
@end
