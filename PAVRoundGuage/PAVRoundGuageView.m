//
//  PAVRoundGuageView.m
//  PAVRoundGuage
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "PAVRoundGuageView.h"

/** This starts 0 degrees at bottom of circle, 180 is pointing upward */
float PAVGuageDegreesToRadians(float degrees) { return (degrees - 180) * (M_PI / 180); };


@interface PAVRoundGuageView () <CAAnimationDelegate>

@property (nonatomic, assign) PAVRoundGuageViewAnimationStyle animationStyle;

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *sweptAreaMaskImageView;
@property (nonatomic, strong) UIImageView *numberAndTickmarkImageView;
@property (nonatomic, strong) UIImageView *pointerView;
@property (nonatomic, strong) UIImageView *frontBezelImageView;

/** Value that defines the # of angle degress for each whole number value that will be animated */
@property (nonatomic, assign) CGFloat degreesPerPoint;

/** name of the animation */
@property (nonatomic, strong) NSString *identifier;

@end


@implementation PAVRoundGuageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

/** Setup put the pieces in position but can't set the images until the setters take care of them */
- (void)setup {
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.sweptAreaMaskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.numberAndTickmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.pointerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.frontBezelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    for (UIImageView *aView in @[self.backgroundView, self.sweptAreaMaskImageView, self.numberAndTickmarkImageView, self.pointerView, self.frontBezelImageView]) {
        aView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:aView];
    }
    
    //rotate the view to it's initial "start angle" state
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGuageDegreesToRadians(0.0));
    [self.pointerView setTransform:pointerTransform];
    
    [self setClipsToBounds:YES];
}

- (void)setupGuageWithStartingNumber:(NSUInteger)startingNumber animationStyle:(PAVRoundGuageViewAnimationStyle)animationStyle {
    _animationStyle = animationStyle;
    
    // rotate the pointer to it's minimum (real-life/visual) state
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGuageDegreesToRadians(self.minimumAngle));
    [self.pointerView setTransform:pointerTransform];
}

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber identifier:(NSString *)idenfifier {
    // need to set as an object property b/c I can't save it to the animation directly
    self.identifier = idenfifier;
    
    /* Rotations do not always go in the correct direction when over 180°, so
     build an animation that has 2 half-rotations so it goes the right way,
     and continues the right way.*/
    
    CALayer* layer = self.pointerView.layer;
    
//    CAKeyframeAnimation *animation = [self revUpAnimationForNumber:newNumber];
    CAKeyframeAnimation *animation = [self peggedAnimationForNumber:newNumber];
//    CAKeyframeAnimation *animation = [self smoothAnimationForNumber:newNumber];
    
    [layer addAnimation:animation forKey:@"transform.rotation.z"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && [self.delegate respondsToSelector:@selector(pavRoundGuageView:didCompleteWithIdentifier:)]) {
        [self.delegate pavRoundGuageView:self didCompleteWithIdentifier:self.identifier];
    }
}

/** Calculate degrees given the integer value and a multiplier */
- (CGFloat)degreesFromMinimumAngleForNumber:(NSUInteger)newNumber multiplier:(CGFloat)multiplier {
    CGFloat degreesToRotate = self.degreesPerPoint * (CGFloat)newNumber * multiplier;
    degreesToRotate += self.minimumAngle;
    return degreesToRotate;
}

/** Animation where the needle goes farther than the final resting number momentarily */
- (CAKeyframeAnimation *)revUpAnimationForNumber:(NSUInteger)newNumber {
    CGFloat halfDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:0.5];
    CGFloat fullDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.0];
    CGFloat overRevDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.1];
    
    CAKeyframeAnimation* animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // set delegate so we can fire animationDidStop
    animation.delegate = self;
    animation.duration = 2.0;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    animation.values = @[[NSNumber numberWithFloat:PAVGuageDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(overRevDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(fullDegreesToRotate)],
                         ];
    
    animation.keyTimes = @[[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.3],
                           [NSNumber numberWithFloat:0.7],
                           [NSNumber numberWithFloat:1.0],
                           ];
    
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                  ];
    
    return animation;
}

