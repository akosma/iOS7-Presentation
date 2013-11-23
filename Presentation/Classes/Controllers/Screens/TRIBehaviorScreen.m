//
//  TRIBehaviorScreen.m
//  Presentation
//
//  Created by Adrian on 20/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBehaviorScreen.h"
#import "TRIViews.h"

static long long const ARC4RANDOM_MAX = 0x100000000;


@interface TRIBehaviorScreen () <UICollisionBehaviorDelegate>

@property (strong, nonatomic) IBOutletCollection(TRICircleView) NSArray *circles;

@property (strong, nonatomic) UIDynamicAnimator *animator;

@end



@implementation TRIBehaviorScreen

+ (NSString *)xtype
{
    return @"behavior";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    for (TRICircleView *circle in self.circles)
    {
        circle.color = [self randomColor];
        
        UIPushBehavior *pusher = [[UIPushBehavior alloc] initWithItems:@[circle]
                                                                  mode:UIPushBehaviorModeInstantaneous];
        pusher.pushDirection = [self randomVector];
        pusher.active = YES;
        [self.animator addBehavior:pusher];

        UIDynamicItemBehavior *properties = nil;
        properties = [[UIDynamicItemBehavior alloc] initWithItems:@[circle]];
        properties.allowsRotation = NO;
        properties.elasticity = 1.0;
        properties.friction = 0.0;
        properties.resistance = 0.0;
        [self.animator addBehavior:properties];
    }
    
    UICollisionBehavior *collider = [[UICollisionBehavior alloc] initWithItems:self.circles];
    collider.collisionDelegate = self;
    collider.collisionMode = UICollisionBehaviorModeEverything;
    collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collider];
}

#pragma mark - Private methods

- (UIColor *)randomColor
{
    CGFloat red =  (CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX;
    CGFloat blue = (CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX;
    CGFloat green = (CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (CGVector)randomVector
{
    CGFloat dx =  (CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX;
    CGFloat dy = (CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX;
    return CGVectorMake(dx, dy);
}

@end
