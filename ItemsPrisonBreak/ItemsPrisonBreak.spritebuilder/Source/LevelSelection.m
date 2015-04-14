//
//  LevelSelection.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelection.h"
#import "Gameplay.h"

@implementation LevelSelection

- (void) startOne {
    //[Gameplay setSelectedLevel: @"Levels/Level1"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startTwo {
    [Gameplay setSelectedLevel: @"Levels/Level2"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startThree {
    [Gameplay setSelectedLevel: @"Levels/Level3"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startFour {
    [Gameplay setSelectedLevel: @"Levels/Level2"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startFive {
    [Gameplay setSelectedLevel: @"Levels/Level2"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end
