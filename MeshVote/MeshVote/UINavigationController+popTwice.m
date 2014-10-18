//
//  UINavigationController+popTwice.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/18/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "UINavigationController+popTwice.h"


@implementation UINavigationController (popTwice)

- (void) popTwoViewControllersAnimated:(BOOL)animated{
    [self popViewControllerAnimated:NO];
    [self popViewControllerAnimated:animated];
}

@end
