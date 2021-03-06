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
#import "Coin.h"
#import "Police.h"
#import "PolicePopup.h"
#import "Camera.h"
#import "Bomb.h"
#import "CameraPopup.h"
#import "Instruction.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

static NSString * const kFirstLevel = @"Levels/Level1";
static NSString *selectedLevel = @"Levels/Level1";
static NSString *stone_text = @"Stone";
static NSString *coin_text = @"Coin";
static NSString * const levelPass = @"levelPass";

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_escaperHand;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    
    CCButton *_retryButton;
    CCButton *_menuButton;
    
    CCPhysicsJoint *_stoneHandJoint;
    //CCNode *_stickdoor;
    CCNode *_stickNode;
    
    // Label the number of remainde items
    CCLabelTTF *_itemsLeft;
    int _stone;
    CCLabelTTF *timeLeft;
    int totalTime;
    
    // Control Level Progress
    Level *level;
    CCNode *_levelNode;
    
    // Record the progress of current stone
    Item *_currentItem;
    
    // Parameters used to check success
    BOOL _success;
    
    // Switch Button
    CCButton *_switch;
    
    // Two Arrays to control the switching
    NSArray *items;
    int itemsCount[3];
    int totalItems;
    int currentItem;
    
    // Check the police has been distracted
    bool policeDistracted;
    
    // Timer to trace the camera
    NSTimer *timer;
    BOOL flip;
    
    // Flag to check is the bomb
    BOOL isBomb;
    
    // Flag to check progress of pass
    int pass;
    int current_level;
    
    // Instruction Layer
    Instruction *instruction;
    int page;
    BOOL beginTimer;
    
    // Trace Mark
    CCNode* question;
    CCNode* exclamation;
    int rockPolice;
}


static const float MIN_SPEED = 10.f;

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    //    self.paused = YES;
    
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = TRUE;
    self.userInteractionEnabled = TRUE;
    level = (Level *) [CCBReader load:selectedLevel owner:self];
    [_levelNode addChild:level];
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    // Initialize the stone left
    items = [NSArray arrayWithObjects:@"Stone", @"Coin", @"Bomb", nil];
    //    itemsCount = [NSArray arrayWithObjects:@5, @5, nil];
    for (int i=0; i<2; i++) {
        itemsCount[i] = 5;
    }
    itemsCount[2] = 2;
    currentItem = 0;
    
    _stone = 2;
    _success = FALSE;
    _itemsLeft.string = [NSString stringWithFormat:@"%d", itemsCount[0]];
    pass = 1;
    beginTimer = TRUE;
    
    // Hide switch button in first level
    if ([selectedLevel isEqual: @"Levels/Level1"]) {
        totalTime = 180;
        timeLeft.string = [self transTime: (time_t)totalTime];
        _switch.visible = FALSE;
        totalItems = 1;
        policeDistracted = true;
        flip = FALSE;
        current_level = 1;
        //        int dataLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:levelPass];
        //        if (dataLevel == current_level) {
        [self addInstruction:1];
        //        }
    } else if([selectedLevel isEqual: @"Levels/Level4"] || [selectedLevel isEqual: @"Levels/Level5"]) {
        totalTime = 300;
        timeLeft.string = [self transTime: (time_t)totalTime];
        _switch.visible = TRUE;
        _switch.title = stone_text;
        policeDistracted = false;
        flip = TRUE;
        pass = 0;
        NSTimeInterval timeInterval = 5.0;
        timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(handleTimer:)
                                               userInfo:nil
                                                repeats:YES];
        totalItems = 3;
        current_level = 5;
        
        if ([selectedLevel isEqual:@"Levels/Level4"]) {
            current_level = 4;
            totalItems = 2;
            //            int dataLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:levelPass];
            //            if (dataLevel == current_level) {
            [self addInstruction:3];
            //            }
        }
    } else {
        totalTime = 240;
        timeLeft.string = [self transTime: (time_t)totalTime];
        _switch.visible = TRUE;
        _switch.title = stone_text;
        totalItems = 2;
        policeDistracted = false;
        flip = FALSE;
        current_level = 3;
        if ([selectedLevel isEqual:@"Levels/Level2"]) {
            current_level = 2;
            //            int dataLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:levelPass];
            //            if (dataLevel == current_level) {
            [self addInstruction:2];
            //            }
        }
    }
    
    rockPolice = 0;
    [self schedule:@selector(updateTime) interval:1.0f];
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
    [self releaseTimer];
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
        
        isBomb = FALSE;
        if (itemsCount[currentItem] > 0) {
            // create a item from the ccb-file
            if (currentItem == 0) {
                _currentItem = (Stone *)[CCBReader load:@"Stone"];
                _currentItem.scale = 0.4;
            } else if (currentItem == 1) {
                _currentItem = (Coin *)[CCBReader load:@"Coin"];
                _currentItem.scale = 0.3;
            } else if (currentItem == 2) {
                _currentItem = (Bomb *) [CCBReader load:@"Bomb"];
                _currentItem.scale = 0.08;
                isBomb = TRUE;
            }
            // initially position it on the scoop.
            CGPoint itemPosition = [_escaperHand convertToWorldSpace:ccp(20.5, 35.5)];
            // transform the world position to the node space to which the penguin will be added (_physicsNode)
            _currentItem.position = [_physicsNode convertToNodeSpace:itemPosition];
            
            // add it to the physics world
            [_physicsNode addChild:_currentItem];
            // we don't want the penguin to rotate in the scoop
            _currentItem.physicsBody.allowsRotation = FALSE;
            
            // create a joint to keep the stone fixed to the scoop until the catapult is released
            _stoneHandJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentItem.physicsBody bodyB:_escaperHand.physicsBody anchorA:_currentItem.anchorPointInPoints];
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

