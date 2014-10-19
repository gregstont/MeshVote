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
        _timeLimit = 60;
        _givenAnswer = -1;
        //_questionNumber = -1;
        
        _answerText = [[NSMutableArray alloc] init];
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
        [super setQuestionNumber:[decoder decodeIntForKey:@"questionNumber"]];
        _questionText = [decoder decodeObjectForKey:@"questionText"];
        _correctAnswer = [decoder decodeIntForKey:@"correctAnswer"];
        _timeLimit = [decoder decodeIntForKey:@"timeLimit"];
        _answerText = [decoder decodeObjectForKey:@"answerText"];
        //_questionNum = [decoder decodeIntForKey:@"questionNum"];
        _voteCount = [decoder decodeIntForKey:@"voteCount"];
        _givenAnswer = [decoder decodeIntForKey:@"givenAnswer"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    //NSLog(@"ENCODE:%d", [super messageType]);
    [encoder encodeInt:[super messageType] forKey:@"messageType"];
    [encoder encodeInt:[super questionNumber] forKey:@"questionNumber"];
    [encoder encodeObject:_questionText forKey:@"questionText"];
    [encoder encodeObject:_answerText forKey:@"answerText"];
    [encoder encodeInt:_correctAnswer forKey:@"correctAnswer"];
    [encoder encodeInt:_timeLimit forKey:@"timeLimit"];
    //[encoder encodeInt:_questionNum forKey:@"questionNum"];
    [encoder encodeInt:_voteCount forKey:@"voteCount"];
    [encoder encodeInt:_givenAnswer forKey:@"givenAnswer"];
    
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
