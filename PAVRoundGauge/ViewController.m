//
//  ViewController.m
//  PAVRoundGauge
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "ViewController.h"
#import "PAVRoundGaugeView.h"


@interface ViewController ()

@property (nonatomic, strong) IBOutlet PAVRoundGaugeView *gaugeView;
@property (nonatomic, strong) IBOutlet UITextField *toValueField;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.gaugeView setBackgroundImage:[UIImage imageNamed:@"GaugeBackground"]];
    [self.gaugeView setPointerImage:[UIImage imageNamed:@"GaugePointer"]];
    [self.gaugeView setMinimumAngle:45.0];
    [self.gaugeView setMaximumAngle:315.0];
    [self.gaugeView setMaximumValue:10];
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

@end