//- (void)launchStone {
//    CCNode* stone = [CCBReader load:@"Stone"];
//    stone.position = ccpAdd(_escaperHand.position, ccp(16, 15));
//    stone.scale = 0.5;
//
//    [_physicsNode addChild:stone];
//
//    CGPoint launchDirection = ccp(1, 0);
//    CGPoint force = ccpMult(launchDirection, 8000);
//    [stone.physicsBody applyForce:force];
//}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone redswitch :(CCNode *)redswitch {
    if (policeDistracted) {
        [redswitch removeFromParent];
        [level removeStickDoor];
        [stone removeFromParent];
    } else {
        [self alarm];
        [self popupRetryPolice];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone yellowswitch :(CCNode *)yellowswitch {
    if (!policeDistracted) {
        [self popupRetryPolice];
        [self alarm];
        return YES;
    } else if (flip) {
        [self popupRetryCamera];
        [self alarm];
        return YES;
    }
    
    if (pass < 1) {
        return YES;
    }
    
    _success = TRUE;
    int dataLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:levelPass];
    if (dataLevel == current_level && dataLevel != 5) {
        [[NSUserDefaults standardUserDefaults] setInteger:dataLevel+1 forKey:levelPass];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [yellowswitch removeFromParent];
    [stone removeFromParent];
    
    WinPopup *popup;
    if (current_level == 1) {
        popup = (WinPopup *)[CCBReader load:@"WinPopupCoin" owner:self];
    } else if (current_level == 4) {
        popup = (WinPopup *)[CCBReader load:@"WinPopupBomb" owner:self];
    } else {
        popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
    }
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];
    self.paused = YES;
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone stickdoor:(CCNode *)stickdoor {
    //[stone removeFromParent];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair coin:(CCNode *)coin police:(CCNode *)police {
    Police *p = (Police *) police;
    [p flipPolice];
    //[p stopAllActions];
    //    CCSprite *pi = (CCSprite *) police;
    //    pi.paused = YES;
    [coin removeFromParent];
    policeDistracted = true;
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone police:(CCNode *)police {
    [self shortAlarm];
    if (rockPolice == 0) {
        question = [CCBReader load:@"Question"];
        question.position = ccpAdd(police.position, ccp(-20, 65));
        question.scale = 0.5;
        [self addChild:question];
    } else if (rockPolice == 1) {
        [question removeFromParent];
        exclamation = [CCBReader load:@"Exclamation"];
        exclamation.position = ccpAdd(police.position, ccp(-20, 65));
        if (policeDistracted) {
            policeDistracted = false;
            Police *p = (Police *) police;
            [p unflipPolice];
        }
        exclamation.scale = 0.5;
        [self addChild:exclamation];
    } else if (rockPolice == 2) {
        [self popupRetryPolice];
    }
    
    rockPolice ++;
    [stone removeFromParent];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bomb:(CCNode *)bomb explosionwall:(CCNode *)explosionwall {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BombExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = bomb.position;
    [bomb.parent addChild:explosion];
    [bomb removeFromParent];
    [explosionwall removeFromParent];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone greenswitch:(CCNode *)greenswitch {
    pass = 1;
    [stone removeFromParent];
    [greenswitch removeFromParent];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stone:(CCNode *)stone camera:(CCNode *)camera {
    [self alarm];
    [self popupRetryCamera];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair coin:(CCNode *)coin camera:(CCNode *)camera {
    [self shortAlarm];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bomb:(CCNode *)bomb camera:(CCNode *)camera {
    [camera removeFromParent];
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bomb:(CCNode *)bomb police:(CCNode *)police {
    [police removeFromParent];
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
        _currentItem.physicsBody.allowsRotation = TRUE;
        _currentItem.launched = TRUE;
        
        if (itemsCount[currentItem] > 0) {
            //_stone--;
            itemsCount[currentItem]--;
            if (itemsCount[currentItem] == 0) {
                _stone--;
            }
            _itemsLeft.string = [NSString stringWithFormat:@"%d", itemsCount[currentItem]];
        }
    }
}

- (void) popupRetry {
    RetryPopup *popup = (RetryPopup *)[CCBReader load:@"RetryPopup" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];
    self.paused = YES;
    _stone = 2;
}

- (void) popupRetryPolice {
    PolicePopup *popup = (PolicePopup *)[CCBReader load:@"PolicePopup" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];
    self.paused = YES;
    _stone = 2;
}

- (void) popupRetryCamera {
    CameraPopup *popup = (CameraPopup *)[CCBReader load:@"CameraPopup" owner:self];
    popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(0.25, 0.25);
    [self addChild:popup];
    self.paused = YES;
    _stone = 2;
}

- (void) retry {
    // reload this level
    CCLOG(@"retry");
    CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
    [self releaseTimer];
}

#pragma mark - Update
- (void)update:(CCTime)delta
{
    if (totalTime == 0) {
        [self alarm];
        [self popupRetry];
    }
    
    if (_currentItem.launched && isBomb == TRUE) {
        if (ccpLength(_currentItem.physicsBody.velocity) < MIN_SPEED){
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BombExplosion"];
            // make the particle effect clean itself up, once it is completed
            explosion.autoRemoveOnFinish = TRUE;
            // place the particle effect on the seals position
            explosion.position = _currentItem.position;
            [_currentItem.parent addChild:explosion];
            [_currentItem removeFromParent];
        }
    }
    
    if (_currentItem.launched && itemsCount[0] <= 0) {
        
        if (_success) {
            return;
        }
        
        if ([_currentItem parent] == nil) {
            [self popupRetry];
            return;
        }
        
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentItem.physicsBody.velocity) < MIN_SPEED){
            [self popupRetry];
            return;
        }
        
        int xMin = _currentItem.boundingBox.origin.x;
        
        if (xMin < self.boundingBox.origin.x) {
            [self popupRetry];
            return;
        }
        
        int xMax = xMin + _currentItem.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self popupRetry];
            return;
        }
        
        int yMin = _currentItem.boundingBox.origin.y;
        if (yMin < self.boundingBox.origin.y) {
            [self popupRetry];
            return;
        }
        
        int yMax = _currentItem.boundingBox.size.height;
        if (yMax > (self.boundingBox.origin.y + self.boundingBox.size.height)) {
            [self popupRetry];
            return;
        }
    }
}

#pragma mark - Update
-(void) switchItem {
    
    currentItem++;
    if (currentItem >= totalItems) {
        currentItem = 0;
    }
    CCLOG(@"h%d",currentItem);
    _switch.title = [items objectAtIndex:currentItem];
    //    _itemsLeft.string = [NSString stringWithFormat:@"%@", [itemsCount objectAtIndex:currentItem]];
    _itemsLeft.string = [NSString stringWithFormat:@"%d", itemsCount[currentItem]];
}

+(void) setSelectedLevel: (NSString *) level {
    selectedLevel = level;
}

- (void)handleTimer:(NSTimer *)theTimer
{
    //    NSDateFormatter *dateFormator = [[NSDateFormatter alloc] init];
    //    dateFormator.dateFormat = @"yyyy-MM-dd  HH:mm:ss";
    //    NSString *date = [dateFormator stringFromDate:[NSDate date]];
    //    NSLog(@"handleTimer %@", date);
    if (flip) {
        flip = FALSE;
        [level unflipCamera];
    } else {
        flip = TRUE;
        [level flipCamera];
    }
}

- (void) releaseTimer {
    if ([timer isValid])
    {
        CCLOG(@"release timer");
        [timer invalidate];
    }
}

- (void) alarm {
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"alarm.mp3" volume:0.5 pitch:1 pan:0.5 loop:NO];
}

- (void) shortAlarm {
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"135371__blackie666__thathurts.wav" volume:0.5 pitch:1 pan:0.5 loop:NO];
}

- (void) begin {
    self.paused = NO;
    [self removeInstruction];
    _retryButton.enabled = TRUE;
    _menuButton.enabled = TRUE;
    self.userInteractionEnabled = TRUE;
    beginTimer = TRUE;
}

- (void) addInstruction: (int) index {
    beginTimer = FALSE;
    self.paused = YES;
    self.userInteractionEnabled = FALSE;
    _retryButton.enabled = FALSE;
    _menuButton.enabled = FALSE;
    if (index == 1) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-1" owner:self];
    } else if (index == 2) {
        instruction = (Instruction *)[CCBReader load:@"Instruction2-1" owner:self];
    } else {
        instruction = (Instruction *)[CCBReader load:@"Instruction3-1" owner:self];
    }
    instruction.positionType = CCPositionTypeNormalized;
    instruction.position = ccp(0, 0);
    [self addChild:instruction];
    page = 1;
}

