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
@property (weak, nonatomic) IBOutlet UILabel *statusLabelBottom;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingActivityIndicator;

@property (nonatomic, strong) NSString* sessionName;

@property (nonatomic, strong) NSString *userName;

@end
