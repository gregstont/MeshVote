//
//  Results.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/7/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Message.h"

@interface Results : Message <NSCoding>

@property (nonatomic, strong) NSArray* votes;

@end
