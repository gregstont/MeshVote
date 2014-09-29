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
@property (nonatomic, strong) NSMutableArray *voteCounts;
@property (nonatomic, assign) int questionNum;
@property (nonatomic, assign) int correctAnswer;
@property (nonatomic, assign) int timeLimit;

-(void)addAnswer:(NSString*)text;

-(void)removeAnswer:(int)index;

-(int)getAnswerCount;

@end
