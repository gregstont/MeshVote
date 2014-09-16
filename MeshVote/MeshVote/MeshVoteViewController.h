//
//  MeshVoteViewController.h
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeshVoteViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
- (IBAction)joinSession:(id)sender;
- (IBAction)createSession:(id)sender;
- (IBAction)showAbout:(id)sender;

@end
