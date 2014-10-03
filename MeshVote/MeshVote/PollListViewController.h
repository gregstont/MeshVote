//
//  PollListViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Message.h"

@interface PollListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) NSString* userName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end