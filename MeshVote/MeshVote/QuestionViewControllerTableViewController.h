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
#import "BigMCSession.h"

@interface QuestionViewControllerTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, BigMCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

- (IBAction)addNewQuestion:(id)sender;
- (IBAction)playPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UILabel *createQuestionHintLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *createQuestionHintArrow;
//@property (weak, nonatomic) IBOutlet UITextView *tipTextView;

@property (nonatomic, strong) NSString* userName;
//@property (nonatomic, NS_NONATOMIC_IOSONLY) MCSession *session;
@property (nonatomic, strong) BigMCSession* bigSession;

@property (nonatomic, strong) NSMutableDictionary *peerList;

@property (nonatomic, strong) QuestionSet *questionSet;
@property (nonatomic, strong) NSMutableArray *pollSet; //the root array of QuestionSet


@end
