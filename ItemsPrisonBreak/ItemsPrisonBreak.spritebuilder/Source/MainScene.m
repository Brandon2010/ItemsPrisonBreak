#import "MainScene.h"

@implementation MainScene

- (void) start {
    CCScene *selectionScene = [CCBReader loadAsScene:@"Splash"];
    [[CCDirector sharedDirector] replaceScene:selectionScene];
}

@end
