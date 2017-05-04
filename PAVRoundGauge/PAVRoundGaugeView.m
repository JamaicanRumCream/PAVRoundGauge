//
//  PAVRoundGaugeView.m
//  PAVRoundGauge
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "PAVRoundGaugeView.h"

/** This starts 0 degrees at bottom of circle, 180 is pointing upward */
float PAVGaugeDegreesToRadians(float degrees) { return (degrees - 180) * (M_PI / 180); };


@interface PAVRoundGaugeView () <CAAnimationDelegate>

@property (nonatomic, assign) PAVRoundGaugeViewAnimationStyle animationStyle;

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *sweptAreaMaskImageView;
@property (nonatomic, strong) UIImageView *numberAndTickmarkImageView;
@property (nonatomic, strong) UIImageView *pointerView;
@property (nonatomic, strong) UIImageView *frontBezelImageView;

/** The angle in degrees where the pointer can start, will be 0 if not set. */
@property (nonatomic, assign) CGFloat minimumAngle;

/** The angle in degrees where the pointer will stop and go no further, REQUIRED. */
@property (nonatomic, assign) CGFloat maximumAngle;

/** The maximum value the gauge can show; it should be a whole number
 such as 10 for max questions answered, or 550 for max speed points.
 MUST ALWAYS be set after the angle values are set! */
@property (nonatomic, assign) CGFloat maximumValue;

/** Value that defines the # of angle degress for each whole number value that will be animated */
@property (nonatomic, assign) CGFloat degreesPerPoint;

/** Number of the starting value, for example fuel guage starts at half and then increased */
@property (nonatomic, assign) NSUInteger startingNumber;

/** Name of the animation */
@property (nonatomic, strong) NSString *identifier;

@end


@implementation PAVRoundGaugeView

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
    self.backgroundView             = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.sweptAreaMaskImageView     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.numberAndTickmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.pointerView                = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.frontBezelImageView        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    for (UIImageView *aView in @[self.backgroundView, self.sweptAreaMaskImageView, self.numberAndTickmarkImageView, self.pointerView, self.frontBezelImageView]) {
        aView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:aView];
    }
    
    //rotate the view to it's initial "start angle" state
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGaugeDegreesToRadians(0.0));
    [self.pointerView setTransform:pointerTransform];
    
    [self setClipsToBounds:YES];
}

- (void)setupGaugeWithStartingNumber:(NSUInteger)startingNumber maxValue:(CGFloat)maximumValue minAngle:(CGFloat)minimumAngle maxAngle:(CGFloat)maximumAngle animationStyle:(PAVRoundGaugeViewAnimationStyle)animationStyle {
    
    _startingNumber = startingNumber;
    _animationStyle = animationStyle;
    
    [self setMinimumAngle:minimumAngle];
    [self setMaximumAngle:maximumAngle];
    // maxValue MUST ALWAYS be set AFTER ANGLES
    [self setMaximumValue:maximumValue];
    
    // add the start number value to the minAngle so it's offset
    CGFloat degreesToOffset = ((self.maximumAngle - self.minimumAngle) / self.maximumValue) * (CGFloat)startingNumber;
    self.minimumAngle += degreesToOffset;
    
    // rotate the pointer to it's minimum (real-life/visual) state
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGaugeDegreesToRadians(self.minimumAngle));
    [self.pointerView setTransform:pointerTransform];
}



#pragma mark - Delegate Methods

/** Delegate method that will inform delegate that animation has been finished successfully */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && [self.delegate respondsToSelector:@selector(pavRoundGaugeView:didCompleteWithIdentifier:)]) {
        [self.delegate pavRoundGaugeView:self didCompleteWithIdentifier:self.identifier];
    }
}



