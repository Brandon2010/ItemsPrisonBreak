//
//  Level.h
//  ItemsPrisonBreak
//
//  Created by Brandon on 3/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Level : CCNode

@property (nonatomic, copy) NSString *nextLevelName;
@property (nonatomic, assign) int stoneNumber;

- (void) removeStickDoor;
- (void) flipCamera;
- (void) unflipCamera;

@end
