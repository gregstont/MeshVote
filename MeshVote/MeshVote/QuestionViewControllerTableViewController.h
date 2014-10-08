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

@interface QuestionViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

- (IBAction)addNewQuestion:(id)sender;
- (IBAction)playPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString* userName;
@property (nonatomic, NS_NONATOMIC_IOSONLY) MCSession *session;

@property (nonatomic, strong) NSMutableDictionary *peerList;

@property (nonatomic, strong) QuestionSet *questionSet; 
@property (nonatomic, strong) NSMutableArray *pollSet; //the root array of QuestionSet


@end
