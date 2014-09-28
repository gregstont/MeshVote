//
//  ConnectingViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/27/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>
#import "MultipeerConnectivity/MCPeerID.h"
#import "MultipeerConnectivity/MCSession.h"
#import "Question.h"

@interface ConnectingViewController : UIViewController <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) NSString* sessionName;

@end