#pragma mark - Animations

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber identifier:(NSString *)idenfifier {
    // need to set as an object property b/c I can't save it to the animation directly
    self.identifier = idenfifier;
    
    CAKeyframeAnimation *animation;
    
    switch (self.animationStyle) {
        case PAVRoundGaugeViewAnimationStyleRevUp:
            animation = [self revUpAnimationForNumber:newNumber];
            break;
        case PAVRoundGaugeViewAnimationStylePegged:
            animation = [self peggedAnimationForNumber:newNumber];
            break;
        case PAVRoundGaugeViewAnimationStyleSmooth:
            animation = [self smoothAnimationForNumber:newNumber];
            break;
            
        default:
            break;
    }
    
    // set delegate so we can fire animationDidStop
    animation.delegate = self;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    [self.pointerView.layer addAnimation:animation forKey:@"transform.rotation.z"];
}

/** Calculate degrees given the integer value and a multiplier (for animation keyframes) */
- (CGFloat)degreesFromMinimumAngleForNumber:(NSUInteger)newNumber multiplier:(CGFloat)multiplier {
    // find degrees to rotate given new number and subtract the starting number
    CGFloat degreesToRotate = self.degreesPerPoint * ((CGFloat)newNumber - (CGFloat)self.startingNumber) * multiplier;
    degreesToRotate += self.minimumAngle;
    return degreesToRotate;
}

/** Animation where the needle goes farther than the final resting number momentarily.
 IMPORTANT NOTE: Rotations do not always go in the correct direction when over 180°, so
 build an animation that has 2 half-rotations so it goes the right way,
 and continues the right way.*/
- (CAKeyframeAnimation *)revUpAnimationForNumber:(NSUInteger)newNumber {
    CGFloat halfDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:0.5];
    CGFloat fullDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.0];
    CGFloat overRevDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.1];
    
    CAKeyframeAnimation* animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.duration = 2.0;
    
    animation.values = @[[NSNumber numberWithFloat:PAVGaugeDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(overRevDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(fullDegreesToRotate)],
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
    
    animation.duration = 1.5;
    
    // 15 values
    animation.values = @[[NSNumber numberWithFloat:PAVGaugeDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.1])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.9])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.068])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.935])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.045])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.965])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.030])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.979])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.018])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.985])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:1.012])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians([self degreesFromMinimumAngleForNumber:newNumber multiplier:0.990])],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(fullDegreesToRotate)],
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

/** Animation where the needle goes from 0 to max smoothly */
- (CAKeyframeAnimation *)smoothAnimationForNumber:(NSUInteger)newNumber {
    CGFloat halfDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:0.5];
    CGFloat fullDegreesToRotate = [self degreesFromMinimumAngleForNumber:newNumber multiplier:1.0];
    
    CAKeyframeAnimation* animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.duration = 2.0;
    
    animation.values = @[[NSNumber numberWithFloat:PAVGaugeDegreesToRadians(self.minimumAngle)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(halfDegreesToRotate)],
                         [NSNumber numberWithFloat:PAVGaugeDegreesToRadians(fullDegreesToRotate)],
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
    
    CGAffineTransform pointerTransform = CGAffineTransformRotate(CGAffineTransformIdentity, PAVGaugeDegreesToRadians(self.minimumAngle));
    [self.pointerView setTransform:pointerTransform];
}



#pragma mark - Property Overrides / Setters

- (void)setMaximumValue:(CGFloat)maximumValue {
    // IMPORTANT: Always be sure angle values are set before calling this setter
    _maximumValue = maximumValue;
    
    NSAssert(maximumValue != 0, @"🚫 Attempting to set maximumValue at 0 which will cause Ø division.");
    NSAssert(self.maximumAngle > 0, @"🚫 maximumAngle is 0 and should be greater than Ø.");
    
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

- (void)setPointerAxisOffset:(CGFloat)pointerAxisOffset {
    // catch illegal values
    if (pointerAxisOffset > 1.0 || pointerAxisOffset < 0.0) {
        return;
    }
    _pointerAxisOffset = pointerAxisOffset;
    self.pointerView.center = CGPointMake(0.5 * CGRectGetWidth(self.frame), pointerAxisOffset * CGRectGetHeight(self.frame));
}

@end
