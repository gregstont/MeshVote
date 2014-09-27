//
//  MeshVoteViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "MeshVoteViewController.h"
#import "BackgroundLayer.h"
#import "QuestionViewControllerTableViewController.h"
#import "JoinViewControllerTableViewController.h"

@interface MeshVoteViewController ()

@end

@implementation MeshVoteViewController

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad - MeshVoteViewController");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    //for keyboard exit
    [self.nameInput setDelegate:self];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if([textField.text isEqualToString:@"Name"]) {
        textField.text = @"";
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    //if([textView. isEqualToString:@)
}

- (IBAction)joinSession:(id)sender {
    NSLog(@"joinSession");
}

- (IBAction)createSession:(id)sender {
    NSLog(@"createSession");
}

- (IBAction)showAbout:(id)sender {
    NSLog(@"showAbout");

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"createSessionSeque"]){
        //NSLog(@"prepareForSegue");
        QuestionViewControllerTableViewController *controller = (QuestionViewControllerTableViewController *)segue.destinationViewController;
        controller.userName = _nameInput.text;
    }
    else if([segue.identifier isEqualToString:@"joinSessionSeque"]){
        NSLog(@"prepareForSegue");
        JoinViewControllerTableViewController *controller = (JoinViewControllerTableViewController *)segue.destinationViewController;
        controller.userName = _nameInput.text;
    }
}
@end
