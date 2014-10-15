//
//  Message.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BigMCSession.h"

//messageType
#define MSG_QUESTION_SET     1
#define MSG_QUESTION_SET_ACK 2
#define MSG_ANSWER           3
#define MSG_ANSWER_ACK       4
#define MSG_ACTION           5
#define MSG_ACTION_ACK       6
#define MSG_POLL_RESULTS     7

//actionType
#define AT_REWIND      10
#define AT_PLAY        11
#define AT_PAUSE       12
#define AT_FORWARD     13
#define AT_DONE        14

@interface Message : NSObject <NSCoding>

@property (nonatomic) int messageType; //TODO: change to int
@property (nonatomic) int questionNumber;
@property (nonatomic) int answerNumber;
@property (nonatomic) int actionType; //can I use a union here?

+ (BOOL)broadcastMessage:(Message*)message inSession:(BigMCSession*)bigSession;
+ (BOOL)sendMessage:(Message*)message toPeers:(NSArray*)peers inSession:(MCSession*)session;
+ (BOOL)sendMessageType:(int)messageType toPeers:(NSArray*)peers inSession:(MCSession*)session;
+ (BOOL)sendMessageType:(int)messageType withActionType:(int)actionType toPeers:(NSArray*)peers inSession:(MCSession*)session;


@end
