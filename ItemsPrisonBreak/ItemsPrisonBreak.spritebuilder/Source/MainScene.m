#import "MainScene.h"

@implementation MainScene

- (void) start {
    CCScene *selectionScene = [CCBReader loadAsScene:@"LevelSelection"];
    [[CCDirector sharedDirector] replaceScene:selectionScene];
}

@end
