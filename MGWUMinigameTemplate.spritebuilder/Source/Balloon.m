//
//  Balloon.m
//  MGWUMinigameTemplate
//
//  Created by Branko Kotur on 8/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Balloon.h"

@implementation Balloon

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"balloon";
    self.physicsBody.collisionGroup = @"balloon";
}

@end
