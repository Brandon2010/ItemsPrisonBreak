//
//  Gameplay.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Level.h"
#import "WinPopup.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_escaperHand;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentStone;
    CCPhysicsJoint *_stoneHandJoint;
    //CCNode *_stickdoor;
    CCNode *_stickNode;
    Level *level;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    self.userInteractionEnabled = TRUE;
    //level = [CCBReader loadAsScene:@"Levels/Level1"];
    level = (Level *) [CCBReader load:@"Levels/Level1" owner:self];
    [_levelNode addChild:level];
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start hand dragging when a touch inside of the hand occurs
    if (CGRectContainsPoint([_escaperHand  boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the escaperHand
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_escaperHand.physicsBody anchorA:ccp(0, 0) anchorB:ccp(9.8, 9.3) restLength:0.f stiffness:3000.f damping:60.f];
        
        // create a stone from the ccb-file
        _currentStone = [CCBReader load:@"Stone"];
        // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
        CGPoint stonePosition = [_escaperHand convertToWorldSpace:ccp(20.5, 35.5)];
        // transform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentStone.position = [_physicsNode convertToNodeSpace:stonePosition];
        _currentStone.scale = 0.5;
        // add it to the physics world
        [_physicsNode addChild:_currentStone];
        // we don't want the penguin to rotate in the scoop
        _currentStone.physicsBody.allowsRotation = FALSE;
        
        // create a joint to keep the penguin fixed to the scoop until the catapult is released
        _stoneHandJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentStone.physicsBody bodyB:_escaperHand.physicsBody anchorA:_currentStone.anchorPointInPoints];
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self releaseHead];
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self releaseHead];
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

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone redswitch :(CCNode *)redswitch {
    [redswitch removeFromParent];
    [level removeStickDoor];
    [stone removeFromParent];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone yellowswitch :(CCNode *)yellowswitch {
    [yellowswitch removeFromParent];
    [stone removeFromParent];
    
    WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];

    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone stickdoor:(CCNode *)stickdoor {
    //[stone removeFromParent];
    return YES;
}

- (void)releaseHead {
    if (_mouseJoint != nil)
    {
        // releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        // releases the joint and lets the penguin fly
        [_stoneHandJoint invalidate];
        _stoneHandJoint = nil;
        
        // after snapping rotation is fine
        _currentStone.physicsBody.allowsRotation = TRUE;
        
        // follow the flying penguin
        //CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        //[_contentNode runAction:follow];
        // follow the flying penguin
//        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
//        [_contentNode runAction:_followPenguin];
//        _currentStone.launched = TRUE;
    }
}

@end
