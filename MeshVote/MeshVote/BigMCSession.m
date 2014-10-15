//
//  BigMCSession.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/14/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "BigMCSession.h"

#define MAX_PEERS_PER_SESSION kMCSessionMaximumNumberOfPeers

@interface BigMCSession ()


@property (nonatomic, strong) MCPeerID* host;

@end

@implementation BigMCSession

-(id)initWithPeer:(MCPeerID*)peerID {
    self = [super init];
    if(self) {
        _peerCount = 0;
        _host = peerID;
        
        _sessionList = [[NSMutableArray alloc] init];
        MCSession* first = [[MCSession alloc] initWithPeer:_host securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        first.delegate = self;
        [_sessionList addObject:first];
    }
    return self;
}


-(MCSession*)getAvailableSession {
    
    //check for slot in existing session
    for (MCSession *session in _sessionList) {
        if ([session.connectedPeers count] < MAX_PEERS_PER_SESSION)
            return session;
    }
    
    //Or create a new session
    MCSession *newSession = [[MCSession alloc] initWithPeer:_host securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    [_sessionList addObject:newSession];
    
    return newSession;
}

-(void)disconnect {
    
}

//
//  MCSessionDelegate
//

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if(state == MCSessionStateConnected) {
        ++_peerCount;
    }
    else if(state == MCSessionStateNotConnected) {
        --_peerCount;
    }
    [_delegate session:session peer:peerID didChangeState:state];
    
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    [_delegate session:session didReceiveData:data fromPeer:peerID];
    
}


 // Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}
 
 // Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}
 
 // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
 - (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
 }
 



@end
