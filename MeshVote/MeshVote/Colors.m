//
//  Colors.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/1/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "Colors.h"


@implementation Colors

NSArray* colors;
NSArray* alphaColors;
NSArray* alphaColors2;
NSArray* letters;

-(id)init {
    self = [super init];
    if(self) {
        colors =      @[ [UIColor colorWithRed:0.258 green:0.756 blue:0.631 alpha:1.0], //green
                         [UIColor colorWithRed:0 green:0.592 blue:0.929 alpha:1.0], //blue
                         [UIColor colorWithRed:0.905 green:0.713 blue:0.231 alpha:1.0], //yellow
                         [UIColor colorWithRed:1 green:0.278 blue:0.309 alpha:1.0], //red
                         [UIColor colorWithRed:88.0/255 green:86.0/255 blue:214.0/255 alpha:1.0], //purple
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:1.0] ]; //orange
        
        alphaColors = @[ [UIColor colorWithRed:0.258 green:0.756 blue:0.631 alpha:0.3], //green
                         [UIColor colorWithRed:0 green:0.592 blue:0.929 alpha:0.3], //blue
                         [UIColor colorWithRed:0.905 green:0.713 blue:0.231 alpha:0.3], //yellow
                         [UIColor colorWithRed:1 green:0.278 blue:0.309 alpha:0.3], //red
                         [UIColor colorWithRed:88.0/255 green:86.0/255 blue:214.0/255 alpha:0.3], //purple
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:0.3] ]; //orange
        alphaColors2 =@[ [UIColor colorWithRed:0.258 green:0.756 blue:0.631 alpha:0.1], //green
                         [UIColor colorWithRed:0 green:0.592 blue:0.929 alpha:0.1], //blue
                         [UIColor colorWithRed:0.905 green:0.713 blue:0.231 alpha:0.1], //yellow
                         [UIColor colorWithRed:1 green:0.278 blue:0.309 alpha:0.1], //red
                         [UIColor colorWithRed:88.0/255 green:86.0/255 blue:214.0/255 alpha:0.1], //purple
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:0.1] ]; //orange
        letters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
    }
    return self;
}

- (UIColor*)getColorAtIndex:(long)index {
    return [colors objectAtIndex:index];
    
}

- (UIColor*)getAlphaColorAtIndex:(long)index {
    return [alphaColors objectAtIndex:index];
    
}
- (UIColor*)getAlphaColor2AtIndex:(long)index {
    return [alphaColors2 objectAtIndex:index];
    
}
- (NSString*)getLetterAtIndex:(long)index {
    return [letters objectAtIndex:index];
    
}

@end
