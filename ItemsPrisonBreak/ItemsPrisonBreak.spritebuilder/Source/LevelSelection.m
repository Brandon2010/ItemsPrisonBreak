//
//  LevelSelection.m
//  ItemsPrisonBreak
//
//  Created by Brandon on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelection.h"
#import "Gameplay.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

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
    [audio playEffect:@"Prison Break.mp3" volume:0.5 pitch:1 pan:0.5 loop:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:levelPass]==nil){
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:levelPass];
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
            [_button5 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateHighlighted];
            [_button5 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateDisabled];
        }
    }
    
    if (level >= 4) {
        if (_button4 != nil) {
            [_button4 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
            [_button4 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateHighlighted];
            [_button4 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateDisabled];
        }
    }
    
    if (level >= 3) {
        if (_button3 != nil) {
            [_button3 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
            [_button3 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateHighlighted];
            [_button3 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateDisabled];
        }
    }
    
    if (level >= 2) {
        if (_button2 != nil) {
            [_button2 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
            [_button2 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateHighlighted];
            [_button2 setBackgroundSpriteFrame:spriteFrame forState:CCControlStateDisabled];
        }
    }
    
    //    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //    UIView *view = [CCDirector sharedDirector].view;
    //    loginButton.center = view.center;
    //    [view addSubview:loginButton];
    
    //    FBSDKShareButton *shareButton = [[FBSDKShareButton alloc] init];
    //    UIButton *m = shareButton;
    //    UIView *view = [CCDirector sharedDirector].view;
    //    shareButton.center = ccpAdd(view.center, CGPointMake(0, 100));
    //    shareButton.enabled = TRUE;
    //
    //    [self setUserInteractionEnabled:YES];
    ////    [m setUserInteractionEnabled:YES];
    //    [shareButton addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    //
    ////    [self addChild:m];
    //    [view addSubview:shareButton];
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


- (void) startOne {
    //[Gameplay setSelectedLevel: @"Levels/Level1"];
    [Gameplay setSelectedLevel: @"Levels/Level1"];
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


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
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


@end
