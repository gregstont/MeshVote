//
//  Question.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface Question : Message <NSCoding>

//@property (nonatomic, assign) int questionNumber;
@property (nonatomic, strong) NSString *questionText;
@property (nonatomic, strong) NSMutableArray *answerText;
@property (atomic, strong) NSMutableArray *voteCounts;
@property (nonatomic, assign) int voteCount;
@property (nonatomic, assign) int correctAnswer;
@property (nonatomic, assign) int timeLimit;
@property (nonatomic, assign) int givenAnswer; //used on client side only for post-results

-(void)addAnswer:(NSString*)text;

-(void)removeAnswer:(int)index;

-(int)getAnswerCount;

@end
