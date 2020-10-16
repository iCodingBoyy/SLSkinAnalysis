


# SLSkinAnalysisQCloud V2.0.0 SDK iOS平台接入指南 

-----

`SLSkinAnalysisQCloud` 是 `HETSkinAnalysisSDK` 的升级版本，改进架构并优化了拍照性能和体验，内部集成了 `QCloud` 云服务`。

![版本](https://img.shields.io/badge/version-2.0.0-brightgreen.svg)      ![Platform](https://img.shields.io/badge/platform-iOS%209.0+-orange.svg)     ![Build Status](https://img.shields.io/badge/build-passing-red.svg)


# 变更记录说明

<table width="100%" style="border-spacing: 0;  border-collapse: collapse;">
    <thead>
        <tr>
            <td>日期</td>
            <td>版本号</td>
            <td>作者</td>
            <td>描述</td>
        </tr>
    </thead>
    <tbody> 
        <tr>
            <td>2020年09月29日</td>
            <td>2.0.0</td>
            <td>马远征</td>
            <td>改进拍照测肤SDK架构，并集成了人脸遮挡物检测功能</td>
        </tr>
    </tbody>
</table>

---
## 一、平台授权

`SDK` 需要配置相应的 `AppId` 和 `AppSecret` ，请联系相关客服人员获取。

---
## 二、快速集成

SDK支持 iOS 9.0 以上设备，请保持Xcode开发工具升级到最新版本。

### 1、资源下载

>- [x] 肤质分析 SDK 下载  [SLSkinAnalysisQCloud.framework](https://github.com/iCodingBoyy/SLSkinAnalysis.git)
>- [x] Demo下载 [SLSkinAnalysisDemo](https://github.com/iCodingBoyy/SLSkinAnalysis.git)
>- [x] 腾讯云存储下载 [QCloud](https://github.com/tencentyun/qcloud-sdk-ios/releases)

### 2、Xcode 集成

1、将`SLSkinAnalysisQCloud.framework` 拖到你的项目中，将 `Embed` 设置为 `Embed & Sign`

2、前往 [ OpenCV ](https://opencv.org/releases/)下载 `opencv2.framework`，选择3.4.x版本即可。

3、前往腾讯云下载 [QCloud](https://github.com/tencentyun/qcloud-sdk-ios/releases) 拖入到工程，你也可以通过`Cocoapods`集成腾讯云`QCloud`，具体见教程 [iOS SDK文档](https://cloud.tencent.com/document/product/436/11280)

4、添加必要的链接库文件，并在 `Other Link Flags` 选项添加 `-ObjC`
 
 - libc++.tdb

5、在需要使用的地方导入头文件 `#import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>` 即可进入相关开发


---
## 三、接入指南

在调用相关接口前请先下载`SDK`和`Demo`，熟悉接口和调用逻辑。

### 3.1、注册 AppId 和 AppSecret

```objectivec
// 优先导入头文件
#import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>

// 注册
SLSARegister(@"31298", @"145a2540f00147e89dc5e33b6842f74c");
```
### 3.2 相机调用

在项目工程 `Info.plist` 中添加 `Privacy - Camera Usage Description` 隐私描述 如：`App拍照测肤需要调用您的相机`

#### 3.2.1 访问授权

在调用相机拍摄前需要优先判断是否拥有相机访问许可，如果未授权需要请求授权访问。

```objectivec
AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
if (status == AVAuthorizationStatusAuthorized) {
    // 初始化相机
    return;
}
@weakify(self);
[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
    SLSAAsyncMain(^{
        if (granted) {
            // 初始化相机
            return;
        }
        // 无相机访问许可，做对应的处理
        [self showAlert:@"无相机访问许可，请更改隐私设置允许访问相机" doneHandler:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    });
}];
```

#### 3.2.2 相机初始化

拥有相机访问权限后，可按如下方式初始化相机

