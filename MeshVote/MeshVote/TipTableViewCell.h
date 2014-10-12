//
//  TipTableViewCell.h
//  MeshVote
//
//  Created by Taylor Gregston on 10/11/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *createQuestionHintLabel;
@property (weak, nonatomic) IBOutlet UITextView *tipTextView;
@property (weak, nonatomic) IBOutlet UIImageView *createQuestionHintArrow;

@property (nonatomic) BOOL loaded;

@end
