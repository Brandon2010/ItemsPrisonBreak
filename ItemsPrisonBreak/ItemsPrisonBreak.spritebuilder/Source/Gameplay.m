//
//  Gameplay.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_escaperHand;
    CCNode *_levelNode;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self launchStone];
}

- (void)launchStone {
    CCNode* stone = [CCBReader load:@"Stone"];
    stone.position = ccpAdd(_escaperHand.position, ccp(16, 15));
    stone.scale = 0.5;
    
    [_physicsNode addChild:stone];
    
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [stone.physicsBody applyForce:force];
}

@end
