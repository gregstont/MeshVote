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

@interface QuestionViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

//TODO: need to be private
@property (nonatomic, strong) NSMutableArray *questions; //change this later
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;


@end