```objectivec
NSError *error;
_camera = [[SLSACamera alloc]init];
_camera.delegate = self;
BOOL ret = [_camera prepareCamera:AVCaptureDevicePositionFront error:&error];
if (!ret) {
    // 相机初始化失败，做失败处理
    NSLog(@"---相机设备初始化失败--%@",error);
    @weakify(self);
    [self showAlert:@"相机初始化出错" doneHandler:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    return;
}
/// 调用处理，如插入layer图层并启动相机视频帧采集
if (_camera.prepared) {
    _camera.videoPreviewLayer.frame = self.view.bounds;
}
[self.view.layer insertSublayer:_camera.videoPreviewLayer atIndex:0];
[_camera startRunning];
```

#### 3.2.3 videoPreviewLayer 设置

`AVCaptureVideoPreviewLayer` 提供了相机画面的异步渲染，如果不需要自行渲染相机数据，可以调用它。

- 将相机预览图层插入视图图层索引0位置


```objectivec
[self.view.layer insertSublayer:_camera.videoPreviewLayer atIndex:0];
_camera.videoPreviewLayer.frame = self.view.bounds;
```

- 调整预览图层的 frame 

```objectivec
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.camera && self.camera.prepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.camera && self.camera.prepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
}
```

#### 3.2.4 运行控制

- 判断相机是否正在采集视频帧

```objectivec
BOOL ret = [self.camera isRunning];
if (ret) {
    /// 相机正在运行
}
```

- 启动相机视频帧录制

```objectivec
/// 异步启动相机
[self.camera startRunning];
/// 同步启动相机
[self.camera startRunning:NO];
```

- 停止视频帧录制

```objectivec
/// 异步停止相机拍摄
[self.camera stopRunning];
```

#### 3.2.5 摄像头切换

- 判断是否是后置摄像头

```objectivec
/// 异步停止相机拍摄
BOOL ret = [self.camera isCameraPositionBack];
```

- 获取摄像头位置

```objectivec
AVCaptureDevicePosition position = [self.camera getCameraPosition];
```

- 异步切换摄像头

```objectivec
/// 相机正在拍照，不执行切换
if ([self.camera isCapturingStillImage]) {
    return;
}
// 获取当前摄像头方向并设置相反的切换方向
AVCaptureDevicePosition devicePosition = [self.camera getCameraPosition];
if (devicePosition == AVCaptureDevicePositionBack) {
    devicePosition = AVCaptureDevicePositionFront;
}
else {
    devicePosition = AVCaptureDevicePositionBack;
}
/// 切换摄像头
@weakify(self);
[self.camera setCameraPosition:devicePosition result:^(AVCaptureDevicePosition position) {
    @strongify(self);
    /// 得到摄像头切换的方向 position 做对应的处理 
    BOOL isFrontCamera = [self.camera isCameraPositionBack];
    self.voiceTextLabel.text = isFrontCamera ? @"请平视前置摄像头" : @"请平视后置摄像头";
    self.switchButton.selected = (position == AVCaptureDevicePositionBack);
}];
```

#### 3.2.6 静态图片采集

调用如下接口进行静态图片拍摄

```objectivec
/// 正在拍照
if ([self.camera isCapturingStillImage]) {
    return;
}
@weakify(self);
[self.camera takePhotosAsynchronously:^(CMSampleBufferRef  _Nonnull imageDataSampleBuffer, NSError * _Nonnull error) {
    /// 拍照结果buffer回调
    @strongify(self);
    SLSAAsyncMain(^{
        
    });
} result:^(NSData * _Nonnull imageData, NSError * _Nonnull error) {
    if (error) {
    /// 拍照错误
        return;
    }
    /// 得到原始图像进行处理
    UIImage *originImage = [[UIImage alloc]initWithData:imageData];
}];
```

#### 3.2.7 清理资源

使用完毕释放资源

```objectivec
- (void)dealloc {
    if (_camera) {
        [_camera clear];
        _camera = nil;
    }
}
```

### 3.3 buffer 处理

`SLSAVideoBufferAnalysisEngine`分析引擎用于辅助拍摄符合要求的清晰人脸图像，通过此引擎可以控制拍摄距离、光亮、人脸在屏幕位置、识别人脸遮挡物等。

