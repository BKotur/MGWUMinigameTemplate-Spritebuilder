//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation MyMinigame
{
    NSMutableArray* _balloonArray;
    CCPhysicsNode* _physicsNode;
    CCLabelTTF* _scoreLabel;
    CCLabelTTF* _timeLabel;
    Dart* _dart;
    CCNode* _handFront;
    
    BOOL _gameOver;
    float _time;
    int _score;
    BOOL _dartActive;
    BOOL _dartThrown;

}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"You have 60 seconds to pop as many balloons as you can.\nYou can only throw one dart at a time.\nGet 5 points for every popped balloon.  Lose 1 points for every miss.";
        _gameOver = NO;
        _time = 0.0f;
        _score = 0;
        _dartActive = NO;
        _dartThrown = NO;
        _balloonArray = [NSMutableArray array];
        
        
    }
    return self;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;

    // Set up anything connected to Sprite Builder here
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_dartActive) {
        
        [self.hero pullBack];
        _dart = (Dart*)[CCBReader load:@"Dart"];
    
        CGPoint dartPosition = [self.hero convertToWorldSpace:ccp(self.hero.position.x, self.hero.position.y)];
        _dart.position = [_physicsNode convertToWorldSpace:dartPosition];
    
        [_dart pullBack];
        [_physicsNode addChild:_dart];
        _dartActive = YES;

        [self.theDart pullBack];

    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_dartActive && !_dartThrown) {
        [self.hero throwDart];
        [_dart throwDart];
        //[self.theDart throwDart];
        //_dart.physicsBody.velocity = ccp(5, 5);
        CGPoint throwDirection = ccp(1, 1);
        CGPoint force = ccpMult(throwDirection, 12000);
        [_dart.physicsBody applyForce:force];
        _dartThrown = YES;
    }
}

-(void)onEnter {
    [super onEnter];
    
    //_physicsNode.collisionDelegate = self;
    [self updateLabels];
    [self updateScoreLabel];
    
    [self schedule:@selector(updateLabels) interval:0.1f];
    [self schedule:@selector(spawnBalloon) interval:1.0f];
    
    // Create anything you'd like to draw here
}

-(void)cleanup {
    [self unscheduleAllSelectors];
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    
    if (_gameOver) {
        [self endMinigame];
    } else {
        _time += delta;
        if (_time >= 60) {
            _gameOver = YES;
        }
        
        NSMutableArray* balloonToRemove = [NSMutableArray array];
        
        // Make sure the balloons are on the screen
        
        for (CCNode* balloon in _balloonArray) {
            if (balloon.position.y > 320.0f) {
                [balloonToRemove addObject:balloon];
                [balloon removeFromParent];
            }
        }
        
        for (CCNode* balloon in balloonToRemove) {
            [_balloonArray removeObject:balloon];
        }
        
        for (CCNode* balloon in _balloonArray) {
            CGPoint velocity = CGPointMake(0, 6);
            balloon.position = ccpAdd(balloon.position, velocity);
        }
        
        // Make sure the dart is on the screen
        
        if (_dartActive && _dartThrown) {
            if (_dart.position.x > 568.0f) {
                [self dartRemoved:_dart];
                _score = _score - 1;
                if (_score < 0) {
                    _score = 0;
                }
            }
           
        }
    }
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    if (_score < 1) {
        _score = 1;
    }
    if (_score > 100) {
        _score = 100;
    }
    [self endMinigameWithScore:_score];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair balloon:(CCNode *)nodeA dart:(CCNode *)nodeB {
    [[_physicsNode space] addPostStepBlock:^{
        [self balloonRemoved:nodeA];
        [self dartRemoved:nodeB];
    } key:nodeA];
}

-(void)balloonRemoved:(CCNode *)balloon {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BalloonPop"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = balloon.position;
    [balloon.parent addChild:explosion];
    
    [balloon removeFromParent];
    _score = _score + 5;
}

-(void)dartRemoved:(CCNode *)dart {
    [dart removeFromParent];
    _dartActive = NO;
    _dartThrown = NO;

}

-(void)updateScoreLabel {
    _scoreLabel.string = [NSString stringWithFormat:@"%i", _score];
}

-(void)updateLabels {
    _timeLabel.string = [NSString stringWithFormat:@"%.0f", _time];
    _scoreLabel.string = [NSString stringWithFormat:@"%0i", _score];
}

-(void)spawnBalloon {
    CCNode* balloon;
    
    balloon = [CCBReader load:@"Balloon"];
    
    balloon.position = ccp((300 * CCRANDOM_0_1()) + 240, 30);
    
    [_physicsNode addChild:balloon];
    [_balloonArray addObject:balloon];
    
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    _hero.characterType = kCharacterGreen;
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!

@end
