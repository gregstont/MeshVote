//
//  Util.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Util.h"

@implementation Util

// returns a string with a random 6-digit number at end
+(NSString*)getUniqueName:(NSString*)name {
    return [NSString stringWithFormat:@"%@%d",name,((arc4random() % 999999) + 100000)];
}

// translates name into service-type
// Must be 1–15 characters long
// Can contain only ASCII lowercase letters, numbers, and hyphens. hyphens must be single and interior
+(NSString*)getServiceTypeFromName:(NSString*)input {
    const char* c_string = [[input lowercaseString] UTF8String];
    char new_string[16];
    const char* runner = c_string;
    int newStringIndex = 0;
    while(*runner != '\0' && newStringIndex < 16) {
        
        if((*runner >= 'a' && *runner <= 'z') || (*runner >= 0 && *runner <= 9)) {
            new_string[newStringIndex] = *runner;
            ++newStringIndex;
        }
        ++runner;
    }
    new_string[newStringIndex] = '\0';
    return [NSString stringWithUTF8String:new_string];
}
@end
