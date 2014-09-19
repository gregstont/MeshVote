//
//  QuestionSet.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "QuestionSet.h"

@interface QuestionSet()

@property (nonatomic, strong) NSMutableArray *questions; //array of class Question
//@property (nonatomic) int numberOfQuestions;

@end

@implementation QuestionSet

-(instancetype)init {
    self = [super init];
    if(self) {
        _questions = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addQuestion:(Question*)question {
    NSLog(@"adding question");
    [_questions addObject:question];
    //++_numberOfQuestions;
    
}

-(void)removeQuestionAtIndex:(int)index {
    
    [_questions removeObjectAtIndex:index];
    //--_numberOfQuestions;
}


-(int)getQuestionCount {
    return (int)[_questions count];
}

-(NSString*)getQuestionTextAtIndex:(int)index {
    
    Question *temp = [_questions objectAtIndex:index];
    //temp.answerText
    
    return temp.questionText;
}

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex {
    
    return nil;
    
}




@end
