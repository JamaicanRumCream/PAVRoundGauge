//
//  PAVRoundGaugeView.h
//  PAVRoundGauge
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//
//  An analog style guage like an automobile gauge such as speedometer,
//  tachometer, fuel level, volts, etc.
//  Has layers of images. The needle center defaults to the middle of the view
//  which should be made perfectly square. Needle center can be offset vertically.
//  Needle angle of Ø points downward. Will sweep clockwise when the animation value
//  increases. Can be made to go from high value to a lower value and moves CCW.

#import <UIKit/UIKit.h>
@class PAVRoundGaugeView;


typedef enum : NSUInteger {
    PAVRoundGaugeViewAnimationStyleRevUp,
    PAVRoundGaugeViewAnimationStyleSmooth,
    PAVRoundGaugeViewAnimationStylePegged,
} PAVRoundGaugeViewAnimationStyle;


@protocol pavRoundGaugeViewDelegate <NSObject>

@optional
- (void)pavRoundGaugeView:(PAVRoundGaugeView *)gaugeView didCompleteWithIdentifier:(NSString *)identifier;

@end


@interface PAVRoundGaugeView : UIView

@property (nonatomic, strong) id<pavRoundGaugeViewDelegate> delegate;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *sweptAreaMaskImage;
@property (nonatomic, strong) UIImage *numberAndTickmarkImage;
@property (nonatomic, strong) UIImage *pointerImage;
@property (nonatomic, strong) UIImage *frontBezelImage;

/** Pointers whose center is not the center of the entire gauge
 offset the pointer center. 0.5 is center, 0 is top of gauge, 1 is bottom of gauge. */
@property (nonatomic, assign) CGFloat pointerAxisOffset;

- (void)setupGaugeWithStartingNumber:(NSUInteger)startingNumber maxValue:(CGFloat)maximumValue minAngle:(CGFloat)minimumAngle maxAngle:(CGFloat)maximumAngle animationStyle:(PAVRoundGaugeViewAnimationStyle)animationStyle;

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber identifier:(NSString *)idenfifier;

- (void)stopAnimation;
- (void)resetPointerPosition;

@end
