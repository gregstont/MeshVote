//
//  ResultsPollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/6/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"

@interface ResultsPollViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *resultsTable;

@property (nonatomic, strong) QuestionSet *questionSet;
- (IBAction)resultsDoneButton:(id)sender;

@end
