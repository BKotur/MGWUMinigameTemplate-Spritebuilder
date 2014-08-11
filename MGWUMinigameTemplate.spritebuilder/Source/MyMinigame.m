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
    CCLabelTTF* _dartsThrownLabel;
    CCLabelTTF* _balloonsPoppedLabel;
    CCLabelTTF* _missesLabel;
    CCLabelTTF* _finalScoreLabel;
    Dart* _dart;
    CCNode* _handFront;
    CCNode* _resultsNode;
    CCNode* _results;
    
    BOOL _gameOver;
    BOOL _gameDone;
    float _time;
    int _score;
    BOOL _dartActive;
    BOOL _dartThrown;
    int _dartsThrown;
    int _balloonsPopped;
    int _misses;
    
}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"You have 60 seconds to pop as many balloons as you can.\nYou can only throw one dart at a time.\nGet 5 points for every popped balloon.";
        _gameOver = NO;
        _gameDone = NO;
        _time = 0.0f;
        _score = 0;
        _dartActive = NO;
        _dartThrown = NO;
        _dartsThrown = 0;
        _balloonsPopped = 0;
        _misses = 0;
        _balloonArray = [NSMutableArray array];
        
        
    }
    return self;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;
    [_results setVisible:NO];
    // Set up anything connected to Sprite Builder here
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_dartActive) {
        
        [self.hero pullBack];
        _dart = (Dart*)[CCBReader load:@"Dart"];
    
        CGPoint dartPosition = [self.hero convertToWorldSpace:ccp(self.hero.position.x, self.hero.position.y)];
        _dart.position = [_physicsNode convertToWorldSpace:dartPosition];
        
        _dart.physicsBody.type = CCPhysicsBodyTypeStatic;
        
        [_dart pullBack];
        [_physicsNode addChild:_dart];
        _dartActive = YES;

        [self.theDart pullBack];

    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_dartActive && !_dartThrown) {
        _dart.physicsBody.type = CCPhysicsBodyTypeDynamic;

        
        [self.hero throwDart];
        [_dart throwDart];
        CGPoint throwDirection = ccp(1, 1);
        CGPoint force = ccpMult(throwDirection, 22000);
        [_dart.physicsBody applyForce:force];
        [_dart.physicsBody applyAngularImpulse:-135];
        _dartThrown = YES;
        _dartsThrown++;
    }
}

-(void)onEnter {
    [super onEnter];
    
    //_physicsNode.collisionDelegate = self;
    [self updateLabels];
    [self updateScoreLabel];
    
    [self schedule:@selector(updateLabels) interval:0.1f];
    [self schedule:@selector(spawnBalloon) interval:0.75f];
    
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
        if (!_gameDone) {
            _gameDone = YES;
            [[CCDirector sharedDirector] pause];
            [self doCleanup];
            [self showResults];
            //[self endMinigame];
        }
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
        
        // Make sure the dart is on the screen
        
        if (_dartActive && _dartThrown) {
            if (_dart.position.x > 568.0f) {
                [self dartRemoved:_dart];
                //_score--;
                _misses++;
                if (_score < 0) {
                    _score = 0;
                }
            }
           
        }
    }
}

-(void)doCleanup {
    NSMutableArray* balloonToRemove = [NSMutableArray array];
    for (CCNode* balloon in _balloonArray) {
        [balloonToRemove addObject:balloon];
        [balloon removeFromParent];
        
    }
    
    for (CCNode* balloon in balloonToRemove) {
        [_balloonArray removeObject:balloon];
    }
    [self dartRemoved:_dart];
}

-(void)showResults {
    [_results setVisible:YES];
    _dartsThrownLabel.string = [NSString stringWithFormat:@"%0i", _dartsThrown];
    _balloonsPoppedLabel.string = [NSString stringWithFormat:@"%0i", _balloonsPopped];
    _missesLabel.string = [NSString stringWithFormat:@"%0i", _misses];
    _finalScoreLabel.string = [NSString stringWithFormat:@"%0i", _score];
}

-(void)doneButton {
    [[CCDirector sharedDirector] resume];
    [self endMinigame];
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
    _balloonsPopped++;
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
    CGPoint velocity = CGPointMake(0, arc4random_uniform(200) + 25);
    balloon.physicsBody.velocity = velocity;
    
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