- (void) nextIns1 {
    page++;
    [self removeInstruction];
    if (page == 2) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-2" owner:self];
    } else if (page == 3) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-3" owner:self];
    } else if (page == 4) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-4" owner:self];
    } else if (page == 5) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-5" owner:self];
    } else if (page == 6) {
        instruction = (Instruction *)[CCBReader load:@"Instruction1-6" owner:self];
    }
    
    instruction.positionType = CCPositionTypeNormalized;
    instruction.position = ccp(0, 0);
    [self addChild:instruction];
}

- (void) nextIns2 {
    page++;
    [self removeInstruction];
    if (page == 2) {
        instruction = (Instruction *)[CCBReader load:@"Instruction2-2" owner:self];
    }
    instruction.positionType = CCPositionTypeNormalized;
    instruction.position = ccp(0, 0);
    [self addChild:instruction];
}

- (void) nextIns3 {
    page++;
    [self removeInstruction];
    if (page == 2) {
        instruction = (Instruction *)[CCBReader load:@"Instruction3-2" owner:self];
    }
    instruction.positionType = CCPositionTypeNormalized;
    instruction.position = ccp(0, 0);
    [self addChild:instruction];
}


- (void) removeInstruction {
    [self removeChild:instruction];
}

- (void) menu {
    CCScene *selectionScene = [CCBReader loadAsScene:@"LevelSelection"];
    [[CCDirector sharedDirector] replaceScene:selectionScene];
}

