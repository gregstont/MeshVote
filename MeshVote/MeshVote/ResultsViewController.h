//
//  ResultsViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/30/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RunningAnswerTableViewCell.h"
#import "UINavigationController+popTwice.h"

#import "Colors.h"
#import "Results.h"
#import "BackgroundLayer.h"
#import "QuestionSet.h"
#import "BigMCSession.h"

@interface ResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *meanLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *medianLabel;

@property (weak, nonatomic) IBOutlet UITableView *resultsTable;

@property (nonatomic, strong) QuestionSet *questionSet;
@property (nonatomic, strong) BigMCSession* bigSession;

@property (nonatomic, strong) NSMutableDictionary *voteHistory;

// for results when receiving stats from host
@property (strong, nonatomic) NSArray* stats;

@property (nonatomic) BOOL isQuiz;


- (IBAction)resultsDoneButton:(id)sender;

@end
