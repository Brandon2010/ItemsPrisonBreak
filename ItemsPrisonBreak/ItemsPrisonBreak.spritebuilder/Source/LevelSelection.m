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

- (void) didLoadFromCCB {
    // access audio object
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play sound effect in a loop
    //[audio playEffect:@"Prison Break.mp3" loop:YES];
    [audio playEffect:@"Prison Break.mp3" volume:0.5 pitch:0.5 pan:0.5 loop:YES];
}

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
    [Gameplay setSelectedLevel: @"Levels/Level4"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startFive {
    [Gameplay setSelectedLevel: @"Levels/Level5"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end
