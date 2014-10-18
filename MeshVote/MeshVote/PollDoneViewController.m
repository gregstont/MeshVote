//
//  PollDoneViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "PollDoneViewController.h"
#import "UINavigationController+popTwice.h"
#import "BackgroundLayer.h"

@interface PollDoneViewController ()

@end

@implementation PollDoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    _checkImage.alpha = 0.0;
    _doneText.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _checkImage.alpha = 0.6;}
                     completion:nil];
    [UIView animateWithDuration:1.0 delay:0.3 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _doneText.alpha = 1.0;}
                     completion:nil];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        [NSThread sleepForTimeInterval:5.0f];

        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [self.navigationController popTwoViewControllersAnimated:YES];
            [self.navigationController setNavigationBarHidden:NO];
            //[self.navigationController popViewControllerAnimated:NO];
            //[self.navigationController popViewControllerAnimated:YES];
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
