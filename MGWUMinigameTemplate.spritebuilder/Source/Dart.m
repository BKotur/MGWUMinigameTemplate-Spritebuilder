//
//  Dart.m
//  MGWUMinigameTemplate
//
//  Created by Branko Kotur on 8/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Dart.h"

@implementation Dart {
    BOOL _isHolding;
}


-(id)init {
    if ((self = [super init])) {
        _isHolding = NO;
    }
    return self;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"dart";
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    // This sample method is called every update to handle character animation
    [self updateAnimations:delta];
}

-(void)updateAnimations:(CCTime)delta {
    
}

-(void)pullBack {
    _isHolding = YES;
    [self.animationManager runAnimationsForSequenceNamed:@"Hold"];
}

-(void)throwDart {
    _isHolding = NO;
    [self.animationManager runAnimationsForSequenceNamed:@"Arc"];
}

@end
