//
//  RunningPollViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"


@interface RunningPollViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) QuestionSet* questionSet;

- (IBAction)rewindPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)forwardPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *answerTable;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLetterLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *answerProgress;

@end
