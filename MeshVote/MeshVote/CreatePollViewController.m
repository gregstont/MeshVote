//
//  CreatePollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "CreatePollViewController.h"
#import "PollListViewController.h"

@interface CreatePollViewController ()

@property (nonatomic, strong) QuestionSet* tempQuestionSet;

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
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _tempQuestionSet = [[QuestionSet alloc] init];
    _tempQuestionSet.isQuiz = YES;
    _tempQuestionSet.showResults = YES;
    _tempQuestionSet.shareScores = NO; //not implemented
    
    
    _pollNameTextField.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES];
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

//
// UITextFieldDelegate
//

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // Indicate we're done with the keyboard. Make it go away.
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_saveButton setTitle:@"Done"];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_saveButton setTitle:@"Save"];
    _tempQuestionSet.name = textField.text;
}

- (IBAction)modeControlClicked:(id)sender
{
    _tempQuestionSet.isQuiz = !_modeControl.selectedSegmentIndex;
}

- (IBAction)shareResultsControlClicked:(id)sender
{
    _tempQuestionSet.showResults = !_shareResultsControl.selectedSegmentIndex;
}

- (IBAction)shareScoresSwitch:(id)sender  //not implemented
{
    _tempQuestionSet.shareScores = [_shareScoresOutlet isOn];
}

- (IBAction)saveButton:(id)sender
{
    if([_saveButton.title isEqualToString:@"Done"])
    {
        [_pollNameTextField resignFirstResponder];
    }
    else // save
    { 
        [_pollSet addObject:_tempQuestionSet];
        

        // we want to automatically segue to the new poll...
        int currentVCIndex = (int)[self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        
        PollListViewController* pollListVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
        pollListVC.returningFromAdd = YES;

        [self.navigationController popViewControllerAnimated:NO];
        [pollListVC performSegueWithIdentifier:@"showPollQuestionSegue" sender:pollListVC];
    }
}
@end
