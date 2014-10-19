//
//  EditQuestionViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "ResultsPollViewController.h"
#import "ResultsViewController.h"

#import "Colors.h"
#import "BackgroundLayer.h"
#import "SpacedUITableViewCell.h"

#import "BigMCSession.h"
#import "QuestionSet.h"
#import "Util.h"
#import "Results.h"


#define VIEWMODE_ADD_NEW_QUESTION   0
#define VIEWMODE_EDIT_QUESTION      1
#define VIEWMODE_ASK_QUESTION       2



@interface EditQuestionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, MCSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextView *questionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionNumberLabel;

@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) QuestionSet* questionSet;
@property (nonatomic, strong) NSMutableArray *pollSet; //the root array of QuestionSet

@property (nonatomic, strong) Question* currentQuestion;
@property (nonatomic) int currentQuestionNumber;
@property (nonatomic) int viewMode;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID* host;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)checkButtonPressed:(id)sender;
- (IBAction)checkButtonOutlinePressed:(id)sender;

-(void)moveToNextQuestion;


@end
