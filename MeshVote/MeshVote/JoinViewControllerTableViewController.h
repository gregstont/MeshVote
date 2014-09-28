//
//  JoinViewControllerTableViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/17/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>
#import <MultipeerConnectivity/MCNearbyServiceBrowser.h>
#import <MultipeerConnectivity/MCAdvertiserAssistant.h>
#import "MultipeerConnectivity/MCPeerID.h"
#import "MultipeerConnectivity/MCSession.h"
#import "Question.h"

@interface JoinViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) NSString* userName;


@end
