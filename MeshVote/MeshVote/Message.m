//
//  Message.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Message.h"

@implementation Message

//
// NSCoding
//

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _messageType = [decoder decodeObjectForKey:@"messageType"];
        _questionNumber = [decoder decodeIntForKey:@"questionNumber"];
        _answerNumber = [decoder decodeIntForKey:@"answerNumber"];
        _actionType = [decoder decodeIntForKey:@"actionType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    //NSLog(@"encode:%@", [super messageType]);
    [encoder encodeObject:_messageType forKey:@"messageType"];
    [encoder encodeInt:_questionNumber forKey:@"questionNumber"];
    [encoder encodeInt:_answerNumber forKey:@"answerNumber"];
    [encoder encodeInt:_actionType forKey:@"actionType"];
    
}

@end
