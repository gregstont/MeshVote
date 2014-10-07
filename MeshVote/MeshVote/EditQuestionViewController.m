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

@property (atomic) int currentAnswer;
@property (atomic) BOOL currentAnswerAcked;

@property (atomic) int timeRemaining;

@property (nonatomic, strong) Colors* colors;

@property (nonatomic, strong) NSNumberFormatter* numberFormatter;
@end

@implementation EditQuestionViewController


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
    
    //time input stuff
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    [self.numberFormatter setGroupingSize:2];
    [self.numberFormatter setGroupingSeparator:@":"];
    [self.numberFormatter setUsesGroupingSeparator:YES];
    [self.numberFormatter setMaximumFractionDigits:0];
    [self.numberFormatter setMinimumIntegerDigits:3];
    [self.numberFormatter setMaximumIntegerDigits:3];
    
    
    
    
    
    
    //_currentQuestionNumber = 0;
    _colors = [[Colors alloc] init];
    _currentAnswer = -1;
    _currentAnswerAcked = NO;
    
    NSLog(@"in editQuestion view Controller, mode:%d",_viewMode);
    [_doneButton setTitle:@""];
    [_doneButton setEnabled:NO];
    //[_doneButton setHidden:YES];
    
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    //_delegate = [self.navigationController.viewControllers objectAtIndex:2]; //TODO: change this! bug waiting to happen
    
    _questionTextLabel.clipsToBounds = YES;
    _questionTextLabel.layer.cornerRadius = 3.0f;
    
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION) { //create new question
        _currentQuestion = [[Question alloc] init];
        _currentQuestion.questionNumber = [_questionSet getQuestionCount] + 1;
        [_questionTextLabel setText:@"Question..."];
        //[_doneButton setHidden:NO];
        [_doneButton setTitle:@"Save"];
        [_doneButton setEnabled:YES];
        self.navigationItem.title = @"New question";
        self.timeTextField.delegate = self;
    }
    else if(_viewMode == VIEWMODE_EDIT_QUESTION) { //edit existing question
        //_currentQuestion = [_delegate getQuestionAtIndex:[_delegate getSelectedQuestion]];
        [_questionTextLabel setText:_currentQuestion.questionText];
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestion.questionNumber]];
        
        NSInteger time = _currentQuestion.timeLimit;
        //NSInteger hours = (time / 3600) % 3600;
        NSInteger minutes = (time / 60) % 60;
        NSInteger seconds = time % 60;
        
        self.timeTextField.delegate = self;
        self.timeTextField.text = [self.numberFormatter stringFromNumber:@([[NSString stringWithFormat:@"%02ld%02ld", minutes, seconds] doubleValue])];
        
        //self.navigationItem.title = [NSString stringWithFormat:@"Question %d", [_delegate getSelectedQuestion] + 1];
    }
    else { // VIEWMODE_ASK_QUESTION
        
        
        //send action-ack
        [Message sendMessageType:MSG_ACTION withActionType:AT_PLAY toPeers:@[_host] inSession:_session];
        
        [_timeTextField setBackgroundColor:[UIColor clearColor]];
        //NSLog(@"here");
        //_questionSet = (QuestionSet*)_questionSet;
        _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
        //NSLog(@"not here");
        
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1]];
        //self.navigationItem.title = [NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1];
        _questionTextLabel.text = _currentQuestion.questionText; //[NSString stringWithFormat:@"%d:%02d",time / 60, time % 60];
        //_currentQuestion.t
        _timeRemaining = _currentQuestion.timeLimit;
        [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
        //[_doneButton setTitle:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
        
        //start timer TODO: move this to moveToNextQuestion
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            while(_timeRemaining > 0) {
                [NSThread sleepForTimeInterval:1.0f];
                --_timeRemaining;
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    // GUI thread
                    //NSLog(@"GUI thread 1");
                    // update label 1 text
                    [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
                    //[_doneButton setTitle:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
                });
                //NSLog(@"times up");
            }
            //NSLog(@"times up, questionNum:%d",_currentQuestionNumber);
        });
    }
    
    // Do any additional setup after loading the view.
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setScrollsToTop:NO];
    
    [_questionTextLabel setDelegate:self];

    _session.delegate = self;
    
    //[_timeTextField setDelegate:self];
    
    //NSLog(@"selectedQuestion:%d", temp);
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:(190/255.0)  green:(190/255.0)  blue:(190/255.0)  alpha:1.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"editWillDisappear");
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.toolbar.barTintColor = nil;
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

    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION || _viewMode == VIEWMODE_EDIT_QUESTION) {
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
    
    if(indexPath.row % 2 == 1) { //blank spacing cell
        UITableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"eq_cellid2"];
        [blankCell setHidden:YES];
        [blankCell setUserInteractionEnabled:NO];
        if(blankCell == nil) {
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

        cell = [[SpacedUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eq_cellid"];

    }
    
    //cell.answerChoiceLetter.layer.cornerRadius = 2.0f;
    
    cell.answerChoiceLetter.backgroundColor = [_colors getAlphaColor2AtIndex:indexPath.row/2];
    [cell.answerChoiceLetter setText:[_colors getLetterAtIndex:indexPath.row/2]];
    [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.08]];
    //[cell setAlpha:0.7]
    
    [cell setHighlighted:YES   animated:YES];

    cell.layer.cornerRadius = 2.0f;
    cell.clipsToBounds = YES;
    cell.textLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    cell.answerTextField.delegate = self;
    
    //checkbutton for submissions (VIEWMODE_ASK_QUESTION)
    if(_currentAnswer == indexPath.row/2) {
        if(_currentAnswerAcked) {
            cell.answerActivityIndicator.hidden = YES;
            //cell.answerCheckImage.hidden = NO;
            cell.checkButton.hidden = NO;
        }
        else {
            cell.answerActivityIndicator.hidden = NO;
            [cell.answerActivityIndicator startAnimating];
        }
    }
    else {
        cell.checkButton.hidden = YES;
        //cell.answerCheckImage.hidden = YES;
        cell.answerActivityIndicator.hidden = YES;
    }
    
    //if correct answer, show check button
    if(_viewMode == VIEWMODE_EDIT_QUESTION && _currentQuestion.correctAnswer == indexPath.row/2) {
        cell.checkButton.hidden = NO;
    }
    //cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Thin" size:38];
    
    //show check button and outline
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION || _viewMode == VIEWMODE_EDIT_QUESTION) { //add new question
        if([_currentQuestion getAnswerCount] > (int)indexPath.row/2) {
            cell.answerTextField.alpha = 1.0;
            cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:(int)indexPath.row/2];
            //NSLog(@"isQuiz:%d",_questionSet.isQuiz);
            if(_questionSet.isQuiz) {
                cell.checkOutline.hidden = NO;
                cell.checkOutline.enabled = YES;
                
                cell.checkButton.hidden = YES;
                cell.checkButton.enabled = NO;
            }
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //cell.contentView.userInteractionEnabled = NO;
            //[cell setUserInteractionEnabled:NO];
            [cell setEditing:NO];
            if(indexPath.row/2 == _currentQuestion.correctAnswer) {
                cell.checkButton.hidden = NO;
                cell.checkButton.enabled = YES;
                cell.checkOutline.hidden = YES;
            }
            //else
             //   [cell.checkButton setAlpha:0.0005];
        }
        else { //"add answer" button
            cell.textLabel.text = @"";
            cell.answerTextField.text = @"add answer";
            cell.answerTextField.alpha = 0.25;
        }

    }
    else {
        [cell.answerTextField setEnabled:NO];
        cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:indexPath.row/2];//[_delegate getAnswerTextAtIndex:[_delegate getSelectedQuestion] andAnswerIndex:(int)indexPath.row/2];
        cell.textLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_viewMode == VIEWMODE_ASK_QUESTION) { //submit answer
        NSLog(@"clicked answer to submit");
        
        Message *answerMessage = [[Message alloc] init];
        //answerMessage.messageType = @"answer";
        answerMessage.messageType = MSG_ANSWER;
        answerMessage.questionNumber = _currentQuestionNumber;
        answerMessage.answerNumber = (int)indexPath.row/2;
        
        [Message sendMessage:answerMessage toPeers:@[_host] inSession:_session];
        
        _currentAnswer = answerMessage.answerNumber;
        _currentAnswerAcked = NO;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_tableView reloadData];
        });
        
    }
   

    
    
}


