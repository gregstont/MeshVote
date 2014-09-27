//
//  EditQuestionViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "EditQuestionViewController.h"
#import "BackgroundLayer.h"
#import "SpacedUITableViewCell.h"

@interface EditQuestionViewController ()

@property (nonatomic, strong) Question* currentQuestion;
@property (nonatomic) BOOL isAddingNewAnswer;

@end

@implementation EditQuestionViewController

NSMutableArray *colors;
NSArray *letters;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"in editQuestion view Controller");
    [_doneButton setTitle:@""];
    [_doneButton setEnabled:NO];
    //[_doneButton setHidden:YES];
    
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    _delegate = [self.navigationController.viewControllers objectAtIndex:1];
    
    _questionTextLabel.clipsToBounds = YES;
    _questionTextLabel.layer.cornerRadius = 10.0f;
    
    if([_delegate getSelectedQuestion] == -1) { //create new question
        _currentQuestion = [[Question alloc] init];
        [_questionTextLabel setText:@"Question..."];
        //[_doneButton setHidden:NO];
        [_doneButton setTitle:@"Save"];
        [_doneButton setEnabled:YES];
        self.navigationItem.title = @"New question";
    }
    else { //edit existing question
        _currentQuestion = [_delegate getQuestionAtIndex:[_delegate getSelectedQuestion]];
        [_questionTextLabel setText:_currentQuestion.questionText];
        self.navigationItem.title = [NSString stringWithFormat:@"Question %d", [_delegate getSelectedQuestion] + 1];
    }
    
    // Do any additional setup after loading the view.
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    [_questionTextLabel setDelegate:self];
    
    
    colors = [[NSMutableArray alloc] init];
    [colors addObject:[[UIColor alloc] initWithRed:0.258 green:0.756 blue:0.631 alpha:1.0]]; //green
    [colors addObject:[[UIColor alloc] initWithRed:0 green:0.592 blue:0.929 alpha:1.0]]; //blue
    [colors addObject:[[UIColor alloc] initWithRed:0.905 green:0.713 blue:0.231 alpha:1.0]]; //yellow
    [colors addObject:[[UIColor alloc] initWithRed:1 green:0.278 blue:0.309 alpha:1.0]]; //red
    
    letters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];//[NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G" count:7];

    //NSLog(@"selectedQuestion:%d", temp);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//
//  UITableViewDataSource, UITableViewDelegate
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"checking number of rows");
    
    //NSIndexPath *temp = [tableView indexPathForSelectedRow];
    
    //NSLog(@" and:%d", [_delegate getAnswerCountAtIndex:0]);
    if([_delegate getSelectedQuestion] == -1) {
        return MAX(1, [_currentQuestion getAnswerCount] * 2 + 1);
    }
    else
        return [_currentQuestion getAnswerCount] * 2 - 1; //TODO: change this
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1)
        return 10;
    return 34;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_delegate getSelectedQuestion] == -1) { //add new question
        
    }
    
    if(indexPath.row % 2 == 1) { //blank spacing cell
        UITableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"eq_cellid2"];
        [blankCell setHidden:YES];
        [blankCell setUserInteractionEnabled:NO];
        if(blankCell == nil) {
            NSLog(@"Shouldnt be here!!!!!!!!!!!");
            blankCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"eq_cellid2"];
            [blankCell.contentView setAlpha:0];
            [blankCell setAlpha:0];
            [blankCell setHidden:YES];
            blankCell.clipsToBounds = YES;
            [blankCell setUserInteractionEnabled:NO];
        }
        return blankCell;
    }
    
    //NSLog(@"cellForRow");
    SpacedUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eq_cellid"]; //forIndexPath:indexPath];
    [cell setHidden:NO];
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"Shouldnt be here!!!!!!!!!!!");

        cell = [[SpacedUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eq_cellid"];

    }
    
    cell.answerChoiceLetter.layer.cornerRadius = 7.0f;
    
    cell.answerChoiceLetter.backgroundColor = [colors objectAtIndex:indexPath.row/2];
    [cell.answerChoiceLetter setText:[letters objectAtIndex:indexPath.row/2]];
    
    [cell setHighlighted:YES   animated:YES];

    cell.layer.cornerRadius = 10.0f;
    cell.clipsToBounds = YES;
    cell.textLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    cell.answerTextField.delegate = self;
    
    //cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Thin" size:38];
    
    //NSIndexPath *temp = [tableView indexPathForSelectedRow];
    if([_delegate getSelectedQuestion] == -1) { //add new question
        if([_currentQuestion getAnswerCount] > (int)indexPath.row/2) {
            cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:(int)indexPath.row/2];
        }
        else {
            cell.textLabel.text = @"";
            cell.answerTextField.text = @"add answer";
        }
        /*
        if([_currentQuestion getAnswerCount] == 0) { //no answers yet
            cell.textLabel.text = @"";
            cell.answerTextField.text = @"add answer";
        }
        else {
            cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:(int)indexPath.row/2];
        }
         */

    }
    else {
        [cell.answerTextField setEnabled:NO];
        cell.answerTextField.text = [_delegate getAnswerTextAtIndex:[_delegate getSelectedQuestion] andAnswerIndex:(int)indexPath.row/2];
        cell.textLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   

    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (IBAction)doneButtonPressed:(id)sender {
    if([_doneButton.title isEqualToString:@"Done"]) { //in edit text view
        [self.view endEditing:YES];
    }
    else { //save/add new question
        NSLog(@"submitted:%@", _currentQuestion.questionText);
        [self.delegate addQuestionToSet:_currentQuestion];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


//
//  TextViewDelegate, for question
//

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [_doneButton setTitle:@"Done"];
    if([_questionTextLabel.text isEqualToString:@"Question..."])
        [_questionTextLabel setText:@""];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //if([textView. isEqualToString:@)
    [_doneButton setTitle:@"Save"];
    [_currentQuestion setQuestionText:textView.text];
    //NSLog(@"submitted:%@", _currentQuestion.questionText);
}


//
//  TextFieldDelegate, for answers
//

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // Indicate we're done with the keyboard. Make it go away.
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_doneButton setTitle:@"Done"];
    if([textField.text isEqualToString:@"add answer"]) {
        [self setIsAddingNewAnswer:YES];
        textField.text = @"";
    }
    else {
        [self setIsAddingNewAnswer:NO];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    //if([textView. isEqualToString:@)
    [_doneButton setTitle:@"Save"];
    NSLog(@"answer count:%d", _currentQuestion.getAnswerCount);
    if(self.isAddingNewAnswer && ![textField.text isEqualToString:@"add answer"]) { //adding new answer
        [_currentQuestion addAnswer:textField.text];
    }
    else { //editing an existing answer
        
    }
    
    //[_currentQuestion setQuestionText:textView.text];
    NSLog(@"answer count:%d", _currentQuestion.getAnswerCount);
    NSLog(@"added answer:%@", textField.text);
    //[self.tableView reloadData];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
@end