-(void)share{
    NSLog(@"share");
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    CCNode *node = [scene.children objectAtIndex:0];
    UIImage *image = [self screenshotImage:node];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    [photo setImageURL:[NSURL URLWithString:@"http://www.itemsprisonbreak.com"]];
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = [CCDirector sharedDirector];
    [dialog setShareContent:content];
    dialog.mode = FBSDKShareDialogModeShareSheet;
    CCLOG(@"Show");
    [dialog show];
    CCLOG(@"Show end");
}

-(UIImage*) screenshotImage:(CCNode*)startNode
{
    
    CCLOG(@"image");
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize windowSize = [[CCDirector sharedDirector]viewSize];
    CCRenderTexture* crt =
    [CCRenderTexture renderTextureWithWidth:windowSize.width
                                     height:windowSize.height];
    [crt begin];
    [startNode visit];
    [crt end];
    
    return [crt getUIImage];
}

- (void) updateTime {
    if (!beginTimer) {
        return;
    }
    if (totalTime < 0) {
        return;
    }
    totalTime--;
    timeLeft.string = [self transTime: (time_t)totalTime];
    if (totalTime <= 60) {
        timeLeft.fontColor = [CCColor redColor];
    }
}

- (NSString *)transTime:(time_t)t{
    NSString  *timeformat = @"%M:%S";
    NSString  *currenttime = [self dateInFormat:t format:timeformat];
    return currenttime;
}

- (NSString *)dateInFormat:(time_t)dateTime format:(NSString*) stringFormat

{
    char buffer[80];
    const char *timeformat = [stringFormat UTF8String];
    struct tm * timeinfo;
    timeinfo = localtime(&dateTime);
    strftime(buffer, 80, timeformat, timeinfo);
    return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end
