//
//  CLContainerView.m
//  Cascade
//
//  Created by Marian Paul on 02/11/11.
//  Copyright (c) 2011 iPuP SARL. All rights reserved.
//

#import "CLContainerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CLContainerView
@synthesize shadowWidthLeft = _shadowWidthLeft;
@synthesize shadowOffsetLeft = _shadowOffsetLeft;
@synthesize shadowWidthRight = _shadowWidthRight;
@synthesize shadowOffsetRight = _shadowOffsetRight;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addLeftBorderShadowView:(UIView *)view withWidth:(CGFloat)width {
    
    [self setClipsToBounds: NO];
    
    if (_shadowWidthLeft != width) {
        _shadowWidthLeft = width;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    if (view != _shadowViewLeft) {
        _shadowViewLeft = view;
        
        [self insertSubview:_shadowViewLeft atIndex:0];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addRightBorderShadowView:(UIView *)view withWidth:(CGFloat)width {
    
    [self setClipsToBounds: NO];
    
    if (_shadowWidthRight != width) {
        _shadowWidthRight = width;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    if (view != _shadowViewLeft) {
        _shadowViewRight = view;
        
        [self insertSubview:_shadowViewRight atIndex:0];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeLeftBorderShadowView {
    
    [self setClipsToBounds: YES];
    
    _shadowViewLeft = nil;
    [self setNeedsLayout];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeRightBorderShadowView {
    
    [self setClipsToBounds: YES];
    
    _shadowViewRight = nil;
    [self setNeedsLayout];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;

    if (_shadowViewLeft) {
        CGRect shadowFrame = CGRectMake(0 - _shadowWidthLeft + _shadowOffsetLeft, 0.0, _shadowWidthLeft, rect.size.height);
        _shadowViewLeft.frame = shadowFrame;
    }
    
    if (_shadowViewRight) {
        CGRect shadowFrame = CGRectMake(rect.size.width + _shadowOffsetRight, 0.0, _shadowWidthRight, rect.size.height);
        _shadowViewRight.frame = shadowFrame;
    }
    
    
    /*if (self.subviews.count > 1) {
        UIView *firstView = [self.subviews objectAtIndex:1];
        firstView.layer.shouldRasterize = YES;
        firstView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
        [shapeLayer setPath:[path CGPath]];
        firstView.layer.mask = shapeLayer;
    }*/
    // Removed because performances are really bad ...
    // TODO : create a method to add / remove the mask
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-  (void) dealloc {
    _shadowViewLeft = nil;
    _shadowViewRight = nil;
}

@end
