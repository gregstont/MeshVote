//
//  RunningPollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"
#import "MultipeerConnectivity/MCPeerID.h"
#import "MultipeerConnectivity/MCSession.h"


@interface RunningPollViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MCSessionDelegate>

- (NSString*)timeAsString:(int)time;
-(void)nextQuestion;

@property (nonatomic, strong) QuestionSet* questionSet;
@property (nonatomic, strong) MCSession* session;

- (IBAction)rewindPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)forwardPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *pollQuestionText;
@property (weak, nonatomic) IBOutlet UITableView *answerTable;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLetterLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *answerProgress;
@property (weak, nonatomic) IBOutlet UILabel *votesReceivedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalConnectedLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@end
