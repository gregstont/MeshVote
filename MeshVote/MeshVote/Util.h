//
//  Util.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

// returns a string with a random 6-digit number at end
+(NSString*)getUniqueName:(NSString*)name;

// translates name into service-type
// Must be 1–15 characters long
// Can contain only ASCII lowercase letters, numbers, and hyphens. hyphens must be single and interior
+(NSString*)getServiceTypeFromName:(NSString*)input;

// saves poll data to disk
+(void)savePollDataToPhone:(NSMutableArray*)pollSet;

@end
