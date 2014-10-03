//
//  CreatePollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "CreatePollViewController.h"

@interface CreatePollViewController ()

@end

@implementation CreatePollViewController

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
    // Do any additional setup after loading the view.
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    
    CGRect temp = CGRectZero;
    temp.size.width = 640;
    temp.size.height = 1136;
    temp.origin.y = -90;
    
    
    bgLayer.frame = temp;//self.view.bounds;
    //bgLayer.frame.size.height = 990;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
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
