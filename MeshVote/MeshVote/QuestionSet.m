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

//
// NSCoding
//

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        [super setMessageType:[decoder decodeIntForKey:@"messageType"]];
        _questions = [decoder decodeObjectForKey:@"questions"];
        _name = [decoder decodeObjectForKey:@"name"];
        _isQuiz = [decoder decodeBoolForKey:@"isQuiz"];
        _showResults = [decoder decodeBoolForKey:@"showResults"];
        _shareScores = [decoder decodeBoolForKey:@"shareScores"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    //NSLog(@"encode:%@", [super messageType]);
    [encoder encodeInt:[super messageType] forKey:@"messageType"];
    [encoder encodeObject:_questions forKey:@"questions"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeBool:_isQuiz forKey:@"isQuiz"];
    [encoder encodeBool:_showResults forKey:@"showResults"];
    [encoder encodeBool:_shareScores forKey:@"shareScores"];
}

-(void)addQuestion:(Question*)question {
    NSLog(@"adding question");
    [_questions addObject:question];
    NSLog(@"new question count:%d", self.getQuestionCount);
    //++_numberOfQuestions;
    
}

-(Question*)getQuestionAtIndex:(int)index {
    NSLog(@"getQuestionAtIndex");
    return [_questions objectAtIndex:index];
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
    Question *temp = [_questions objectAtIndex:index];
    return [temp.answerText objectAtIndex:ansIndex];
    
}

-(int)getAnswerCountAtIndex:(int)index {
    Question *temp = [_questions objectAtIndex:index];
    
    return [temp getAnswerCount];
}


@end
