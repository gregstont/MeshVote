//
//  MeshVoteViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundLayer.h"
#import "QuestionViewControllerTableViewController.h"
#import "JoinViewControllerTableViewController.h"
#import "PollListViewController.h"

@interface MeshVoteViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameInput;

- (IBAction)joinSession:(id)sender;
- (IBAction)createSession:(id)sender;
- (IBAction)showAbout:(id)sender;

@end
