//
//  MeshVoteViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "MeshVoteViewController.h"
#import "BackgroundLayer.h"

@interface MeshVoteViewController ()

@end

@implementation MeshVoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    //for keyboard exit
    [self.nameInput setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This gets called by the framework when the user touches the Return key on the keyboard.
// Make sure to include <UITextFieldDelegate> in the class' interface definition.
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // Indicate we're done with the keyboard. Make it go away.
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)joinSession:(id)sender {
    NSLog(@"joinSession");
}

- (IBAction)createSession:(id)sender {
    NSLog(@"createSession");
}

- (IBAction)showAbout:(id)sender {
    NSLog(@"showAbout");
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
}
@end