#### 3.3.1 configure
`SLSAVideoBufferAnalysisConfiguration`允许你设置buffer分析阈值，如：光亮、距离、分析选项、稳定帧等

```objectivec
SLSAVideoBufferAnalysisConfiguration *config = [[SLSAVideoBufferAnalysisConfiguration alloc]init];
config.minDistance = 0.55; // 最小相对距离
config.maxDistance = 0.95; // 最大相对距离
config.minYUVLight = 60; // 最小亮度
config.maxYUVLight = 220; // 最大亮度
config.options = SSVideoBufferAnalysisAll;// 检测所有选项
config.minStableFramesToCaptureStillImage = 3；// 最小拍照稳定帧，3次满足拍照要求输出拍照状态
config.minStableFramesToOutputState = 3; // 静音模式最小稳定帧，3此满足输出当前状态
```

#### 3.3.2 自定义语音

`buffer`分析引擎提供了默认的语音`SLSADefaultVoiceConfiguration`,如果需要自定义声音，实现`SLSAVoiceConfigDelegate`协议即可

```objectivec
@interface SLSAMyCustomVoiceConfiguration : NSObject <SLSAVoiceConfigDelegate>

@end

@implementation SLSAMyCustomVoiceConfiguration

#pragma mark - Delegate

- (nullable SLSAVoiceItem*)getVoiceItemByVideoBufferAnalysisState:(SSVideoBufferAnalysisState)state frontCamera:(BOOL)isFrontCamera {
    /// 实现非遮挡物状态语音
}
- (nullable SLSAVoiceItem*)getVoiceItemByDetectedFaceShelters:(NSArray<SLSAFaceShelterItem*>*)shelters {
    /// 实现遮挡物状态语音
}
@end
```

#### 3.3.3 人脸状态检测

- 初始化 buffer 分析引擎

```objectivec
SLSAVideoBufferAnalysisConfiguration *config = [[SLSAVideoBufferAnalysisConfiguration alloc]init];
config.minDistance = 0.55;
config.maxDistance = 0.95;
SLSAMyCustomVoiceConfiguration *voiceConfig = [[SLSAMyCustomVoiceConfiguration alloc]init];
_bufferAnalysisEngine = [[SLSAVideoBufferAnalysisEngine alloc]initWithConfiguation:config voiceConfig:voiceConfig];
```

- buffer分析

```objectivec
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer faceObjects:(NSArray *)faceObjects fromConnection:(AVCaptureConnection *)connection {
    AVCaptureDevicePosition position = [self.camera getCameraPosition];
    [self.bufferAnalysisEngine analysisVideoBuffer:sampleBuffer position:position faces:faceInfoArray renderRect:self.renderRect boundingRect:self.renderRect targetFace:^(CGRect faceRect) {
        NSLog(@"--人脸框--%@",NSStringFromCGRect(faceRect));
        SLSAAsyncMain(^{
            @strongify(self);
            [self.faceRectDraw drawFaceRect:faceRect];
        });
    } result:^(SLSAVideoBufferAnalysisResult * _Nonnull result) {
        NSLog(@"--result--%@",result);
        @strongify(self);
        /// 处理人脸状态
        /// code
        if (result.state == SSVideoBufferAnalysisStateWillTakePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(prepareToTakePhoto) withObject:nil afterDelay:3.0];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"取消拍照");
             [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(prepareToTakePhoto) object:nil];
            });
        }
    }];
}
```

### 3.4 静态图片检测
可使用静态图片检测接口识别图片是否符合大数据肤质分析要求，如果不做处理且不满足要求，后台算法服务器会返回对应的错误

