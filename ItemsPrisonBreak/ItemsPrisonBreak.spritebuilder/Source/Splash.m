//
//  Splash.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 4/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Splash.h"

@implementation Splash

- (void) skip {
    CCScene *selectionScene = [CCBReader loadAsScene:@"LevelSelection"];
    [[CCDirector sharedDirector] replaceScene:selectionScene];
}

@end
