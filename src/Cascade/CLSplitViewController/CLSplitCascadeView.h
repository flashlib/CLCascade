//
//  CLSplitCascadeView.h
//  Cascade
//
//  Created by Emil Wojtaszek on 11-03-27.
//  Copyright 2011 CreativeLabs.pl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CLSplitCascadeViewController;
@class CLShadowBlurredView;

@interface CLSplitCascadeView : UIView {
    // views
    UIView* _categoriesView;
    UIView* _cascadeView;
     
    // background
    UIView*     _backgroundView;

    // Container
    UIView *_containerView;
    
    // divider
    UIView*     _dividerView;
    UIImage*    _verticalDividerImage;
    CGFloat     _dividerWidth;
    
    CALayer *_containerLayer;
    CALayer *_leftLayer;
    CALayer *_rightLayer;
    UIView *_backgroundBlackWhenModalView;
    CLShadowBlurredView *_backgroundModalView;
    
    BOOL _isOpen;
    BOOL _isAnimating;

    UIViewController *_presentedController;
    BOOL _isKeyboardVisible;
    CGSize _keyboardSize;
}

- (void) presentModalControllerFromMiddle:(UIViewController*)controller;
- (void) dismissMiddleViewController;

@property (nonatomic, strong) IBOutlet CLSplitCascadeViewController* splitCascadeViewController;

/*
 * Divider image - image between categories and cascade view
 */
@property (nonatomic, strong) UIImage* verticalDividerImage;

/*
 * Background view - located under cascade view
 */
@property (nonatomic, strong) UIView* backgroundView;

/*
 * Categories view - located on the left, view containing table view
 */
@property (nonatomic, strong) UIView* categoriesView;

/*
 * Cascade content navigator - located on the right, view containing cascade view controllers
 */
@property (nonatomic, strong) UIView* cascadeView;

/*
 * Container view. Contains all the views
 */
@property (nonatomic, strong) UIView* containerView;

@property BOOL isRotating;

@end
