//
//  LevelSelection.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelection.h"
#import "Gameplay.h"

@implementation LevelSelection {
    CCButton *_button2;
    CCButton *_button3;
    CCButton *_button4;
    CCButton *_button5;
    int level;
}

static NSString * const levelPass = @"levelPass";

- (void) didLoadFromCCB {
    // access audio object
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play sound effect in a loop
    //[audio playEffect:@"Prison Break.mp3" loop:YES];
    [audio playEffect:@"Prison Break.mp3" volume:0.5 pitch:0.5 pan:0.5 loop:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:levelPass]==nil){
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:levelPass];
        [[NSUserDefaults standardUserDefaults] synchronize];
        level = 1;
    }else{
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:levelPass];
        level = (int)[[NSUserDefaults standardUserDefaults] integerForKey:levelPass];
    }
    
    CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithImageNamed:@"ResourceAssets/Level-3-Star@4x (1).png"];
    if (level == 5) {
        if (_button5 != nil) {
            [_button5 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
        }
    }
    
    if (level >= 4) {
        if (_button4 != nil) {
            [_button4 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
        }
    }
    
    if (level >= 3) {
        if (_button3 != nil) {
            [_button3 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
        }
    }
    
    if (level >= 2) {
        if (_button2 != nil) {
            [_button2 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
        }
    }
    
}

- (void) startOne {
    //[Gameplay setSelectedLevel: @"Levels/Level1"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) startTwo {
    if (level >= 2) {
        [Gameplay setSelectedLevel: @"Levels/Level2"];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
}

- (void) startThree {
    if (level >= 3) {
        [Gameplay setSelectedLevel: @"Levels/Level3"];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
}

- (void) startFour {
    if (level >= 4) {
        [Gameplay setSelectedLevel: @"Levels/Level4"];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
}

- (void) startFive {
    if (level >= 5) {
        [Gameplay setSelectedLevel: @"Levels/Level5"];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
}


@end
