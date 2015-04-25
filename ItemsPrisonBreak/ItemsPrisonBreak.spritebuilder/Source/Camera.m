//
//  Camera.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Camera.h"

@implementation Camera

- (void) flipCamera {
    CCLOG(@"flip camera");
    [self runAction:[CCActionFlipX actionWithFlipX:YES]];
}

- (void) unflipCamera {
    [self runAction:[CCActionFlipX actionWithFlipX:NO]];
}

@end
