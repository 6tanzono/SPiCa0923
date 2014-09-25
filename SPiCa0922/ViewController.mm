//
//  ViewController.m
//  test0921
//
//  Created by takuya on 2014/09/21.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "ViewController.h"
#import "DragView.h"
#import "editLineViewController.h"
// opencv の import
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
#import <opencv2/legacy/legacy.hpp>
#import <opencv2/opencv_modules.hpp>

@interface ViewController ()

@end



//ベースとなる画像
UIImageView *showImageView;
//貼付け中の画像
DragView *currentStampView;
//貼付け中かどうか
BOOL _isPressStamp;

UIImage *picture;

NSInteger tagNo = 1;

NSMutableArray *stars;

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    stars = [NSMutableArray array];
    self.params = [NSMutableDictionary dictionary];
    
    //ナビゲーションツールバーを除いた大きさの取得
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screen);
    CGFloat screenHeight = CGRectGetHeight(screen);
    CGFloat statusBarHeight = 30;
    CGFloat navBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat availableHeight = screenHeight - statusBarHeight - navBarHeight;
    CGFloat availableWidth = screenWidth;
    
    showImageView = [[UIImageView alloc] init];
    
    //showImageView.image = [UIImage imageNamed:@"back1.png"];
    //cv::Mat     mat = [self matWithImage:[UIImage imageNamed:@"hisyatai.png"]];
    
    
    //背景画像の追加
    UIImageView *backView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back3.png"]];
    backView.frame = CGRectMake(0, statusBarHeight + navBarHeight, availableWidth, availableHeight);
    backView.contentMode = UIViewContentModeScaleAspectFit;
    backView.tag = 0;
    [self.view addSubview:backView];
    
    
    //領域分割
    CvRect roi;
    CvMemStorage *storage = 0;
    CvSeq *comp = 0;
    storage = cvCreateMemStorage (0);
    IplImage *aaaaa = [self IplImageFromUIImage:[UIImage imageNamed:@"hisyatai1.png"]];
    roi.x = roi.y = 0;
    roi.width = aaaaa->width & -(1 << 4);
    roi.height = aaaaa->height & -(1 << 4);
    cvSetImageROI (aaaaa, roi);
    IplImage *dst_img = cvCloneImage (aaaaa);
    cvPyrSegmentation (aaaaa, dst_img, storage, &comp, 4, 255.0, 100.0);
    cvReleaseMemStorage (&storage);
    showImageView.image = [self UIImageFromIplImage:dst_img];
    
    
    
    cv::Mat     mat = [self matWithImage:showImageView.image];
    
    /*
    // グレイスケール化してから適応的二値化
    cv::cvtColor(mat, mat, CV_BGR2GRAY);
    cv::adaptiveThreshold(mat, mat, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 7, 8);
    showImageView.image = MatToUIImage(mat);
    */
    /*
    // グレイスケール化してから大津法で二値化
    cv::cvtColor(mat, mat, CV_BGR2GRAY);
    cv::threshold(mat, mat, 0, 255, cv::THRESH_BINARY|cv::THRESH_OTSU);
    showImageView.image = MatToUIImage(mat);
    */
    //showImageView.alpha = 0.08;
    
    //CIFilterで合成
    /*
     CIImage *ciImage = [[CIImage alloc]initWithImage:[UIImage imageNamed:@"back1.png"]];
    
     CIFilter *ciFilter = [CIFilter filterWithName:@"CIAdditionCompositing" keysAndValues:kCIInputImageKey,[[CIImage alloc] initWithImage:showImageView.image],@"inputBackgroundImage",ciImage,nil];
     CIContext *ciContext = [CIContext contextWithOptions:nil];
     CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
     showImageView.image = [UIImage imageWithCGImage:cgimg scale:1.0f orientation:UIImageOrientationUp];
     CGImageRelease(cgimg);
    */

    /*
    // ImageViewのサイズを取得する
    CGSize size = showImageView.frame.size;
    
    // 重ねて描画したい画像の配列を作成します
    NSArray *images = @[[UIImage imageNamed:@"kingyo.png"],
                        [UIImage imageNamed:@"hisyatai.png"]];
    
    // 生成したUIImageオブジェクトをImageViewに設定する
    showImageView.image = [self compositeImages:images size:size];
    */
    
    //[showImageView setFrame:[[UIScreen mainScreen]applicationFrame]];
    
    showImageView.frame = CGRectMake(0, statusBarHeight + navBarHeight, availableWidth, availableHeight);
    
    showImageView.contentMode = UIViewContentModeScaleAspectFit;
    showImageView.tag = 0;
    [self.view addSubview:showImageView];
    
    
    //初期化
    currentStampView = nil;
    _isPressStamp = NO;
    
    
}

