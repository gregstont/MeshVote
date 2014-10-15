//
//  BigMCSession.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/14/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



@class BigMCSession;

@protocol BigMCSessionDelegate <NSObject>

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state;

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

/*
// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID;

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress;

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error;

*/

@end


@interface BigMCSession : NSObject <MCSessionDelegate>

@property (nonatomic) int peerCount;
@property (weak, nonatomic) id <BigMCSessionDelegate> delegate;
@property (nonatomic, strong) NSMutableArray* sessionList;

-(id)initWithPeer:(MCPeerID*)peerID;
-(MCSession*)getAvailableSession;
-(void)disconnect;


@end
