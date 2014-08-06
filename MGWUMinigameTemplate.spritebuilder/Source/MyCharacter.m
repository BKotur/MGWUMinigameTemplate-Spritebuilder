//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyCharacter.h"

@implementation MyCharacter {
    float _velYPrev; // this tracks the previous velocity, it's used for animation
    BOOL _isPullBack;
    BOOL _isHolding;
    BOOL _isThrow;
    BOOL _isIdling; // these BOOLs track what animations have been triggered.  By default, they're set to NO
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        
        // We initialize _isIdling to be YES, because we want the character to start idling
        // (Our animation code relies on this)
        _isIdling = YES;
        // by default, a BOOL's value is NO, so the other BOOLs are NO right now
    }
    return self;
}

-(void)didLoadFromCCB {
    // Set up anything connected to Sprite Builder here
    [self.animationManager runAnimationsForSequenceNamed:@"AnimSideIdling"];
    self.physicsBody.collisionType = @"hero";
}

-(void)onEnter {
    [super onEnter];
    // Create anything you'd like to draw here
}

-(void)pullBack {
    [self.animationManager runAnimationsForSequenceNamed:@"AnimSidePullBack"];
    _isHolding = YES;

}

-(void)throwDart {
    [self.animationManager runAnimationsForSequenceNamed:@"AnimSideThrow"];
    _isHolding = NO;
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    // This sample method is called every update to handle character animation
    [self updateAnimations:delta];
}

-(void)updateAnimations:(CCTime)delta {

    // Holding Animation
    if (_isHolding) {
        [self.animationManager runAnimationsForSequenceNamed:@"AnimSideHolding"];
    }
    // IDLE
    // The animation should be idle if the character was and is stationary
    // The character may only start idling if he or she was not already idling or falling
    /*if (_velYPrev == 0 && self.physicsBody.velocity.y == 0 && !_isIdling && !_isFalling) {
        [self resetBools];
        _isIdling = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimSideIdling"];
    }
    else if (_velYPrev == 0 && self.physicsBody.velocity.y == 0 && _isIdling && !_isPullBack) {
        [self resetBools];
        _isPullBack = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimSidePullBack"];
    }
    else if (_velYPrev == 0 && self.physicsBody.velocity.y == 0 && _isPullBack && !_isThrow) {
        [self resetBools];
        _isThrow = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimSideThrow"];
    }

    // JUMP
    // The animation should be jumping if the character wasn't moving up, but now is
    // The character may only start jumping if he or she was idling and isn't jumping
    else if (_velYPrev == 0 && self.physicsBody.velocity.y > 0 && _isIdling && !_isJumping) {
        [self resetBools];
        _isJumping = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoJump"];
    }
    // FALLING
    // The animation should be falling if the character's moving down, but was moving up or stalled
    // The character may only start falling if he or she was jumping and isn't falling
    else if (_velYPrev >= 0 && self.physicsBody.velocity.y < 0 && _isJumping && !_isFalling) {
        [self resetBools];
        _isFalling = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoFalling" tweenDuration:0.5f];
    }
    // LANDING
    // The animation sholud be landing if the character's stopped moving down (hit something)
    // The character may only start landing if he or she was falling and isn't landing
    else if (_velYPrev < 0 && self.physicsBody.velocity.y >= 0 && _isFalling && !_isLanding) {
        [self resetBools];
        _isLanding = YES;
        [self.animationManager runAnimationsForSequenceNamed:@"AnimIsoLand"];
    }
    */
    // We track the previous velocity, since it's important to determining how the character is and was moving for animations
    //_velYPrev = self.physicsBody.velocity.y;
    
}

// This method is called before setting one to YES, so that only one is ever YES at a time
-(void)resetBools {
    //_isPullBack = NO;
    //_isThrow = NO;
    _isIdling = NO;
}

@end
