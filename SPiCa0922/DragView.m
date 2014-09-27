//
//  DragView.m
//  test0921
//
//  Created by takuya on 2014/09/21.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "DragView.h"

@implementation DragView

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	startLocation = [[touches anyObject] locationInView:self];
	[[self superview] bringSubviewToFront:self];
}

//移動されるとき
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	CGRect frame = [self frame];
	frame.origin.x += pt.x - startLocation.x;
	frame.origin.y += pt.y - startLocation.y;

    [self setFrame:frame];
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
//色と形を指定して、変更するメソッド

-(void)changeFigure:(NSInteger )figure {

}


@end;