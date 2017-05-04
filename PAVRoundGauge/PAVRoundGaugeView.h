//
//  PAVRoundGaugeView.h
//  PAVRoundGauge
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

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

/** The angle in degrees where the pointer can start, will be 0 if not set. */
@property (nonatomic, assign) CGFloat minimumAngle;

/** The angle in degrees where the pointer will stop and go no further, REQUIRED. */
@property (nonatomic, assign) CGFloat maximumAngle;

/** The maximum value the gauge can show; it should be a whole number
 such as 10 for max questions answered, or 550 for max speed points. */
@property (nonatomic, assign) CGFloat maximumValue;

/** Pointers whose center is not the center of the entire gauge
 offset the pointer center. 0.5 is center, 0 is top of gauge, 1 is bottom of gauge. */
@property (nonatomic, assign) CGFloat pointerAxisOffset;

- (void)setupGaugeWithStartingNumber:(NSUInteger)startingNumber animationStyle:(PAVRoundGaugeViewAnimationStyle)animationStyle;

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber identifier:(NSString *)idenfifier;

- (void)stopAnimation;
- (void)resetPointerPosition;

@end