//uiimageからiplimageを作成するメソッド
- (IplImage*)IplImageFromUIImage:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4 );
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}
//iplimageからuiimageを作成するメソッド
- (UIImage*)UIImageFromIplImage:(IplImage*)image
{
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        //BGRになっているのでRGBに変換
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

//合成するメソッド
- (UIImage *)compositeImages:(NSArray *)array size:(CGSize)size
{
    UIImage *image = nil;
    
    // ビットマップ形式のグラフィックスコンテキストの生成
    UIGraphicsBeginImageContextWithOptions(size, 0.f, 0);
    
    // 塗りつぶす領域を決める
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    for (id item in array) {
        if (![item isKindOfClass:[UIImage class]]) {
            continue;
        }
        UIImage *img = item;
        [img drawInRect:rect];
    }
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}

//uiimageをmatに変換するメソッド
- (cv::Mat)matWithImage:(UIImage*)image
{
    // 画像の回転を補正する（内蔵カメラで撮影した画像などでおかしな方向にならないようにする）
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // UIImage -> cv::Mat
    cv::Mat mat;
    
    UIImageToMat(correctImage, mat);
    return mat;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//ダブルタップされたときに呼ばれる
- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        
        [recognizer.view removeFromSuperview];
        
    }
}

//タッチされたとき
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    //タッチされた座標を取得
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:showImageView];
    
    //スタンプの作成
    currentStampView = [[DragView alloc] initWithFrame:CGRectMake(point.x-10, point.y+40, 20, 20)];
    
  
    
    /*
    UIImage *originImage = [UIImage imageNamed:@"kingyo.png"];
    CIImage *filteredImage = [[CIImage alloc]initWithImage:originImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"
                                  keysAndValues:kCIInputImageKey, filteredImage,
                        @"inputAngle",[NSNumber numberWithFloat:2], nil];
    filteredImage = filter.outputImage;
    
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [ciContext createCGImage:[filter outputImage]
                                          fromRect:[[filter outputImage] extent]];
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef
                                               scale:1.0f
                                         orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    currentStampView.image = outputImage;
    */
    
    UIImage *originImage = [UIImage imageNamed:@"hoshi11.png"];

    UIColor* monochromeColor = [UIColor yellowColor];

    
    CIImage* ciImage = [[CIImage alloc]initWithImage:originImage];
    
    CIColor* ciColor = [[CIColor alloc]initWithColor:monochromeColor];
    
    NSNumber* nsIntensity = @1.0f;
    
    
    CIContext* ciContext = [CIContext contextWithOptions:nil];
    CIFilter* ciMonochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,ciImage,@"inputColor",ciColor,@"inputIntensity",nsIntensity,nil];
    
    
    CGImageRef cgMonochromeimage = [ciContext createCGImage:ciMonochromeFilter.outputImage fromRect:[ciMonochromeFilter.outputImage extent]];
    
    currentStampView.image = [UIImage imageWithCGImage:cgMonochromeimage scale:originImage.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(cgMonochromeimage);
    
    
    
    
    //currentStampView.image = [UIImage imageNamed:@"hoshi01.png"];
    
    //タッチされているビューを識別するためにタグをつける
    currentStampView.userInteractionEnabled = YES;
    currentStampView.tag = tagNo;
    tagNo += 1;
    
    //既に配置されたビュー以外がタッチされた場合
    if(touch.view.tag != currentStampView.tag){
        //スタンプを貼付ける
        UITapGestureRecognizer *doubleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [currentStampView addGestureRecognizer:doubleTap];
        
        [self.view addSubview:currentStampView];
        
        _isPressStamp = YES;
        
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //タッチされた座標を取得
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:showImageView];
    
    //スタンプの位置を変更する
    if(_isPressStamp){
        currentStampView.frame = CGRectMake(point.x-10, point.y+40, 20,20);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // スタンプモード終了（スタンプを確定する）
    //　hashmapにidをキーにしてcurrentStampViewを格納
    [self.params setObject:currentStampView forKey:[NSString stringWithFormat:@"%d",currentStampView.tag]];
    _isPressStamp = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // スタンプモード終了（スタンプを確定する）
    _isPressStamp = NO;
}


- (IBAction)nextView:(id)sender {
    [self performSegueWithIdentifier:@"toEditLine" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
    
    if ( [[segue identifier] isEqualToString:@"toEditLine"] ) {
        editLineViewController *editLineViewController = [segue destinationViewController];
        //ここで遷移先ビューのクラスの変数receiveStringに値を渡している
        [self listSubviewsOfView:self.view];
        picture = [self captureImage];
        editLineViewController.picture = picture;
        editLineViewController.stars = stars;
        
        
        
        
    }
}

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return;
    
    for (DragView *subview in subviews) {
        
        if(subview.tag != 0){
            
            
            [stars addObject:subview];
        }
        
    }
}

-(UIImage *)captureImage
{
    // 描画領域の設定
    CGSize size = CGSizeMake(showImageView.frame.size.width , showImageView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // グラフィックスコンテキスト取得
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // コンテキストの位置を切り取り開始位置に合わせる
    CGPoint point = showImageView.frame.origin;
    CGAffineTransform affineMoveLeftTop
    = CGAffineTransformMakeTranslation(
                                       -(int)point.x ,
                                       -(int)point.y );
    CGContextConcatCTM(context , affineMoveLeftTop );
    
    // viewから切り取る
    [(CALayer*)self.view.layer renderInContext:context];
    
    // 切り取った内容をUIImageとして取得
    UIImage *cnvImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // コンテキストの破棄
    UIGraphicsEndImageContext();
    
    return cnvImg;
}




@end
