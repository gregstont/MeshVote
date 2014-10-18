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
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    
    CGRect temp = CGRectZero;
    temp.size.width = 640;
    temp.size.height = 1136;
    temp.origin.y = -90;
    
    
    bgLayer.frame = temp;//self.view.bounds;
    //bgLayer.frame.size.height = 990;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _tempQuestionSet = [[QuestionSet alloc] init];
    _tempQuestionSet.isQuiz = YES;
    _tempQuestionSet.showResults = YES;
    _tempQuestionSet.shareScores = NO; //not implemented
    
    if(_tempQuestionSet.isQuiz)
        [_modeSwitchText setText:@"quiz"];
    else
        [_modeSwitchText setText:@"poll"];
    
    
    _pollNameTextField.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_saveButton setTitle:@"Done"];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //if([textView. isEqualToString:@)
    [_saveButton setTitle:@"Save"];
    _tempQuestionSet.name = textField.text;
}

- (IBAction)modeControlClicked:(id)sender {
    _tempQuestionSet.isQuiz = !_modeControl.selectedSegmentIndex;
}

- (IBAction)shareResultsControlClicked:(id)sender {
    _tempQuestionSet.showResults = !_shareResultsControl.selectedSegmentIndex;
}

- (IBAction)modeSwitch:(id)sender {
    _tempQuestionSet.isQuiz = [_modeSwitchOutlet isOn];
    if(_tempQuestionSet.isQuiz) {
        [_modeSwitchText setText:@"quiz"];
        //_shareScoresTextTitle.hidden = NO; //deprecated
        //_shareScoresTextDetail.hidden = NO;
        //_shareScoresOutlet.hidden = NO;
    }
    else {
        [_modeSwitchText setText:@"poll"];
        //_shareScoresTextTitle.hidden = YES;
        //_shareScoresTextDetail.hidden = YES;
        //_shareScoresOutlet.hidden = YES;
    }
    
}

- (IBAction)showResultsSwitch:(id)sender {
    _tempQuestionSet.showResults = [_showResultsOutlet isOn];
}

- (IBAction)shareScoresSwitch:(id)sender {
    _tempQuestionSet.shareScores = [_shareScoresOutlet isOn];
}

- (IBAction)saveButton:(id)sender {
    if([_saveButton.title isEqualToString:@"Done"]) {
        [_pollNameTextField resignFirstResponder];
    }
    else { // save
        [_pollSet addObject:_tempQuestionSet];
        
        
        // get the index of the visible VC on the stack
        int currentVCIndex = (int)[self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        // get a reference to the previous VC
        //UITabBarController *prevVC = (UITabBarController *)[self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
        
        PollListViewController* pollListVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
        pollListVC.returningFromAdd = YES;

        //[pollListVC performSegueWithIdentifier:@"showPollQuestionSegue" sender:pollListVC];
        //[self performSegueWithIdentifier:@"startTakingPollSegue" sender:self];
        
        // get the VC shown by the previous VC
        //EventInformationViewController *prevShownVC = (EventInformationViewController *)prevVC.selectedViewController;
        //[prevShownVC performSelector:@selector(rateCurrentEvent:)];
        
        [self.navigationController popViewControllerAnimated:NO];
        
        [pollListVC performSegueWithIdentifier:@"showPollQuestionSegue" sender:pollListVC];
    }
}
@end
