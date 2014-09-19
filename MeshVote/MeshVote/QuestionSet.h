//
//  QuestionSet.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

@interface QuestionSet : NSObject

-(void)addQuestion:(Question*)question;

-(void)removeQuestionAtIndex:(int)index; //Raises an NSRangeException if index is beyond the end of the array.

-(int)getQuestionCount;

-(NSString*)getQuestionTextAtIndex:(int)index;

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex;

@end
