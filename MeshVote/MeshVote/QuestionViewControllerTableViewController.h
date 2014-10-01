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

@interface QuestionViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, EditQuestionViewControllerDelegate, MCNearbyServiceAdvertiserDelegate>

- (IBAction)addNewQuestion:(id)sender;
- (IBAction)playPressed:(UIButton *)sender;

@property (nonatomic, strong) NSString* userName;


@end
