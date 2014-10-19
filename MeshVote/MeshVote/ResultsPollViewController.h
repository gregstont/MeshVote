//
//  ResultsPollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/6/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RunningAnswerTableViewCell.h"
#import "UINavigationController+popTwice.h"
#import "BackgroundLayer.h"

#import "QuestionSet.h"
#import "BigMCSession.h"
#import "Colors.h"
#import "Results.h"

@interface ResultsPollViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *resultsTable;


@property (nonatomic, strong) BigMCSession* bigSession;

@property (nonatomic, strong) QuestionSet *questionSet;


- (IBAction)resultsDoneButton:(id)sender;

@end
