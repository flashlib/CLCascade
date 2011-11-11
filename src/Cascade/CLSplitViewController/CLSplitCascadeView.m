//
//  CLSplitCascadeView.m
//  Cascade
//
//  Created by Emil Wojtaszek on 11-03-27.
//  Copyright 2011 CreativeLabs.pl. All rights reserved.
//

#import "CLSplitCascadeView.h"
#import "CLGlobal.h"

#import "CLCascadeNavigationController.h"
#import "CLSplitCascadeViewController.h"
#import "CLGlobal.h"

#define OFFSET_SHADOW 50.0f

@interface CLShadowBlurredView : UIView
@end

@interface CLSplitCascadeView (Private)
- (void) setupView;
- (void) addDivierView;

- (UIImage*) getImageFromCurrentContext;
- (void) openViewAnimated:(BOOL)animated;
- (void) openLayersAnimated:(BOOL)animated;
- (void) replaceModalViewControllerAnimated:(BOOL)animated;

@end

@implementation CLSplitCascadeView

@synthesize splitCascadeViewController = _splitCascadeViewController;

@synthesize categoriesView = _categoriesView;
@synthesize cascadeView = _cascadeView;
@synthesize backgroundView = _backgroundView;
@synthesize verticalDividerImage = _verticalDividerImage;
@synthesize containerView = _containerView;
@synthesize isRotating = _isRotating;

