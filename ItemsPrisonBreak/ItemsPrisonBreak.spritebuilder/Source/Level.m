//
//  Level.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 3/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Level.h"
#import "Camera.h"

@implementation Level {
    CCNode *_stickDoor;
    CCSprite *_camera;
}

-(void) didLoadFromCCB {
}

- (void) removeStickDoor {
    [_stickDoor removeFromParent];
}

- (void) flipCamera {
    if (_camera != nil) {
        Camera *c = (Camera *) _camera;
        [c flipCamera];
    }
}

- (void) unflipCamera {
    if (_camera != nil) {
        Camera *c = (Camera *) _camera;
        [c unflipCamera];
    }
}


@end
