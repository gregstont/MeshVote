//
//  QuestionSet.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

@interface QuestionSet : Message <NSCoding>

-(void)addQuestion:(Question*)question;

-(Question*)getQuestionAtIndex:(int)index;

-(void)removeQuestionAtIndex:(int)index; //Raises an NSRangeException if index is beyond the end of the array.

-(int)getQuestionCount;

-(NSString*)getQuestionTextAtIndex:(int)index;

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex;

-(int)getAnswerCountAtIndex:(int)index;



@property (nonatomic, strong) NSString* name;
@property (nonatomic) BOOL isQuiz; //otherwise poll
@property (nonatomic) BOOL showResults;
@property (nonatomic) BOOL shareScores;

@end
