//
//  CLContainerView.h
//  Cascade
//
//  Created by Marian Paul on 02/11/11.
//  Copyright (c) 2011 iPuP SARL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLContainerView : UIView
{
    UIView* _shadowViewLeft, *_shadowViewRight;
    UIView *_middleView;
}

/*
 * The width of the left shadow
 */
@property (nonatomic, assign) CGFloat shadowWidthLeft;

/*
 * The width of the right shadow
 */
@property (nonatomic, assign) CGFloat shadowWidthRight;

/*
 * The offset of the left shadow in X-axis. Default 0.0
 */
@property (nonatomic, assign) CGFloat shadowOffsetLeft;

/*
 * The offset of the right shadow in X-axis. Default 0.0
 */
@property (nonatomic, assign) CGFloat shadowOffsetRight;

/* 
 * This method add left outer shadow view with proper width
 */
- (void) addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width;

/* 
 * This method add right outer shadow view with proper width
 */
- (void) addRightBorderShadowView:(UIView *)view withWidth:(CGFloat)width;

/* 
 * This method add middle view
 */
- (void) addMiddleView:(UIView *)view;


/* 
 * This method remove left outer shadow
 */
- (void) removeLeftBorderShadowView;

/* 
 * This method remove right outer shadow
 */
- (void) removeRightBorderShadowView;

/* 
 * This method remove middle view
 */
- (void) removeMiddleView;


@end
