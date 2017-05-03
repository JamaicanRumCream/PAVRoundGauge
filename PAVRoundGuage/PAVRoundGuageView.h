//
//  PAVRoundGuageView.h
//  PAVRoundGuage
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PAVRoundGuageView;


typedef enum : NSUInteger {
    PAVRoundGuageViewAnimationStyleRevUp,
    PAVRoundGuageViewAnimationStyleSmooth,
    PAVRoundGuageViewAnimationStylePegged,
} PAVRoundGuageViewAnimationStyle;


@protocol pavRoundGuageViewDelegate <NSObject>

@optional
- (void)pavRoundGuageView:(PAVRoundGuageView *)guageView didCompleteWithIdentifier:(NSString *)identifier;

@end


@interface PAVRoundGuageView : UIView

@property (nonatomic, strong) id<pavRoundGuageViewDelegate> delegate;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *sweptAreaMaskImage;
@property (nonatomic, strong) UIImage *numberAndTickmarkImage;
@property (nonatomic, strong) UIImage *pointerImage;
@property (nonatomic, strong) UIImage *frontBezelImage;

/** The angle in degrees where the point can start */
@property (nonatomic, assign) CGFloat minimumAngle;

/** The angle in degrees where the pointer will stop and go no further, can be empty */
@property (nonatomic, assign) CGFloat maximumAngle;

/** The maximum value the guage can show; it should be a whole number
 such as 10 for max questions answered, or 550 for max speed points */
@property (nonatomic, assign) CGFloat maximumValue;

/** Pointers whose center is not the center of the entire guage
 offset the pointer center. 0.5 is center, 0 is bottom of guage, 1 is top of guage */
@property (nonatomic, assign) CGFloat pointerAxisOffset;

- (void)setupGuageWithStartingNumber:(NSUInteger)startingNumber animationStyle:(PAVRoundGuageViewAnimationStyle)animationStyle;

/** Animates to the new number, as long as it is higher than current number, and returns with the given identifier */
- (void)animateToNumber:(NSUInteger)newNumber identifier:(NSString *)idenfifier;

- (void)stopAnimation;
- (void)resetPointerPosition;

@end
