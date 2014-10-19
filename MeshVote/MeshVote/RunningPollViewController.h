//
//  RunningPollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "ResultsViewController.h"
#import "ResultsPollViewController.h"

#import "RunningAnswerTableViewCell.h"
#import "KAProgressLabel.h"
#import "BackgroundLayer.h"

#import "QuestionSet.h"
#import "Question.h"
#import "Colors.h"
#import "BigMCSession.h"


@interface RunningPollViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BigMCSessionDelegate>

- (NSString*)timeAsString:(int)time;

@property (nonatomic, strong) QuestionSet* questionSet;
@property (nonatomic, strong) BigMCSession* bigSession;
@property (atomic, strong) NSMutableDictionary *peerList;

// circular progress bars
@property (weak, nonatomic) IBOutlet KAProgressLabel *votesProgressLabel;
@property (weak, nonatomic) IBOutlet KAProgressLabel *timeProgressLabel;

@property (weak, nonatomic) IBOutlet UITextView *pollQuestionText;
@property (weak, nonatomic) IBOutlet UITableView *answerTable;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLetterLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *answerProgress;
@property (weak, nonatomic) IBOutlet UILabel *votesReceivedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalConnectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;


- (IBAction)rewindPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)forwardPressed:(UIButton *)sender;

@end
