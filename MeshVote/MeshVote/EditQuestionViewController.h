//
//  EditQuestionViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"

@class EditQuestionViewController;
@protocol EditQuestionViewControllerDelegate <NSObject>

-(Question*)getQuestionAtIndex:(int)index;

-(NSString*)getQuestionTextAtIndex:(int)index;

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex;

-(int)getAnswerCountAtIndex:(int)index;

-(int)getSelectedQuestion;

@end


@interface EditQuestionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *questionTextLabel;
@property (strong, nonatomic) id <EditQuestionViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)doneButtonPressed:(id)sender;


@end
