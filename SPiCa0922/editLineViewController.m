//
//  editLineViewController.m
//  test0921
//
//  Created by takuya on 2014/09/22.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "editLineViewController.h"
#import "DragView.h"

@implementation editLineViewController
//ベースとなる画像
UIImageView *showImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //ナビゲーションツールバーを除いた大きさの取得
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screen);
    CGFloat screenHeight = CGRectGetHeight(screen);
    CGFloat statusBarHeight = 30;
    CGFloat navBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat availableHeight = screenHeight - statusBarHeight - navBarHeight;
    CGFloat availableWidth = screenWidth;
    
    //ここで渡された画像を表示
    showImageView = [[UIImageView alloc] init];
    showImageView.image = self.picture;
    //[showImageView setFrame:[[UIScreen mainScreen]applicationFrame]];
    
    showImageView.frame = CGRectMake(0, statusBarHeight + navBarHeight, availableWidth, availableHeight);
    
    showImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:showImageView];
    
    for (DragView *subview in self.stars) {
        NSLog(@"%f",subview.frame.origin.x);
        
    }
    
}
- (IBAction)closeView:(UIBarButtonItem *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end

