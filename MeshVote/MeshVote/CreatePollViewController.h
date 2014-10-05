//
//  CreatePollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundLayer.h"
#import "QuestionSet.h"

@interface CreatePollViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pollNameTextField;

@property (nonatomic, strong) NSMutableArray *pollSet; //handed down from PollListVC

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UISwitch *modeSwitchOutlet;
@property (weak, nonatomic) IBOutlet UILabel *modeSwitchText;
@property (weak, nonatomic) IBOutlet UISwitch *showResultsOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *shareScoresOutlet;
@property (weak, nonatomic) IBOutlet UILabel *shareScoresTextTitle;
@property (weak, nonatomic) IBOutlet UITextView *shareScoresTextDetail;



- (IBAction)saveButton:(id)sender;
- (IBAction)modeSwitch:(id)sender;
- (IBAction)showResultsSwitch:(id)sender;
- (IBAction)shareScoresSwitch:(id)sender;



@end
