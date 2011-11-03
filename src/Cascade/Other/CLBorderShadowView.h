//
//  CLBorderShadowView.h
//  Cascade
//
//  Created by Emil Wojtaszek on 23.08.2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    CLShadowLeft = 0,
    CLShadowRight
}CLShadow;

@interface CLBorderShadowView : UIView
{
    CLShadow _currentShadow;
}
- (id) initWithType:(CLShadow)type;
@end
