//
//  Message.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Message.h"


/*
 
 #define MT_QUESTION     1
 #define MT_QUESTION_ACK 2
 #define MT_ANSWER       3
 #define MT_ANSWER_ACK   4
 #define MT_ACTION       5
 #define MT_ACTION_ACK   6
 
 #define AT_REWIND       7
 #define AT_PLAY         8
 #define AT_PAUSE        9
 #define AT_FORWARD     10
 #define AT_DONE        11
 
 */

@implementation Message

+ (BOOL)sendMessageType:(int)messageType toPeers:(NSArray*)peers inSession:(MCSession*)session {
    return [self sendMessageType:messageType withActionType:-1 toPeers:peers inSession:session];
}
+ (BOOL)sendMessageType:(int)messageType withActionType:(int)actionType toPeers:(NSArray*)peers inSession:(MCSession*)session {
    Message *message = [[Message alloc] init];
    message.messageType = messageType;
    message.actionType = actionType;
    
    return [self sendMessage:message toPeers:peers inSession:session];
}
+ (BOOL)sendMessage:(Message*)message toPeers:(NSArray*)peers inSession:(MCSession*)session {
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSError *error;
    
    [session sendData:messageData toPeers:peers withMode:MCSessionSendDataReliable error:&error];
    if(error) {
        NSLog(@"Error sending data");
        return NO;
    }
    return YES;
}

//
// NSCoding
//

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _messageType = [decoder decodeIntForKey:@"messageType"];
        _questionNumber = [decoder decodeIntForKey:@"questionNumber"];
        _answerNumber = [decoder decodeIntForKey:@"answerNumber"];
        _actionType = [decoder decodeIntForKey:@"actionType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    //NSLog(@"encode:%@", [super messageType]);
    [encoder encodeInt:_messageType forKey:@"messageType"];
    [encoder encodeInt:_questionNumber forKey:@"questionNumber"];
    [encoder encodeInt:_answerNumber forKey:@"answerNumber"];
    [encoder encodeInt:_actionType forKey:@"actionType"];
    
}

@end