-(void)moveToNextQuestion {
    
    //++_currentQuestionNumber;
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    _timeRemaining = _currentQuestion.timeLimit;
    _currentAnswer = -1;
    _currentAnswerAcked = NO;
    //[_questionTextLabel setText:_currentQuestion.questionText];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1]];
        //self.navigationItem.title = [NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1];
        _questionTextLabel.text = _currentQuestion.questionText;
        [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
        //[_doneButton setTitle:[NSString stringWithFormat:@"%d:%02d", _currentQuestion.timeLimit / 60, _currentQuestion.timeLimit % 60]];
        [self.tableView reloadData];
    });
    
    //start the timer
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // background thread
        //NSLog(@"Background thread 1: waiting 5 seconds");
        // wait 5 seconds
        while(_timeRemaining > 0) {
            [NSThread sleepForTimeInterval:1.0f];
            --_timeRemaining;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
                //[_doneButton setTitle:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
            });
        }
        //NSLog(@"times up, questionNum:%d",_currentQuestionNumber);
    });
    
    
    //when we are done here, send the action-ack TODO funccall here
    
    NSLog(@"sending action ack to host");
    
    [Message sendMessageType:MSG_ACTION_ACK withActionType:AT_PLAY toPeers:@[_host] inSession:_session];
    
    
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
        [_questionSet addQuestion:_currentQuestion];
        //[self.delegate addQuestionToSet:_currentQuestion];
        [self.navigationController popViewControllerAnimated:YES];
        
        //TODO: need to resend questionset to connected peers!
        
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
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION) {
        [_doneButton setTitle:@"Save"];
    }
    else {
        [_doneButton setTitle:nil];
    }
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString {
    //NSLog(@"tag");
    if(textField.tag == 2) {
        NSLog(@"tag2");
        NSString *originalNumber = textField.text;
        if([replacementString isEqualToString:@""]) {
            originalNumber = [originalNumber stringByReplacingCharactersInRange:range withString:@""];
        } else {
            originalNumber = [originalNumber stringByAppendingString:replacementString];
        }
        originalNumber = [originalNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *newString = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[originalNumber doubleValue]]];
        self.timeTextField.text = newString;

        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //if(_viewMode == VIEWMODE_ADD_NEW_QUESTION || textField.tag == 2) {
        [_doneButton setTitle:@"Done"];
        [_doneButton setEnabled:YES];
    //}
    //SpacedUITableViewCell *clickedC = (SpacedUITableViewCell*)[[]]
    if(textField.tag != 2) { //if not time field
        SpacedUITableViewCell *clickedCell = (SpacedUITableViewCell *)[[[textField superview] superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        NSLog(@"clicked:%d", (int)clickedButtonPath.row);
        
        //move the UI up so the keyboard doesnt hide it TODO: maybe need to max out around 5 or 6?
        [UIView beginAnimations:@"registerScroll" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
        self.view.transform = CGAffineTransformMakeTranslation(0, -34.0 * (clickedButtonPath.row/2));
        [UIView commitAnimations];
        
        if([textField.text isEqualToString:@"add answer"]) {
            //[self setViewMode:VIEWMODE_ADD_NEW_QUESTION];
            textField.text = @"";
            textField.alpha = 1.0;

        }

    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField { //TODO: rewrite this 
    //if([textView. isEqualToString:@)
    
    
    if(textField.tag == 2) { //time field text
        NSLog(@"text:%@", [textField.text stringByReplacingOccurrencesOfString:@":" withString:@""]);
        
        int time = [[textField.text stringByReplacingOccurrencesOfString:@":" withString:@""] intValue];
        
        int min = (time / 100);
        int seconds = time % 100;
        if(seconds > 59) {
            ++min;
            seconds -= 60;
        }
        
        
        _currentQuestion.timeLimit = min * 60 + seconds;
        
        self.timeTextField.text = [self.numberFormatter stringFromNumber:@([[NSString stringWithFormat:@"%02d%02d", min, seconds] doubleValue])];
    }
    else { //if not the time text field, its an answer field
    
        //reset the view's position
        [UIView beginAnimations:@"registerScroll" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
        //self.
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView commitAnimations];
        
        
        SpacedUITableViewCell *clickedCell = (SpacedUITableViewCell *)[[[textField superview] superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        
        if(clickedButtonPath.row/2 == [_currentQuestion getAnswerCount]) {
            NSLog(@"adding a new answer");
            [_currentQuestion addAnswer:textField.text];

        }
        else {
            NSLog(@"editing an existing answer");
            [_currentQuestion.answerText setObject:textField.text atIndexedSubscript:clickedButtonPath.row/2];
        }
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
    
    //[_doneButton setTitle:@"Save"];
    
    if(_viewMode == VIEWMODE_EDIT_QUESTION) {
        [_doneButton setTitle:nil];
    }
    else {
        [_doneButton setTitle:@"Save"];
    }
    
    return;

}

//
//  MCSession
//

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"recieved data in EditQuest!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSString *messageType = message.messageType;
    //NSLog(@"type:%d", messageType);
    
    if(message.messageType == MSG_ANSWER_ACK) { //[messageType isEqualToString:@"answer-ack"]) {
        NSLog(@"  answer-ack");
        if(message.questionNumber == _currentQuestionNumber && message.answerNumber == _currentAnswer) {
            _currentAnswerAcked = YES;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_tableView reloadData];
            });
            
        }
    }
    else if(message.messageType == MSG_ACTION) { //[messageType isEqualToString:@"action"]) {
        NSLog(@"  action:%d",message.actionType);
        if(message.actionType == AT_REWIND) {
            
        }
        else if(message.actionType == AT_PLAY) {
            NSLog(@"  action play");
            _currentQuestionNumber = message.questionNumber;
            [self moveToNextQuestion];
            
            
        }
        else if(message.actionType == AT_PAUSE) {
            
        }
        else if(message.actionType == AT_FORWARD) {
            
        }
        else if(message.actionType == AT_DONE) { //poll is over
            
        }
    }
    else {
        NSLog(@"received invalid message");
    }

    
    
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSLog(@"peerDidChangeState");
    if(state == MCSessionStateConnected) {
        NSLog(@"connected1");
    }

}

- (IBAction)checkButtonPressed:(id)sender {
    NSLog(@"check button pressed!");

    
    UIView *parentCell = [[[sender superview] superview] superview];
    UIView *parentView = [[parentCell superview] superview];
    UITableView *tableView = (UITableView *)parentView;
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell];
    
    NSLog(@"indexPath = %zd", indexPath.row/2);
    
    if(_currentQuestion.correctAnswer == (int)indexPath.row/2) {
        _currentQuestion.correctAnswer = -1;
    }
    else {
        _currentQuestion.correctAnswer = (int)indexPath.row/2;
    }
    
    //_currentQuestion.correctAnswer = (int)indexPath.row/2;
    [_tableView reloadData];
}

- (IBAction)checkButtonOutlinePressed:(id)sender {
    NSLog(@"check button outline pressed!");
}

@end