#pragma mark - Keyboard Handlings

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) keyBoardHeightForCurrentOrientation {
    CGFloat keyboardHeight = 0.0;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        keyboardHeight = _keyboardSize.width;
    else
        keyboardHeight = _keyboardSize.height;
    
    return keyboardHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillShow:(NSNotification*)notif
{
    BOOL wasVisible = _isKeyboardVisible;
    
    _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _isKeyboardVisible = YES;
    
    if (_isOpen && !wasVisible && !_isRotating) {
        [self replaceModalViewControllerAnimated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboarWillHide
{    
    if (_isOpen && !_isRotating) {
        _isKeyboardVisible = NO;
        [self replaceModalViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setupView {
    // add a container view to be able to hide the subviews easily
    _containerView = [[UIView alloc] init];
    [self addSubview:_containerView];
    
    [self setBackgroundColor: [UIColor blackColor]];
    
    // register to keyboard notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboarWillHide) name:UIKeyboardWillHideNotification object:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addDivierView {
    
    if ((!_backgroundView) || (!_verticalDividerImage)) return;
    
    if (_dividerView) {
        [_dividerView removeFromSuperview];
        _dividerView = nil;
    }
        
    _dividerView = [[UIView alloc] init];
    _dividerWidth = _verticalDividerImage.size.width;
    [_dividerView setBackgroundColor:[UIColor colorWithPatternImage: _verticalDividerImage]];
    
    [_backgroundView addSubview: _dividerView];
    [self setNeedsLayout];   
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*) getImageFromCurrentContext {
    UIGraphicsBeginImageContext(self.bounds.size);
    [_containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) openViewAnimated:(BOOL)animated {
    UIImage *screenImage = [self getImageFromCurrentContext];
    
    if (!_containerLayer.superlayer)
    {
        _containerLayer = [CALayer layer];
        [self.layer addSublayer:_containerLayer];
    }
    
    [_leftLayer removeFromSuperlayer];
    _leftLayer = [CALayer layer];
    
    [_rightLayer removeFromSuperlayer];
    _rightLayer = [CALayer layer];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        CGFloat oldWidth = width;
        width = height;
        height = oldWidth;
    }
    
    CGRect leftRect = CGRectMake(0, 0, width/2.0, height);
    CGRect rightRect = CGRectMake(width/2.0, 0, width/2.0, height);
    _containerLayer.frame = CGRectMake(0, 0, width, height);
    
    _leftLayer.frame = leftRect;
    _rightLayer.frame = rightRect;
    
    CGImageRef leftImage = CGImageCreateWithImageInRect(screenImage.CGImage, leftRect);
    _leftLayer.contents = (__bridge id)leftImage;
    CGImageRelease(leftImage);
    
    [_containerLayer addSublayer:_leftLayer];
    
    CGImageRef rightImage = CGImageCreateWithImageInRect(screenImage.CGImage, rightRect);
    _rightLayer.contents = (__bridge id)rightImage;
    CGImageRelease(rightImage);
    [_containerLayer addSublayer:_rightLayer];
    
    [self openLayersAnimated:animated];
}

#define PRESENT_MODAL_ANIMATION_DURATION 0.4f

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) openLayersAnimated:(BOOL)animated {
    CGFloat animationDuration = PRESENT_MODAL_ANIMATION_DURATION;
    CGFloat angleAnimation = 6.0f;
    CGFloat xTtranslation = 190.0f;
    
    CATransform3D rotationAndPerspectiveTransformLeft = CATransform3DIdentity;
    rotationAndPerspectiveTransformLeft = CATransform3DTranslate(rotationAndPerspectiveTransformLeft, -xTtranslation, 0.0, 0.0);
    rotationAndPerspectiveTransformLeft.m34 = 1.0 / -500;
    rotationAndPerspectiveTransformLeft = CATransform3DRotate(rotationAndPerspectiveTransformLeft, angleAnimation * M_PI / 180.0f, 0.0, 1.0, 0.0);
    
    CATransform3D rotationAndPerspectiveTransformRight = CATransform3DIdentity;
    rotationAndPerspectiveTransformRight = CATransform3DTranslate(rotationAndPerspectiveTransformRight, xTtranslation, 0.0, 0.0);
    rotationAndPerspectiveTransformRight.m34 = 1.0 / -500;
    rotationAndPerspectiveTransformRight = CATransform3DRotate(rotationAndPerspectiveTransformRight, -angleAnimation * M_PI / 180.0f, 0.0, 1.0, 0.0);
    
    if (animated) {
        CABasicAnimation *animLeft = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animLeft setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
        [animLeft setToValue:[NSValue valueWithCATransform3D:rotationAndPerspectiveTransformLeft]];
        [animLeft setDuration:animationDuration];
        
        [_leftLayer addAnimation:animLeft forKey:nil];
        
        CABasicAnimation *animRight = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animRight setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
        [animRight setToValue:[NSValue valueWithCATransform3D:rotationAndPerspectiveTransformRight]];
        [animRight setDuration:animationDuration];
        
        [self performSelector:@selector(setOpenBoolean) withObject:nil afterDelay:animationDuration];
        
        [_rightLayer addAnimation:animRight forKey:nil];
        
    }
    
    [_rightLayer setTransform:rotationAndPerspectiveTransformRight];
    [_leftLayer setTransform:rotationAndPerspectiveTransformLeft]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) replaceModalViewControllerAnimated:(BOOL)animated {
    CGRect bounds = self.bounds;
    CGFloat width = _presentedController.sizeForMiddleModalView.width;
    CGFloat height = _presentedController.sizeForMiddleModalView.height+44.0;
    
    if (_isKeyboardVisible) {
        bounds.size.height = MAX(bounds.size.height - [self keyBoardHeightForCurrentOrientation], height);
    }
    
    void (^animBlock)(void) = ^{
        CGRect newRect = CGRectMake(floorf((bounds.size.width - width)/2.0),
                                    floorf((bounds.size.height - height)/2.0),
                                    width, 
                                    height);
        _presentedController.view.frame = newRect;
        _backgroundModalView.frame = CGRectInset(newRect, -OFFSET_SHADOW, -OFFSET_SHADOW);
    };
    if (animated)
        [UIView animateWithDuration:0.29 animations:animBlock];
    else
        animBlock();
}

#pragma mark -
#pragma mark Init & dealloc

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]
    ;
    _cascadeView = nil;
    _categoriesView = nil;
    _verticalDividerImage = nil;
    _dividerView = nil;
    _containerView = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIView *lastView = [[[[window subviews] lastObject] subviews] lastObject];
    
    if([lastView isKindOfClass:NSClassFromString(@"PPAlertView")])
    {
        return [lastView hitTest:point withEvent:event];
    }
    
    if (_isOpen) {
        return [super hitTest:point withEvent:event];
    }
    
    CLCascadeNavigationController* cascadeNavigationController = _splitCascadeViewController.cascadeNavigationController;
    UIView* navigationView = [cascadeNavigationController view];

    if (CGRectContainsPoint(_categoriesView.frame, point)) {
        
        UIView* rootView = [[cascadeNavigationController firstVisibleViewController] view];
        CGRect rootViewRect = [rootView convertRect:rootView.bounds toView:self];

        if ((rootView) && (CGRectContainsPoint(rootViewRect, point))) {
            CGPoint newPoint = [self convertPoint:point toView:navigationView];
            return [navigationView hitTest:newPoint withEvent:event];
        } else {
            return [_categoriesView hitTest:point withEvent:event];
        }

    } else {
        CGPoint newPoint = [self convertPoint:point toView:navigationView];
        return [navigationView hitTest:newPoint withEvent:event];
    }
        
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) layoutSubviews {
    if (_isAnimating) {
        return;
    }
    
    CGRect bounds = self.bounds;
    
    _containerView.frame = bounds;
    
    CGRect categoriesFrame = CGRectMake(0.0, 0.0, CATEGORIES_VIEW_WIDTH, bounds.size.height);
    _categoriesView.frame = categoriesFrame;
    
    CGRect cascadeNavigationFrame = bounds;
    _cascadeView.frame = cascadeNavigationFrame;

    CGRect backgroundViewFrame = CGRectMake(CATEGORIES_VIEW_WIDTH, 0.0, bounds.size.width - CATEGORIES_VIEW_WIDTH, bounds.size.height);
    _backgroundView.frame = backgroundViewFrame;

    CGRect dividerViewFrame = CGRectMake(0.0, 0.0, _dividerWidth, bounds.size.height);
    _dividerView.frame = dividerViewFrame;
    
    if (_isOpen) {
        // we could use autoresizing mask ... -> need to call [super layoutSubviews]
        _backgroundBlackWhenModalView.frame = bounds;
        [self openLayersAnimated:NO];
        // call the method to snap shot again ! But after the rotation stuff
        [self performSelector:@selector(replaceOpenedLayers) withObject:nil afterDelay:0.0];
        
        [self replaceModalViewControllerAnimated:NO];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) replaceOpenedLayers {
    [_containerView setHidden:NO];
    [self openViewAnimated:NO];
    [_containerView setHidden:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) closeView {
    CGFloat animationDuration = PRESENT_MODAL_ANIMATION_DURATION;
    
    CABasicAnimation *animLeft = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animLeft setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [animLeft setDuration:animationDuration];
    
    [_leftLayer addAnimation:animLeft forKey:nil];
    
    CABasicAnimation *animRight = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animRight setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [animRight setDuration:animationDuration];
    
    [_rightLayer addAnimation:animRight forKey:nil];
    
    [_rightLayer setTransform:CATransform3DIdentity];
    [_leftLayer setTransform:CATransform3DIdentity]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setOpenBoolean {
    _isOpen = YES;
}

#pragma mark - present controller

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) presentModalControllerFromMiddle:(UIViewController*)controller {
    
    [self openViewAnimated:YES];
    
    _backgroundBlackWhenModalView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundBlackWhenModalView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [self addSubview:_backgroundBlackWhenModalView];
    _backgroundBlackWhenModalView.alpha = 0.0;
    _backgroundBlackWhenModalView.userInteractionEnabled = YES;
    
    _backgroundModalView = [[CLShadowBlurredView alloc] initWithFrame:controller.view.frame];
    [self addSubview:_backgroundModalView];

    controller.view.alpha = _backgroundModalView.alpha = 0.5;
    controller.view.transform = _backgroundModalView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [self addSubview:controller.view];
    
    [UIView animateWithDuration:PRESENT_MODAL_ANIMATION_DURATION
                     animations:^{
                         _backgroundBlackWhenModalView.alpha = 1.0;
                         controller.view.alpha = _backgroundModalView.alpha = 1.0;
                         controller.view.transform = _backgroundModalView.transform = CGAffineTransformIdentity;
                     }];
    
    [[self containerView] setHidden:YES];
    
    _presentedController = controller;
    [self replaceModalViewControllerAnimated:NO];
}

- (void) dismissMiddleViewController {
    _isOpen = NO;
    _isAnimating = YES;
    
    [self closeView];
    
    [UIView animateWithDuration:PRESENT_MODAL_ANIMATION_DURATION
                     animations:^{
                         _backgroundBlackWhenModalView.alpha = 0.0;
                         _presentedController.view.transform = _backgroundModalView.transform = CGAffineTransformMakeScale(0.3, 0.3);
                         _presentedController.view.alpha = _backgroundModalView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [_backgroundBlackWhenModalView removeFromSuperview];
                         _backgroundBlackWhenModalView = nil;
                         
                         [[self containerView] setAlpha:0.0];
                         [[self containerView] setHidden:NO];
                         [UIView animateWithDuration:0.05 animations:^{
                             [[self containerView] setAlpha:1.0];
                         }
                                          completion:^(BOOL finished) {
                                              [_containerLayer removeFromSuperlayer];
                                          }];
                         
                         [_presentedController.view removeFromSuperview];
                         [_backgroundModalView removeFromSuperview];
                         _presentedController = nil;
                         _isAnimating = NO;
                     }];
}


#pragma mark -
#pragma mark Setter


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCategoriesView:(UIView*) aView {
    if (_categoriesView != aView) {
        _categoriesView = aView;
        
        [_containerView addSubview: _categoriesView];
        [_containerView bringSubviewToFront: _cascadeView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCascadeView:(UIView*) aView {
    if (_cascadeView != aView) {
        _cascadeView = aView;
                
        [_containerView addSubview: _cascadeView];
        [_containerView bringSubviewToFront: _cascadeView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setBackgroundView:(UIView*) aView {
    if (_backgroundView != aView) {
        _backgroundView = aView;
        
        [_dividerView removeFromSuperview];
        _dividerView = nil;
        
        if (_cascadeView == nil) {
            [_containerView addSubview: _backgroundView];
        } else {
            NSUInteger index = [_containerView.subviews indexOfObject: _cascadeView];
            [_containerView insertSubview:_backgroundView atIndex:index];
        }

        [self addDivierView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setVerticalDividerImage:(UIImage*) image {
    if (_verticalDividerImage != image) {
        _verticalDividerImage = image;
        
        [self addDivierView];
    }
}

@end

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius);

@implementation CLShadowBlurredView

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius) {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), 
                        CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
                        CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;        
}

- (id) initWithFrame:(CGRect)frame {
    frame = CGRectInset(frame, -OFFSET_SHADOW, -OFFSET_SHADOW);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor;
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), OFFSET_SHADOW, shadowColor);
    CGContextSetFillColorWithColor(context, shadowColor);
    
    CGPathRef roundedRectPath = createRoundedRectForRect(CGRectInset(rect, OFFSET_SHADOW, OFFSET_SHADOW), 6.0);
    
    for (int i = 0 ; i < 6 ; i ++)
    {
        CGContextAddPath(context, roundedRectPath);
        CGContextFillPath(context);
    }
    CGPathRelease(roundedRectPath);
}

@end

