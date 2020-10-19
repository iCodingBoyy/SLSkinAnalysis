//
//  SSStillImageViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSStillImageViewController.h"
#import <Masonry/Masonry.h>
#import "SSNavigationController.h"
#import "UIImage+SSFixed.h"
#import "SSCloudAnalysisViewController.h"
#ifdef __QCloud__
    #import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>
#else
    #import <SLSkinAnalysis/SLSkinAnalysis.h>
#endif


@interface SSStillImageViewController ()<QMUIAlbumViewControllerDelegate,QMUIImagePickerViewControllerDelegate,
QMUIImagePickerPreviewViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SLSAFaceDataAnalysisEngine *dataEngine;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation SSStillImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleView.title = @"静态图片";
    [self makeConstraints];
    [self analysisStillImage];
    
}

- (void)analysisStillImage {
//    SStillImageAnalysisOptions options = SSStillImageAnalysisAll;
    
    // 静态图片可用性分析主要用于对图片进行筛选，提高服务器分析成功率，如果没有特殊需要可以不进行处理
    SSStillImageAnalysisOptions options = SSStillImageAnalysisFaceFeature;
    options = (options | SSStillImageAnalysisSize);
    options = (options | SSStillImageAnalysisAspectRedio);
    options = (options | SSStillImageAnalysisPixels);
    options = (options | SSStillImageAnalysisFaceShelters);
    
    SLSAStillImageAnalysisConfiguration *config = [[SLSAStillImageAnalysisConfiguration alloc]init];
    // 服务器肤质分析对图片的要求不是很严格，因为可以不设置太多限制
    config.maxPixels = 5000000;
    config.maxImageWidth = 2000;
    config.maxImageHeight = 2500;
    config.options = options;
    SLSAStillImageAnalysisEngine *analysisEngine = [[SLSAStillImageAnalysisEngine alloc]initWithConfiguration:config];
    
    NSMutableString *display = [[NSMutableString alloc]init];
    NSError *error;
    BOOL ret = [analysisEngine isValidStillImage:self.imageView.image error:&error];
    if (!ret) {
        [display appendFormat:@"---照片不满足肤质分析要求----\n"];
        [display appendFormat:@"----%@----\n",error.localizedDescription];
    }
    [display appendFormat:@"\n\n\n"];
    
    // 遮挡物检测可以放到子线程处理
    NSError *shelterError;
    NSArray *faceShelters = [analysisEngine analysisFaceShelters:self.imageView.image error:&shelterError];
    [display appendFormat:@"--检测人脸遮挡物--\n"];
    if (shelterError) {
        [display appendFormat:@"---遮挡物错误---%@\n",shelterError.localizedDescription];
        self.textView.text = display;
        return;
    }
    if (faceShelters.count > 0) {
        for (SLSAFaceShelterItem *item in faceShelters) {
            [display appendFormat:@"----%@----\n",item.description];
        }
    }
    else {
        [display appendFormat:@"---没有检测到遮挡物----\n"];
    }
    self.textView.text = display;
}

#pragma mark - constraints

- (void)makeConstraints {
    UIImage *image = [UIImage imageNamed:@"frame.jpg"];
    _imageView = [[UIImageView alloc]initWithImage:image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
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
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(clickToPickPhoto)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithTitle:@"相机" style:UIBarButtonItemStylePlain target:self action:@selector(clickToShowCamera)];
    self.navigationItem.rightBarButtonItems = @[item1,item2];
    
    QMUIFillButton *uploadButton = [[QMUIFillButton alloc]init];
    uploadButton.titleTextColor = [UIColor whiteColor];
    uploadButton.fillColor = [UIColor qmui_colorWithHexString:@"#FF4275"];
    [uploadButton setTitle:@"上传图片" forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(clickToUploadImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadButton];
    [uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-20);
        make.height.equalTo(@(34));
    }];
}

- (void)clickToUploadImage {
    
#ifdef __QCloud__
    [QMUITips showLoading:@"图片上传中" inView:self.view];
    _dataEngine = [[SLSAFaceDataAnalysisEngine alloc]init];
    [_dataEngine uploadImage:self.imageView.image progress:^(float progress) {
        NSLog(@"--上传进度--%@",@(progress));
    } result:^(NSString * _Nonnull imageURL, NSError * _Nonnull error) {
        [QMUITips hideAllTips];
        if (error) {
            NSLog(@"---上传失败--%@",error);
            [QMUITips showError:error.localizedDescription];
            return;
        }
        NSLog(@"---上传成功--%@",imageURL);
        SLSkinAnalysisDecryptQCloudImageURL(imageURL, ^(NSString *decryptedURL, NSError *error) {
            if (error) {
                NSLog(@"--图片解密错误--%@",error);
                return;
            }
            NSLog(@"--图片解密成功--%@",decryptedURL);
        });
        SSCloudAnalysisViewController *cloudAnalysis = [[SSCloudAnalysisViewController alloc]init];
        cloudAnalysis.imageURL = imageURL;
        [self.navigationController pushViewController:cloudAnalysis animated:YES];
    }];
#else
    // 自行上传图片到云服务器
    NSString *imageURL = @"你上传的图片url";
    SSCloudAnalysisViewController *cloudAnalysis = [[SSCloudAnalysisViewController alloc]init];
    cloudAnalysis.imageURL = imageURL;
    [self.navigationController pushViewController:cloudAnalysis animated:YES];
#endif
    
}

#pragma mark - 照片选取

- (void)clickToShowCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
//    image = [image qmui_imageResizedInLimitedSize:CGSizeMake(2000, 2000) resizingMode:QMUIImageResizingModeScaleAspectFit];
    image = [image ssfixedOrientation];
    self.imageView.image = image;
    [self analysisStillImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)clickToPickPhoto {
    QMUIAlbumViewController *albumViewController = [[QMUIAlbumViewController alloc] init];
    albumViewController.albumViewControllerDelegate = self;
    albumViewController.contentType = QMUIAlbumContentTypeOnlyPhoto;
    albumViewController.title = @"选取人脸照片";
    [albumViewController pickLastAlbumGroupDirectlyIfCan];
    
    SSNavigationController *navigationController = [[SSNavigationController alloc]initWithRootViewController:albumViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}


#pragma mark - QMUIAlbumViewControllerDelegate

- (QMUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(QMUIAlbumViewController *)albumViewController {
    
    QMUIImagePickerViewController *imagePickerViewController = [[QMUIImagePickerViewController alloc] init];
    imagePickerViewController.imagePickerViewControllerDelegate = self;
    imagePickerViewController.maximumSelectImageCount = 1;
    imagePickerViewController.allowsMultipleSelection = NO;
    return imagePickerViewController;
    
}

- (void)albumViewControllerDidCancel:(QMUIAlbumViewController *)albumViewController {
    
}

#pragma mark - <QMUIImagePickerViewControllerDelegate>

- (void)imagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController didSelectImageWithImagesAsset:(QMUIAsset *)imageAsset afterImagePickerPreviewViewControllerUpdate:(QMUIImagePickerPreviewViewController *)imagePickerPreviewViewController {
    UIImage *orginImage = [imageAsset originImage];
//    orginImage = [orginImage qmui_imageResizedInLimitedSize:CGSizeMake(2000, 2000) resizingMode:QMUIImageResizingModeScaleAspectFit];
    orginImage = [orginImage ssfixedOrientation];
    self.imageView.image = orginImage;
    [self analysisStillImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerViewControllerDidCancel:(QMUIImagePickerViewController *)imagePickerViewController {
    
}

@end