/** Animation where the needle goes almost instantly to the value then has a little springy wiggle */
- (CAKeyframeAnimation *)peggedAnimationForNumber:(NSUInteger)newNumber {
    CGFloat halfDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:0.5];
    CGFloat fullDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.0];
    
    
    CAKeyframeAnimation* animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // set delegate so we can fire animationDidStop
    animation.delegate = self;
    animation.duration = 1.5;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    // 15 values
    animation.values = @[[NSNumber numberWithFloat:PAVGuageDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.1])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.9])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.068])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.935])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.045])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.965])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.030])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.979])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.018])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.985])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.012])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.990])],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(fullDegreesToRotate)],
                         ];
    
    animation.keyTimes = @[[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.027],
                           [NSNumber numberWithFloat:0.055],
                           [NSNumber numberWithFloat:0.074],
                           [NSNumber numberWithFloat:0.092],
                           [NSNumber numberWithFloat:0.120],
                           [NSNumber numberWithFloat:0.148],
                           [NSNumber numberWithFloat:0.185],
                           [NSNumber numberWithFloat:0.240],
                           [NSNumber numberWithFloat:0.314],
                           [NSNumber numberWithFloat:0.387],
                           [NSNumber numberWithFloat:0.501],
                           [NSNumber numberWithFloat:0.627],
                           [NSNumber numberWithFloat:0.740],
                           [NSNumber numberWithFloat:1.0],
                           ];
    
    // 14 timings
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                  ];
    
    return animation;
}

/** Animation where the needle goes from 0 to max smootly */
- (CAKeyframeAnimation *)smoothAnimationForNumber:(NSUInteger)newNumber {
    CGFloat halfDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:0.5];
    CGFloat fullDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.0];
    
    CAKeyframeAnimation* animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // set delegate so we can fire animationDidStop
    animation.delegate = self;
    animation.duration = 2.0;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    animation.values = @[[NSNumber numberWithFloat:PAVGuageDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGuageDegreesToRadians(fullDegreesToRotate)],
                         ];
    
    animation.keyTimes = @[[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:1.0],
                           ];
    
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                  ];
    
    return animation;
}



/** Stops the animation immediately and leaves the pointer in the position it was at that very moment */
- (void)stopAnimation {
    self.pointerView.layer.transform = self.pointerView.layer.presentationLayer.transform;
    [self.pointerView.layer removeAllAnimations];
}

- (void)resetPointerPosition {
    [self.pointerView.layer removeAllAnimations];
    
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGuageDegreesToRadians(self.minimumAngle));
    [self.pointerView setTransform:pointerTransform];
}



#pragma mark - Property Overrides / Setters

- (void)setMaximumValue:(CGFloat)maximumValue {
    _maximumValue = maximumValue;
    if (maximumValue == 0) {
        NSAssert(maximumValue == 0, @"Attempting to set maximumValue at 0 which will cause Ø division.");
    }
    self.degreesPerPoint = (self.maximumAngle - self.minimumAngle) / _maximumValue;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundView.image = self.backgroundImage;
}

- (void)setPointerImage:(UIImage *)pointerImage {
    _pointerImage = pointerImage;
    self.pointerView.image = self.pointerImage;
}

- (void)setSweptAreaMaskImage:(UIImage *)sweptAreaMaskImage {
    _sweptAreaMaskImage = sweptAreaMaskImage;
    self.sweptAreaMaskImageView.image = self.sweptAreaMaskImage;
}

- (void)setNumberAndTickmarkImage:(UIImage *)numberAndTickmarkImage {
    _numberAndTickmarkImage = numberAndTickmarkImage;
    self.numberAndTickmarkImageView.image = self.numberAndTickmarkImage;
}

- (void)setFrontBezelImage:(UIImage *)frontBezelImage {
    _frontBezelImage = frontBezelImage;
    self.frontBezelImageView.image = self.frontBezelImage;
}

@end