```objectivec
/// 你的检测图像
UIImage *originImage = [[UIImage alloc]initWithData:imageData];

/// 检测拍摄的静态图片的可用性
SSStillImageAnalysisOptions options = SSStillImageAnalysisNone;
options = (options | SSStillImageAnalysisFaceFeature);
options = (options | SSStillImageAnalysisFaceShelters);
options = (options | SSStillImageAnalysisAspectRedio);
options = (options | SSStillImageAnalysisPixels);
options = (options | SSStillImageAnalysisSize);
options = (options | SSStillImageAnalysisPixels);

SLSAStillImageAnalysisConfiguration *config = [[SLSAStillImageAnalysisConfiguration alloc]init];
config.options = options;
config.maxPixels = 5000000;
config.maxImageWidth = 2000;
config.maxImageHeight = 2500;

SLSAStillImageAnalysisEngine *engine = [[SLSAStillImageAnalysisEngine alloc]initWithConfiguration:config];
NSError *stillImageError;
if (![engine isValidStillImage:originImage error:&stillImageError]) {
    [QMUITips showError:stillImageError.localizedDescription];
    return;
}
/// 上传分析
```

### 3.5 上传与分析
采集到符合要求的正面清晰人脸照片后可调用以下接口进行上传和分析
```objectivec
[QMUITips showLoading:@"图片上传中" inView:self.view];
_dataEngine = [[SLSAFaceDataAnalysisEngine alloc]init];
[_dataEngine uploadImage:image progress:^(float progress) {
    NSLog(@"--上传进度--%@",@(progress));
} result:^(NSString * _Nonnull imageURL, NSError * _Nonnull error) {
    [QMUITips hideAllTips];
    if (error) {
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

    /// 肤质分析
    [self.dataEngine analysisWithImageURL:imageURL result:^(NSDictionary * _Nonnull responseJSON, NSError * _Nonnull error) {
        [QMUITips hideAllTips];
        if (error) {
            NSLog(@"----error----%@",error);
            [QMUITips showError:error.localizedDescription];
            return;
        }
        NSLog(@"----responseJSON----%@",responseJSON);
        [QMUITips showSucceed:@"肤质信息分析成功"];
    }];
}];
```

## 四、肤质分析功能说明
### 4.1 能力介绍
- **性别识别**：识别男女；
- **肤色识别**：识别肤色，涵盖亮白、红润、自然、小麦、暗哑等肤色；
- **脸型识别**：识别脸型类别，涵盖圆脸、鹅蛋脸、心形脸、方脸等脸型；
- **黑头识别**：检测黑头个数和严重程度；
- **毛孔检测**：检测毛孔个数和严重程度；
- **痘痘检测**：检测痘痘类别、个数、严重程度、脸部位置，涵盖痘后红斑、凹陷瘢痕、脓包、结节囊肿等类别；
- **眼型识别**：识别眼型类别，涵盖杏眼、丹凤眼、桃花眼等眼型；
- **眉形识别**：识别左右眉形类别，涵盖双燕眉、平直眉、秋波眉等眉形；
- **卧蚕识别**：识别是否有卧蚕；
- **细纹检测**：检测细纹类别和严重程度，涵盖抬头纹、法令纹、泪沟、笑肌断层、鱼尾纹等类别；
- **色素斑检测**：检测色素斑类别、严重程度、脸部位置，涵盖雀斑、黄褐斑、隐藏斑等类别；
- **眼袋检测**：检测是否有眼袋和严重程度；
- **敏感检测**：检测敏感类别和严重程度；
- **油分检测**：检测油分严重程度；
- **水分检测**：检测缺水类别和严重程度；
- **肤质类型检测**：检测肤质类别；
- **肌龄检测**：检测皮肤年龄；
- **黑眼圈检测**：检测黑眼圈类别和严重程度；
- **脂肪粒检测**：检测缺水类别和严重程度；
- **图片质量检测**：检测图片光照和是否模糊；
- **人脸姿态检测**：检测人脸姿态角度；
- **遮挡物检测**：检测人脸遮挡物（帽子、刘海、眼镜、鼻贴、口罩、面膜）；

