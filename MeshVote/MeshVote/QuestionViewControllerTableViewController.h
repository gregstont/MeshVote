//
//  QuestionViewControllerTableViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipeerConnectivity/MCNearbyServiceBrowser.h"
//#import "MultipeerConnectivity/MC
#import <MultipeerConnectivity/MCAdvertiserAssistant.h>
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>

//#import <MultipeerConnectivity/MCNearbyServiceBrowser.h>
#import "MultipeerConnectivity/MCPeerID.h"
#import "MultipeerConnectivity/MCSession.h"
#import "EditQuestionViewController.h"

@interface QuestionViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, EditQuestionViewControllerDelegate>

- (IBAction)addNewQuestion:(id)sender;

@property (nonatomic, strong) NSString* userName;


@end
