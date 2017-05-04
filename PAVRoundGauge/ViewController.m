//
//  ViewController.m
//  PAVRoundGauge
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "ViewController.h"
#import "PAVRoundGaugeView.h"


@interface ViewController () <pavRoundGaugeViewDelegate>

@property (nonatomic, strong) IBOutlet PAVRoundGaugeView *gaugeView;
@property (nonatomic, strong) IBOutlet UITextField *toValueField;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.gaugeView setBackgroundImage:[UIImage imageNamed:@"GaugeBackground"]];
    [self.gaugeView setPointerImage:[UIImage imageNamed:@"GaugePointer"]];
    [self.gaugeView setDelegate:self];

    
    // nearly full sweep like speedo/tach
//    [self.gaugeView setupGaugeWithStartingNumber:0 maxValue:10 minAngle:45 maxAngle:315 animationStyle:PAVRoundGaugeViewAnimationStyleRevUp];
    
    [self.gaugeView setupGaugeWithStartingNumber:3 maxValue:10 minAngle:45 maxAngle:315 animationStyle:PAVRoundGaugeViewAnimationStylePegged];
    
    
    // a high offset fuel guage
//    [self.gaugeView setPointerAxisOffset:0.66];
//    [self.gaugeView setupGaugeWithStartingNumber:0 maxValue:10 minAngle:135 maxAngle:225 animationStyle:PAVRoundGaugeViewAnimationStyleSmooth];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAnimation:(id)sender {
    NSString *numberString = [self.toValueField text];
    [self.gaugeView animateToNumber:[numberString integerValue] identifier:@"TEST"];
}

- (IBAction)resetAnimation:(id)sender {
    [self.gaugeView resetPointerPosition];
}

- (IBAction)stopAnimation:(id)sender {
    [self.gaugeView stopAnimation];
}

- (void)pavRoundGaugeView:(PAVRoundGaugeView *)gaugeView didCompleteWithIdentifier:(NSString *)identifier {
    printf(" Guage animation complete, ID: %s", [identifier UTF8String]);
}

@end
