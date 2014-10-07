//
//  Results.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/7/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Results.h"

@implementation Results

//
// NSCoding
//

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        [super setMessageType:[decoder decodeIntForKey:@"messageType"]];
        _votes = [decoder decodeObjectForKey:@"votes"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    //NSLog(@"ENCODE:%d", [super messageType]);
    [encoder encodeInt:[super messageType] forKey:@"messageType"];
    [encoder encodeObject:_votes forKey:@"votes"];
    
}

@end