### 4.2 类别描述
| 属性     | 类别                                                         |
| -------- | ------------------------------------------------------------ |
| 性别     | 男、女                                                       |
| 肤色     | 黝黑、暗哑、小麦、自然、红润、亮白                           |
| 脸型     | 方脸、圆脸、鹅蛋脸、心形脸                                   |
| 痘痘     | 凹陷瘢痕、痘后红斑、粉刺、炎症丘疹、结节囊肿、脓包           |
| 眼型     | 杏眼、小鹿眼、铜铃眼、睡龙眼、丹凤眼、瑞凤眼、睡凤眼、月牙眼、桃花眼、柳叶眼、狐媚眼、孔雀眼 |
| 眉形     | 柳叶眉、平直眉、秋波眉、秋娘眉、双燕眉、水弯眉               |
| 细纹     | 抬头纹、法令纹、泪沟、笑肌断层                               |
| 色素斑   | 黄褐斑、雀斑、隐藏斑、黑痣                                   |
| 敏感     | 耐受、敏感                                                   |
| 水分     | 滋润、敏感性缺水、油脂性缺水、老化性缺水                     |
| 肤质类型 | 干性、中性偏干、中性、混合性偏干、混合性、混合性偏油、油性   |
| 黑眼圈   | 正常、血管型、色素型                                         |
| 脂肪粒   | 栗丘疹                                                       |
| 图片质量 | 光照：正常、黑暗、过曝、光照不均匀；模糊：正常、模糊         |
| 人脸姿态 | Pitch、 Roll、Yaw                                            |
| 遮挡物  | 帽子、刘海、眼镜、鼻贴、口罩、面膜                                 |

### 4.3 注意事项
**眼型返回值规则**：眼型返回值由 eyelid，narrow，updown 三个值组合而成，如返回值 `"eyelid": 2,"narrow": 2,"updown": 1` 代表丹凤眼，具体计算规则见下表。（**注：**下表的组合值为简写，如 `[1、1、1]` 表示 `"eyelid": 1,"narrow": 1,"updown": 1` ）

| 组合值    | 代表眼型 |
| --------- | -------- |
| [1、1、1] | 铜铃眼   |
| [1、1、2] | 睡龙眼   |
| [2、1、1] | 杏眼     |
| [2、1、2] | 小鹿眼   |
| [2、2、1] | 丹凤眼   |
| [2、2、2] | 睡凤眼   |
| [1、2、1] | 瑞凤眼   |
| [1、2、2] | 月牙眼   |
| [2、3、1] | 桃花眼   |
| [2、3、2] | 柳叶眼   |
| [1、3、1] | 狐媚眼   |
| [1、3、2] | 孔雀眼   |

**肤色返回值规则**：肤色返回值由肤色卡行列组合而成，如返回值 F_3 代表第 F 行第 3 列的肤色块，肤色卡见下表。

<table>
    <tr align="center">
    <td>肤色卡</td>
    </tr>
    <tr align="center">
    <td><img src="http://htsleep.hetyj.com/FsBA8suPUwcVqwIIoDHhD-HsA06m"/></td>
    </tr>
</table>

