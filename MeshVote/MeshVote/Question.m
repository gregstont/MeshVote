//
//  Question.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Question.h"

@interface Question()

//@property (nonatomic, strong) NSMutableArray *answerText;

@end

@implementation Question

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _correctAnswer = -1;
        _timeLimit = -1;
        //_questionNumber = -1;
        
        _answerText = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addAnswer:(NSString*)text {
    [_answerText addObject:text];
}

-(void)removeAnswer:(int)index {
    [_answerText removeObjectAtIndex:index];
}

-(int)getAnswerCount {
    return (int)[_answerText count];
}

@end
