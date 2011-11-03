//
//  CLBorderShadowView.m
//  Cascade
//
//  Created by Emil Wojtaszek on 23.08.2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CLBorderShadowView.h"

@implementation CLBorderShadowView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithType:(CLShadow)type {
    self = [super init];
    if (self) {
        _currentShadow = type;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;

}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) drawRect:(CGRect)rect {
    
    CGFloat colors [] = { 
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.3
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGPoint startPoint, endPoint;
    startPoint = CGPointMake(0, CGRectGetMidY(rect));
    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    if (_currentShadow == CLShadowRight){
        CGPoint oldPoint = endPoint;
        endPoint = startPoint;
        startPoint = oldPoint;
    }
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    
}

@end
