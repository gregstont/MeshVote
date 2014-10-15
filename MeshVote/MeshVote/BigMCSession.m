//
//  BigMCSession.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/14/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "BigMCSession.h"

#define MAX_PEERS_PER_SESSION kMCSessionMaximumNumberOfPeers
//#define MAX_PEERS_PER_SESSION 1

@interface BigMCSession ()


@property (nonatomic, strong) MCPeerID* host;
@property (nonatomic, strong) NSMutableDictionary* openConnectionCount; //open connection count for each session (ie connected peers + open invitations)

@end

@implementation BigMCSession

-(id)initWithPeer:(MCPeerID*)peerID {
    self = [super init];
    if(self) {
        _peerCount = 0;
        _host = peerID;

        
        //_sessionList = [[NSMutableArray alloc] init];
        MCSession* first = [[MCSession alloc] initWithPeer:_host securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        NSLog(@"initial session capacity:%d",(int)[[first connectedPeers] count]);
        first.delegate = self;
        
        _openConnectionCount = [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:0]] forKeys:@[[NSNumber numberWithUnsignedLong:first.hash]]]; //add session with no open connections
        
        _sessionList = [[NSMutableArray alloc] initWithObjects:first, nil];
        //[_sessionList addObject:first];
    }
    return self;
}


-(MCSession*)getAvailableSession {
    
    //MCSession* ggg = [_sessionList objectAtIndex:0];
    //ggg.
    //[_openConnectionCount setObject:[NSNumber numberWithInt:(1)] forKey:ggg];
    //check for slot in existing session
    for (MCSession *session in _sessionList) {
        if([[_openConnectionCount objectForKey:[NSNumber numberWithUnsignedLong:session.hash]] intValue] < MAX_PEERS_PER_SESSION) {
            NSLog(@"Found empty slot in session:%d, hash:%lu",(int)[[session connectedPeers] count], (unsigned long)session.hash);
            int oldValue = [[_openConnectionCount objectForKey:[NSNumber numberWithUnsignedLong:session.hash]] intValue];
            [_openConnectionCount setObject:[NSNumber numberWithInt:(oldValue + 1)] forKey:[NSNumber numberWithUnsignedLong:session.hash]];
            return session;
        }
    }
    
    //create new session
    MCSession *newSession = [[MCSession alloc] initWithPeer:_host securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    newSession.delegate = self;
    [_sessionList addObject:newSession];
    [_openConnectionCount setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithUnsignedLong:newSession.hash]];
    
    NSLog(@"Number of sessions:%lu", (unsigned long)[_sessionList count]);
    return newSession;
}


-(void)disconnect {
    NSLog(@"disconnect session begin");

    for(MCSession* cur in _sessionList) {
        NSLog(@"disconnect session");
        [cur disconnect];
    }
    
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
        
        //update the open connection counts
        int oldValue = [[_openConnectionCount objectForKey:[NSNumber numberWithUnsignedLong:session.hash]] intValue];
        if(oldValue > 0)
            --oldValue;
        [_openConnectionCount setObject:[NSNumber numberWithInt:oldValue] forKey:[NSNumber numberWithUnsignedLong:session.hash]];
    }
    [_delegate session:session peer:peerID didChangeState:state];
    NSLog(@"Session hash:%lu", (unsigned long)session.hash);
    
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
