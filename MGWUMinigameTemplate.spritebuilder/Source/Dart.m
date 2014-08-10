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
    self.physicsBody.collisionGroup = @"dart";
    self.scale = 0.5f;
    //[self.physicsBody applyImpulse:ccp(-)]
    [self setRotation:-45];
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
    self.anchorPoint = ccp(0, 0.5);
}

-(void)throwDart {
    _isHolding = NO;
    [self.animationManager runAnimationsForSequenceNamed:@"Arc"];
    self.anchorPoint = ccp(0.5, 0.5);

}

@end