### 4.4 结果返回
<table width="100%" style="border-spacing: 0;  border-collapse: collapse;">
    <thead>
        <tr>
            <td>名称</td>
            <td>数据类型</td>
            <td>说明</td>
        </tr>
    </thead>
    <tbody> 
          <tr>
            <td> photographId </td>
            <td>string</td>
            <td>测肤记录ID</td>
        </tr>
        <tr>
            <td>blackHead</td>
            <td>object</td>
            <td>黑头</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-极少，3-轻度，4-中度，5-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;number</td>
            <td>number</td>
            <td>黑头数量</td>
        </tr>
        <tr>
            <td>pore</td>
            <td>object</td>
            <td>毛孔</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-紧致，2-轻度，3-中度，4-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;number</td>
            <td>number</td>
            <td>毛孔数量</td>
        </tr>
        <tr>
            <td>facecolor</td>
            <td>String</td>
            <td>肤色（F_3 代表第F行第3列的肤色块)</td>
        </tr>
        <tr>
            <td>faceshape</td>
            <td>String</td>
            <td>脸型（H-心形脸，O-鹅蛋脸, S-方脸, R-圆脸）</td>
        </tr>
        <tr>
            <td>acnes</td>
            <td>list</td>
            <td>痘痘列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;acneTypeId</td>
            <td>number</td>
            <td>痘痘类型（1-红斑，2-粉刺，3-炎症性丘疹，4-脓包，5-凹陷性瘢痕，6-结节）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻度，3-中度，4-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;number</td>
            <td>number</td>
            <td>痘痘数量</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;facePart</td>
            <td>number</td>
            <td>部位（0-脸部无痘痘，1-额头，2-鼻子，3-左脸，4-右脸，5-下颌）</td>
        </tr>
        <tr>
            <td>eyeshape</td>
            <td>object</td>
            <td>眼型</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;eyelid</td>
            <td>number</td>
            <td>单双眼皮（1-单眼皮，2-双眼皮）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;narrow</td>
            <td>number</td>
            <td>眼睛宽窄（1-大眼，2-正常眼，3-眯缝眼）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;updown</td>
            <td>number</td>
            <td>外眼角的上扬或下垂（1-上扬，2-下垂）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、1、1]</td>
            <td></td>
            <td>铜铃眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、1、2]</td>
            <td></td>
            <td>睡龙眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、1、1]</td>
            <td></td>
            <td>杏眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、1、2]</td>
            <td></td>
            <td>小鹿眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、2、1]</td>
            <td></td>
            <td>丹凤眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、2、2]</td>
            <td></td>
            <td>睡凤眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、2、1]</td>
            <td></td>
            <td>瑞凤眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、2、2]</td>
            <td></td>
            <td>月牙眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、3、1]</td>
            <td></td>
            <td>桃花眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[2、3、2]</td>
            <td></td>
            <td>柳叶眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、3、1]</td>
            <td></td>
            <td>狐媚眼</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;[1、3、2]</td>
            <td></td>
            <td>孔雀眼</td>
        </tr>
        <tr>
            <td>eyebrow</td>
            <td>object</td>
            <td>眉形</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;left</td>
            <td>number</td>
            <td>左眼眉形（1、柳叶眉，2-平直眉，3-秋波眉，4-秋娘眉，5-双燕眉，6-水弯眉）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;right</td>
            <td>number</td>
            <td>右眼眉形（1、柳叶眉，2-平直眉，3-秋波眉，4-秋娘眉，5-双燕眉，6-水弯眉）</td>
        </tr>
        <tr>
            <td>pouch</td>
            <td>object</td>
            <td>眼袋</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;exist</td>
            <td>number</td>
            <td>有无眼袋（1-无眼袋，2-有眼袋）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重程度（1-无眼袋，2-轻微，3-严重）</td>
        </tr>
        <tr>
            <td>faceShelter</td>
            <td>object</td>
            <td>遮挡物</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;exist</td>
            <td>number</td>
            <td>有无遮挡物（1-无遮挡物，2-有遮挡物）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;types</td>
            <td> object </td>
            <td>遮挡物种类</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hat</td>
            <td>number</td>
            <td>帽子（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hair</td>
            <td>number</td>
            <td>刘海（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;glass</td>
            <td>number</td>
            <td>眼镜（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sticker</td>
            <td>number</td>
            <td>鼻贴（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mask</td>
            <td>number</td>
            <td>口罩（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;facial</td>
            <td>number</td>
            <td>面膜（0-无，1-存在）</td>
        </tr>
        <tr>
            <td>furrows</td>
            <td>number</td>
            <td>卧蚕（1-无卧蚕，2-有卧蚕）</td>
        </tr>
        <tr>
            <td>wrinkles</td>
            <td>list</td>
            <td>细纹列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;wrinkleTypeId</td>
            <td>number</td>
            <td>细纹类型（1-抬头纹，2-法令纹，3-泪沟，4-笑肌断层，5-鱼尾纹，6-眉间纹）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻度，3-中度，4-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;left</td>
            <td>number</td>
            <td>左边面积值(只有法令纹和鱼尾纹有左右面积)</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;right</td>
            <td>number</td>
            <td>右边面积值(只有法令纹和鱼尾纹有左右面积)</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;area</td>
            <td>number</td>
            <td>面积值(除法令纹和鱼尾纹外其他都不分左右面积)</td>
        </tr>
        <tr>
            <td>pigmentations</td>
            <td>list</td>
            <td>色素斑列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;pigmentationTypeId</td>
            <td>number</td>
            <td>色素斑类型（1-黑痣，2-黄褐斑，3-雀斑，4-隐藏斑）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻度，3-中度，4-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;facePart</td>
            <td>number</td>
            <td>部位（0-脸部无色素斑，1-额头，2-鼻子，3-左脸，4-右脸，5-下颌）</td>
        </tr>
        <tr>
            <td>moisture</td>
            <td>list</td>
            <td>水分列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;className</td>
            <td>number</td>
            <td>缺水类型（1-滋润，2-敏感性缺水，3-油脂性缺水，4-老化性缺水）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-滋润，2-轻度缺水，3-重度缺水）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;facePart</td>
            <td>number</td>
            <td>部位（1-额头，2-鼻子，3-左脸，4-右脸，5-下颌）</td>
        </tr>
        <tr>
            <td>sensitivity</td>
            <td>object</td>
            <td>敏感度列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;sensitivityCategory</td>
            <td>list</td>
            <td>敏感度列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻度，3-中度, 4-重度）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;facePart</td>
            <td>number</td>
            <td>部位（1-额头，2-鼻子，3-左脸，4-右脸，5-下颌）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;typeId</td>
            <td>number</td>
            <td>敏感类型（1-耐受，2-敏感）</td>
        </tr>
        <tr>
            <td>skinType</td>
            <td>number</td>
            <td>肤质类型（1: 干性 2：中性偏干 3：中性 4：混合性偏干 5：混合性 6：混合性偏油 7：油性）</td>
        </tr>
        <tr>
            <td>darkCircle</td>
            <td>list</td>
            <td>黑眼圈列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;type</td>
            <td>number</td>
            <td>缺水类型（1-无，2-血管型，3-色素型）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻微，3-严重）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;position</td>
            <td>number</td>
            <td>部位（1-左眼，2-右眼）</td>
        </tr>
        <tr>
            <td>skinAge</td>
            <td>number</td>
            <td>肌肤年龄</td>
        </tr>
        <tr>
            <td>oil</td>
            <td>list</td>
            <td>油分列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻微，3-严重）</td>
        </tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;facePart</td>
            <td>number</td>
            <td>部位（1-额头，2-鼻子，3-左脸，4-右脸，5-下颌）</td>
        </tr>
        <tr>
            <td>fatGranule</td>
            <td>list</td>
            <td>脂肪粒列表</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;level</td>
            <td>number</td>
            <td>严重等级（1-无，2-轻，3-重）</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;number</td>
            <td>number</td>
            <td>脂肪粒数量</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;fatGranuleTypeId</td>
            <td>number</td>
            <td>脂肪粒类型（1-汗管瘤，2-栗丘疹）</td>
        </tr>
        <tr>
            <td>wrinkleLayer</td>
            <td>string</td>
            <td>细纹图层图片</td>
        </tr>
        <tr>
            <td>acneLayer</td>
            <td>string</td>
            <td>痘痘图层图片</td>
        </tr>
        <tr>
            <td>pigmentationLayer</td>
            <td>string</td>
            <td>色斑图层图片</td>
        </tr>
        <tr>
            <td>sex</td>
            <td>number</td>
            <td>性别（1-男，2-女）</td>
        </tr>
        <tr>
            <td>imageQuality</td>
            <td>Object</td>
            <td>图片质量</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;lightType</td>
            <td>number</td>
            <td>1-正常，2-过暗，3-曝光，4-偏光</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;blurType</td>
            <td>number</td>
            <td>0-模糊，1-正常</td>
        </tr>
        <tr>
            <td>facePose</td>
            <td>Object</td>
            <td>人脸姿态估计</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;pitch</td>
            <td>number</td>
            <td>上下翻转的角度</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;roll</td>
            <td>number</td>
            <td>左右翻转的角度</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;yam</td>
            <td>number</td>
            <td>平面内旋转的角度</td>
        </tr>
    </tbody>
