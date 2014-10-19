//
//  MeshVoteViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "MeshVoteViewController.h"


@interface MeshVoteViewController ()

@end

@implementation MeshVoteViewController

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad - MeshVoteViewController");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // add bg gradient layer
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _nameInput.delegate = self;
    
    // load user name from disk
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    if(userName)
        _nameInput.text = userName;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // save name to disk
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"userName"];
    [defaults synchronize];
}

- (IBAction)joinSession:(id)sender
{
    NSLog(@"joinSession");
}

- (IBAction)createSession:(id)sender
{
    NSLog(@"createSession");
}

- (IBAction)showAbout:(id)sender
{
    NSLog(@"showAbout");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    
    if([_nameInput.text isEqualToString:@""]) //TODO: alert user to input name
    {
        _nameInput.text = [NSString stringWithFormat:@"User%d",arc4random_uniform(9999)];
    }
    
    if([segue.identifier isEqualToString:@"showPollListSegue"])
    {
        // create session
        PollListViewController *controller = (PollListViewController *)segue.destinationViewController;
        controller.userName = _nameInput.text;
    }
    else if([segue.identifier isEqualToString:@"joinSessionSegue"])
    {
        // join session
        JoinViewControllerTableViewController *controller = (JoinViewControllerTableViewController *)segue.destinationViewController;
        controller.userName = _nameInput.text;
    }
}
@end
