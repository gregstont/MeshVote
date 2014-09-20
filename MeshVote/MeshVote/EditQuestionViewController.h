//
//  EditQuestionViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditQuestionViewController;
@protocol EditQuestionViewControllerDelegate <NSObject>

-(NSString*)getQuestionTextAtIndex:(int)index;

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex;

-(int)getAnswerCountAtIndex:(int)index;

-(int)getSelectedQuestion;

@end


@interface EditQuestionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *questionTextLabel;
@property (strong, nonatomic) id <EditQuestionViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;


@end
