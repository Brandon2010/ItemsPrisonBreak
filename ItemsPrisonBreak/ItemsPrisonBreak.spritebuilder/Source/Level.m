//
//  Level.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 3/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Level.h"

@implementation Level {
    CCNode *_stickDoor;
}

-(void) didLoadFromCCB {
    if (_stickDoor == nil) {
        CCLOG(@"nil in Level");
    }
}

- (void) removeStickDoor {
    [_stickDoor removeFromParent];
}

@end
