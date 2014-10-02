//
//  SpacedUITableViewCell.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpacedUITableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *answerChoiceLetter;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *answerActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *answerCheckImage;
@property (weak, nonatomic) IBOutlet UIImageView *checkOutline;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)checkClicked:(id)sender;

@end
