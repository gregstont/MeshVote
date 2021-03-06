//
//  Colors.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/1/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Colors : NSObject

- (UIColor*)getColorAtIndex:(long)index;
- (UIColor*)getAlphaColorAtIndex:(long)index;
- (UIColor*)getAlphaColor2AtIndex:(long)index;
- (NSString*)getLetterAtIndex:(long)index;

+(UIColor*)getFadedColorFromPercent:(double)percent withAlpha:(double)alpha;

@end