</table>

### 4.5 错误码

<table width="100%" style="border-spacing: 0;  border-collapse: collapse;">
    <tr>
        <th width="18%">状态码</th>
        <th>状态码说明</th>
        <td>处理建议</td>
    </tr>
    <tr>
        <td>0</td>
        <td>请求成功</td>
        <td></td>
    </tr>
    <tr>
        <td>100010100</td>
        <td>缺少授权信息</td>
        <td>请检查accessToken，appId，timestamp授权信息是否缺失或错误</td>
    </tr>
    <tr>
        <td>100010101</td>
        <td>accessToken错误或已过期</td>
        <td>重新获取accessToken</td>
    </tr>
    <tr>
        <td>100010103</td>
        <td>AppId不合法</td>
        <td>请检查是否与申请的appId一致</td>
    </tr>
    <tr>
        <td>100010104</td>
        <td>timestamp过期</td>
        <td>获取最新时间戳</td>
    </tr>
    <tr>
        <td>100010105</td>
        <td>签名错误</td>
        <td>请检查是否符合签名规则</td>
    </tr>
    <tr>
        <td>100010106</td>
        <td>请求地址错误</td>
        <td>请检查请求地址</td>
    </tr>
    <tr>
        <td>100010107</td>
        <td>请求Scheme错误</td>
        <td>请检查请求scheme是否为https</td>
    </tr>
    <tr>
        <td>100010200</td>
        <td>失败</td>
        <td>未知原因，请重试</td>
    </tr>
    <tr>
        <td>100010201</td>
        <td>缺少参数</td>
        <td>检查是否缺失必传参数</td>
    </tr>
    <tr>
        <td>107001011</td>
        <td>分析失败</td>
        <td>图片分析失败，请重试</td>
    </tr>
    <tr>
        <td>107001013</td>
        <td>图片中未检测到人脸</td>
        <td>请重新拍照</td>
    </tr>
    <tr>
        <td>107001014</td>
        <td>有两张或多张人脸</td>
        <td>请重新拍照</td>
    </tr>
    <tr>
        <td>107001032</td>
        <td>图片太大错误</td>
        <td>请检查图片大小是否符合要求</td>
    </tr>
    <tr>
        <td>107001033</td>
        <td>图片格式错误</td>
        <td>请检查图片格式是否符合要求</td>
    </tr>
    <tr>
        <td>107001034</td>
        <td>图片处理超时</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107001035</td>
        <td>非法的图片路径</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107001036</td>
        <td>解析图片发生错误</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107001037</td>
        <td>图片像素未达到要求</td>
        <td>请检查图片像素是否符合要求</td>
    </tr>
    <tr>
        <td>107001038</td>
        <td>维度值无效</td>
        <td>请检查维度值是否符合文档要求</td>
    </tr>
    <tr>
        <td>107003010</td>
        <td>肤色检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003011</td>
        <td>脸型检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003012</td>
        <td>黑头检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003014</td>
        <td>毛孔检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003016</td>
        <td>痘痘检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003017</td>
        <td>眼型检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003018</td>
        <td>眉形检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003019</td>
        <td>卧蚕或眼袋检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003020</td>
        <td>细纹检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003021</td>
        <td>色素斑检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003022</td>
        <td>敏感度检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003023</td>
        <td>油分检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003024</td>
        <td>水分检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003025</td>
        <td>肤质类型检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003028</td>
        <td>脂肪粒检测失败</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003089</td>
        <td>图片质量检测错误</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107003090</td>
        <td>人脸姿态检测错误</td>
        <td>请重试</td>
    </tr>
        <tr>
        <td>107003091</td>
        <td>算法服务请求超时</td>
        <td>请重试</td>
    </tr>
    <tr>
        <td>107004000</td>
        <td>授权超时</td>
        <td>授权已超过使用期限</td>
    </tr>
    <tr>
        <td>107005000</td>
        <td>数据解析失败</td>
        <td>本地解析网络数据失败</td>
    </tr>
</table>






