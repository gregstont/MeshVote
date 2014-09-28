//
//  Message.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACTION_REWIND   0
#define ACTION_PLAY     1
#define ACTION_PAUSE    2
#define ACTION_FORWARD  3
#define ACTION_DONE     4

@interface Message : NSObject <NSCoding>

@property (nonatomic, strong) NSString* messageType; //TODO: change to int
@property (nonatomic) int questionNumber;
@property (nonatomic) int answerNumber;
@property (nonatomic) int actionType; //can I use a union here?


@end
