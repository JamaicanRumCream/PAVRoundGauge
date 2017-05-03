//
//  ViewController.m
//  PAVRoundGuage
//
//  Created by Chris Paveglio on 5/2/17.
//  Copyright © 2017 Paveglio.com. All rights reserved.
//

#import "ViewController.h"
#import "PAVRoundGuageView.h"


@interface ViewController ()

@property (nonatomic, strong) IBOutlet PAVRoundGuageView *guageView;
@property (nonatomic, strong) IBOutlet UITextField *toValueField;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.guageView setBackgroundImage:[UIImage imageNamed:@"GuageBackground"]];
    [self.guageView setPointerImage:[UIImage imageNamed:@"GuagePointer"]];
    [self.guageView setMinimumAngle:45.0];
    [self.guageView setMaximumAngle:315.0];
    [self.guageView setMaximumValue:10];
    [self.guageView setupGuageWithStartingNumber:0 animationStyle:PAVRoundGuageViewAnimationStyleRevUp];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAnimation:(id)sender {
    NSString *numberString = [self.toValueField text];
    [self.guageView animateToNumber:[numberString integerValue] identifier:@"TEST"];
}

- (IBAction)resetAnimation:(id)sender {
    [self.guageView resetPointerPosition];
}

- (IBAction)stopAnimation:(id)sender {
    [self.guageView stopAnimation];
}

@end
