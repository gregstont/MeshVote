//
//  QuestionViewControllerTableViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "EditQuestionViewController.h"
#import "RunningPollViewController.h"

#import "TipTableViewCell.h"

#import "BigMCSession.h"
#import "QuestionSet.h"
#import "Question.h"
#import "Util.h"


@interface QuestionViewControllerTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BigMCSessionDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;



@property (nonatomic, strong) NSString* userName;

@property (nonatomic, strong) BigMCSession* bigSession;
@property (nonatomic, strong) NSMutableDictionary *peerList;

@property (nonatomic, strong) QuestionSet *questionSet;
@property (nonatomic, strong) NSMutableArray *pollSet; // the root array of QuestionSet


- (IBAction)addNewQuestion:(id)sender;
- (IBAction)playPressed:(UIButton *)sender;

@end
