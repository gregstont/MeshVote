//
//  RunningAnswerTableViewCell.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunningAnswerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *answerLetterLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *answerProgress;
@property (weak, nonatomic) IBOutlet UILabel *answerPercentLabel;

@end
