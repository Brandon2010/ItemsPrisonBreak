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
#import "RetryPopup.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Stone.h"

static NSString * const kFirstLevel = @"Levels/Level1";
static NSString *selectedLevel = @"Levels/Level1";

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_escaperHand;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    
    CCPhysicsJoint *_stoneHandJoint;
    //CCNode *_stickdoor;
    CCNode *_stickNode;
    
    // Label the number of remainde items
    CCLabelTTF *_itemsLeft;
    int _stone;
    
    // Control Level Progress
    Level *level;
    CCNode *_levelNode;
    
    // Record the progress of current stone
    Stone *_currentStone;
    
    // Parameters used to check success
    BOOL _success;
}

static const float MIN_SPEED = 10.f;

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    self.userInteractionEnabled = TRUE;
    level = (Level *) [CCBReader load:selectedLevel owner:self];
    [_levelNode addChild:level];
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    // Initialize the stone left
    _stone = 5;
    _success = FALSE;
    _itemsLeft.string = [NSString stringWithFormat:@"%d", _stone];
}

#pragma mark - Level completion

- (void)loadNextLevel {
    CCLOG(@"NextLevel!!!!");
    selectedLevel = level.nextLevelName;
    
    CCScene *nextScene = nil;
    
    if (selectedLevel) {
        nextScene = [CCBReader loadAsScene:@"Gameplay"];
    } else {
        selectedLevel = kFirstLevel;
        nextScene = [CCBReader loadAsScene:@"StartScene"];
    }
    
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:nextScene withTransition:transition];
    CCLOG(@"NextLevel!!!!");
}

#pragma mark - Touch Handling

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
        
        if (_stone > 0) {
            // create a stone from the ccb-file
            _currentStone = (Stone *)[CCBReader load:@"Stone"];
            // initially position it on the scoop.
            CGPoint stonePosition = [_escaperHand convertToWorldSpace:ccp(20.5, 35.5)];
            // transform the world position to the node space to which the penguin will be added (_physicsNode)
            _currentStone.position = [_physicsNode convertToNodeSpace:stonePosition];
            _currentStone.scale = 0.5;
            // add it to the physics world
            [_physicsNode addChild:_currentStone];
            // we don't want the penguin to rotate in the scoop
            _currentStone.physicsBody.allowsRotation = FALSE;
            
            // create a joint to keep the stone fixed to the scoop until the catapult is released
            _stoneHandJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentStone.physicsBody bodyB:_escaperHand.physicsBody anchorA:_currentStone.anchorPointInPoints];
        }
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
        _currentStone.launched = TRUE;
        
        if (_stone > 0) {
            _stone--;
            _itemsLeft.string = [NSString stringWithFormat:@"%d", _stone];
        }
    }
}

- (void) popupRetry {
    RetryPopup *popup = (RetryPopup *)[CCBReader load:@"RetryPopup" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];
    _stone = 5;
}

- (void)retry {
    // reload this level
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

#pragma mark - Update
- (void)update:(CCTime)delta
{
    if (_currentStone.launched && _stone <= 0) {
        
        if (_success) {
            CCLOG(@"success");
            return;
        }
        
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentStone.physicsBody.velocity) < MIN_SPEED){
            [self popupRetry];
            return;
        }
        
        int xMin = _currentStone.boundingBox.origin.x;
        
        if (xMin < self.boundingBox.origin.x) {
            [self popupRetry];
            return;
        }
        
        int xMax = xMin + _currentStone.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self popupRetry];
            return;
        }
        
        int yMin = _currentStone.boundingBox.origin.y;
        if (yMin < self.boundingBox.origin.y) {
            [self popupRetry];
            return;
        }
        
        int yMax = _currentStone.boundingBox.size.height;
        if (yMax > (self.boundingBox.origin.y + self.boundingBox.size.height)) {
            [self popupRetry];
            return;
        }
    }
}



@end
