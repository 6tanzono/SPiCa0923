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
    
    //ここで渡された画像を表示
    //フィルターもここかな？
    //ベースとなる画像の貼付け
    showImageView = [[UIImageView alloc] init];
    //showImageView.image = [UIImage imageNamed:@"hisyatai.png"];
    
    CIImage *ciImage = [[CIImage alloc]initWithImage:[UIImage imageNamed:@"hisyatai.png"]];
    

     NSNumber* nsIntensity = @1.0f;
  
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIEdgeWork" keysAndValues:kCIInputImageKey,ciImage,/*@"inputIntensity",nsIntensity,*/ nil];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
    showImageView.image = [UIImage imageWithCGImage:cgimg scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgimg);
    
    
    
 
    
    
    
    
    
    //[showImageView setFrame:[[UIScreen mainScreen]applicationFrame]];
    
    showImageView.frame = CGRectMake(0, statusBarHeight + navBarHeight, availableWidth, availableHeight);
    
    showImageView.contentMode = UIViewContentModeScaleAspectFit;
    showImageView.tag = 0;
    [self.view addSubview:showImageView];
    
    //初期化
    currentStampView = nil;
    _isPressStamp = NO;
    
    
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
    
    UIImage *originImage = [UIImage imageNamed:@"kingyo.png"];

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
