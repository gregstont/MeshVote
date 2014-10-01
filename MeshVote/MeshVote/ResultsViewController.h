//
//  ResultsViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/30/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"

@interface ResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) QuestionSet *questionSet;
@property (weak, nonatomic) IBOutlet UITableView *resultsTable;
- (IBAction)resultsDoneButton:(id)sender;

@end
