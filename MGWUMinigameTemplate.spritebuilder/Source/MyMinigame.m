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

}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"You have 60 seconds to pop as many balloons as you can.";
        _gameOver = NO;
        _time = 0.0f;
        _score = 0;
        _balloonArray = [NSMutableArray array];
        
        
    }
    return self;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;

    // Set up anything connected to Sprite Builder here
    
    // We're calling a public method of the character that tells it to jump!
    //[self.hero jump];
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.hero pullBack];
    _dart = (Dart*)[CCBReader load:@"Dart"];
    
    CGPoint dartPosition = [self.hero convertToWorldSpace:ccp(self.hero.position.x, self.hero.position.y)];
    _dart.position = [_physicsNode convertToWorldSpace:dartPosition];
    
    [_physicsNode addChild:_dart];
    //[self.theDart pullBack];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.hero throwDart];
    //[self.theDart throwDart];
    //_dart.physicsBody.velocity = ccp(5, 5);
    CGPoint throwDirection = ccp(1, 1);
    CGPoint force = ccpMult(throwDirection, 12000);
    [_dart.physicsBody applyForce:force];
    
}

-(void)onEnter {
    [super onEnter];
    
    //_physicsNode.collisionDelegate = self;
    [self updateLabels];
    [self updateScoreLabel];
    
    [self schedule:@selector(updateLabels) interval:0.1f];
    [self schedule:@selector(spawnBalloon) interval:0.5f];
    
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
    }
}

-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
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
    _score++;
}

-(void)dartRemoved:(CCNode *)dart {
    [dart removeFromParent];
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
