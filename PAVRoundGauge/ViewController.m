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
    
    // nearly full sweep 
    [self.gaugeView setMinimumAngle:45.0];
    [self.gaugeView setMaximumAngle:315.0];
    
    // a high offset fuel guage
//    [self.gaugeView setMinimumAngle:135.0];
//    [self.gaugeView setMaximumAngle:225.0];
//    [self.gaugeView setPointerAxisOffset:0.66];
    
    [self.gaugeView setMaximumValue:10];
    [self.gaugeView setDelegate:self];
    
    // set animation style here
    [self.gaugeView setupGaugeWithStartingNumber:0 animationStyle:PAVRoundGaugeViewAnimationStyleRevUp];
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
