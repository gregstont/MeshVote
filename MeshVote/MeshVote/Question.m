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

//
// NSCoding
//

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _questionText = [decoder decodeObjectForKey:@"questionText"];
        _correctAnswer = [decoder decodeIntForKey:@"correctAnswer"];
        _timeLimit = [decoder decodeIntForKey:@"timeLimit"];
        _answerText = [decoder decodeObjectForKey:@"answerText"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_questionText forKey:@"questionText"];
    [encoder encodeObject:_answerText forKey:@"answerText"];
    [encoder encodeInt:_correctAnswer forKey:@"correctAnswer"];
    [encoder encodeInt:_timeLimit forKey:@"timeLimit"];
    
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
