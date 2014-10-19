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
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:1.0], //orange
                         [UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:1.0], //blue
                         [UIColor colorWithRed:1 green:59.0/255 blue:48.0/255 alpha:1.0] ]; //red
        
        alphaColors = @[ [UIColor colorWithRed:0.258 green:0.756 blue:0.631 alpha:0.3], //green
                         [UIColor colorWithRed:0 green:0.592 blue:0.929 alpha:0.3], //blue
                         [UIColor colorWithRed:0.905 green:0.713 blue:0.231 alpha:0.3], //yellow
                         [UIColor colorWithRed:1 green:0.278 blue:0.309 alpha:0.3], //red
                         [UIColor colorWithRed:88.0/255 green:86.0/255 blue:214.0/255 alpha:0.3], //purple
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:0.3], //orange
                         [UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:0.3], //blue
                         [UIColor colorWithRed:1 green:59.0/255 blue:48.0/255 alpha:0.3] ]; //red
        
        
        alphaColors2 =@[ [UIColor colorWithRed:0.258 green:0.756 blue:0.631 alpha:0.5], //green
                         [UIColor colorWithRed:0 green:0.592 blue:0.929 alpha:0.5], //blue
                         [UIColor colorWithRed:0.905 green:0.713 blue:0.231 alpha:0.5], //yellow
                         [UIColor colorWithRed:1 green:0.278 blue:0.309 alpha:0.5], //red
                         [UIColor colorWithRed:88.0/255 green:86.0/255 blue:214.0/255 alpha:0.5], //purple
                         [UIColor colorWithRed:1 green:149.0/255 blue:0 alpha:0.5], //orange
                         [UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:0.5], //blue
                         [UIColor colorWithRed:1 green:59.0/255 blue:48.0/255 alpha:0.5] ]; //red
        
        letters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    }
    return self;
}

- (UIColor*)getColorAtIndex:(long)index {
    return [colors objectAtIndex:index % 8];
    
}

- (UIColor*)getAlphaColorAtIndex:(long)index {
    return [alphaColors objectAtIndex:index % 8];
    
}
- (UIColor*)getAlphaColor2AtIndex:(long)index {
    return [alphaColors2 objectAtIndex:index % 8];
    
}
- (NSString*)getLetterAtIndex:(long)index {
    return [letters objectAtIndex:index % 26];
    
}

+(UIColor*)getFadedColorFromPercent:(double)percent withAlpha:(double)alpha {
    double red, green;
    if(percent < 0.5) {
        red = 1.0 - (percent / 4);
        green = percent * 2;
    }
    else {
        red = (1 - percent) * 2;
        green = 1.0 - ((1 - percent) / 4);
    }
    
    return [UIColor colorWithRed:red green:green blue:0.0 alpha:alpha];
}

@end
