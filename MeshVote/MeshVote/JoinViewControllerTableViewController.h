//
//  JoinViewControllerTableViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/17/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Question.h"

@interface JoinViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) NSString* userName;


@end
