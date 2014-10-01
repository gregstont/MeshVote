//
//  EditQuestionViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"
#import "MultipeerConnectivity/MCSession.h"
#import "MultipeerConnectivity/MCPeerID.h"


#define VIEWMODE_ADD_NEW_QUESTION   0
#define VIEWMODE_EDIT_QUESTION      1
#define VIEWMODE_ASK_QUESTION       2

@class EditQuestionViewController;
@protocol EditQuestionViewControllerDelegate <NSObject>

-(Question*)getQuestionAtIndex:(int)index;

-(NSString*)getQuestionTextAtIndex:(int)index;

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex;

-(void)addQuestionToSet:(Question*)question;

-(int)getAnswerCountAtIndex:(int)index;

-(int)getSelectedQuestion;


@end


@interface EditQuestionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, MCSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextView *questionTextLabel;
@property (strong, nonatomic) id <EditQuestionViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) QuestionSet* questionSet;

@property (nonatomic, strong) Question* currentQuestion;
@property (nonatomic) int currentQuestionNumber;
//@property (nonatomic, strong) Question* nextQuestion; //for pre-loading when asking
@property (nonatomic) int viewMode;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID* host;

- (IBAction)doneButtonPressed:(id)sender;
-(void)moveToNextQuestion;


@end
