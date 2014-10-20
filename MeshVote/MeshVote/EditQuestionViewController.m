//
//  EditQuestionViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "EditQuestionViewController.h"


#define PLACE_HOLDER_TEXT @"enter question here"

@interface EditQuestionViewController ()

// the current clicked answer
@property (atomic) int currentAnswer;

// has the last submitted answer been acknowledged?
@property (atomic) BOOL currentAnswerAcked;

// number of seconds remaining
@property (atomic) int timeRemaining;

// is this poll running
@property (atomic) BOOL pollRunning;

// for colors and letters
@property (nonatomic, strong) Colors* colors;

// for time input
@property (nonatomic, strong) NSNumberFormatter* numberFormatter;

// counter used to prevent multiple threads from updating counter
@property (atomic) int questionCount;

// for receiving results
@property (strong, nonatomic) NSArray* stats;

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
    
    // add bg layer
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _colors = [[Colors alloc] init];
    
    // time input stuff
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    [self.numberFormatter setGroupingSize:2];
    [self.numberFormatter setGroupingSeparator:@":"];
    [self.numberFormatter setUsesGroupingSeparator:YES];
    [self.numberFormatter setMaximumFractionDigits:0];
    [self.numberFormatter setMinimumIntegerDigits:3];
    [self.numberFormatter setMaximumIntegerDigits:3];
    
    
    _questionCount = 0;
    _currentAnswer = -1;
    _currentAnswerAcked = NO;
    
    [_doneButton setTitle:@""];
    [_doneButton setEnabled:NO];
    _questionTextLabel.clipsToBounds = YES;
    _questionTextLabel.layer.cornerRadius = 3.0f;
    
    //
    // This view supports 3 different modes, indicated by _viewMode
    //
    
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION) // create new question
    {
        // create new question
        _currentQuestion = [[Question alloc] init];
        _currentQuestion.questionText = @"";
        _currentQuestion.questionNumber = [_questionSet getQuestionCount] + 1;
        
        // update the view
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestion.questionNumber]];
        [_questionTextLabel setText:PLACE_HOLDER_TEXT];
        _questionTextLabel.textColor = [UIColor lightGrayColor];
        [_doneButton setTitle:@"Save"];
        [_doneButton setEnabled:YES];
        self.navigationItem.title = @"New question";
        
        // update time field
        _timeTextField.delegate = self;
        _timeTextField.text = [NSString stringWithFormat:@"%d:%02d", _currentQuestion.timeLimit / 60, _currentQuestion.timeLimit % 60];
        
    }
    else if(_viewMode == VIEWMODE_EDIT_QUESTION) // edit existing question
    {
        // update the view
        [_questionTextLabel setText:_currentQuestion.questionText];
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestion.questionNumber]];
        [_doneButton setEnabled:YES];
        
        // show the time
        NSInteger time = _currentQuestion.timeLimit;
        NSInteger minutes = (time / 60) % 60;
        NSInteger seconds = time % 60;
        
        self.timeTextField.delegate = self;
        self.timeTextField.text = [self.numberFormatter stringFromNumber:@([[NSString stringWithFormat:@"%02ld%02ld", (long)minutes, (long)seconds] doubleValue])];
        
    }
    else // // VIEWMODE_ASK_QUESTION - ask user a question (peer is taking poll)
    {
        _pollRunning = YES;
        
        //send action-ack
        [Message sendMessageType:MSG_ACTION_ACK withActionType:AT_PLAY toPeers:@[_host] inSession:_session];
        
        // upddate view
        [_timeTextField setBackgroundColor:[UIColor clearColor]];
        [_questionTextLabel setSelectable:NO];
        [_timeTextField setEnabled:NO];
        
        [self moveToNextQuestion];
    }
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setScrollsToTop:NO];
    
    [_questionTextLabel setDelegate:self];

    _session.delegate = self;
    
    // this fixes bug where delete-swipes not detected over UITextField
    self.tableView.panGestureRecognizer.delaysTouchesBegan = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:(190/255.0)  green:(190/255.0)  blue:(190/255.0)  alpha:1.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(_viewMode == VIEWMODE_EDIT_QUESTION) {
        [Util savePollDataToPhone:_pollSet];
    }
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"checking number of rows");

    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION || _viewMode == VIEWMODE_EDIT_QUESTION)
        return MAX(1, [_currentQuestion getAnswerCount] * 2 + 1);
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
    
    if(indexPath.row % 2 == 1) // blank spacing cell
    {
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
    
    SpacedUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eq_cellid"]; //forIndexPath:indexPath];
    [cell setHidden:NO];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[SpacedUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eq_cellid"];
    }
    
    cell.answerChoiceLetter.backgroundColor = [_colors getAlphaColor2AtIndex:indexPath.row/2];
    [cell.answerChoiceLetter setText:[_colors getLetterAtIndex:indexPath.row/2]];
    [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.08]];

    [cell setHighlighted:YES   animated:YES];

    cell.layer.cornerRadius = 2.0f;
    cell.clipsToBounds = YES;
    cell.textLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    cell.answerTextField.delegate = self;
    
    if(_currentAnswer == indexPath.row/2)
    {
        if(_currentAnswerAcked) // show check mark
        {
            cell.answerActivityIndicator.hidden = YES;
            cell.checkButton.hidden = NO;
        }
        else // show spinning indicator
        {
            cell.answerActivityIndicator.hidden = NO;
            [cell.answerActivityIndicator startAnimating];
        }
    }
    else
    {
        cell.checkButton.hidden = YES;
        cell.answerActivityIndicator.hidden = YES;
    }
    
    //if correct answer, show check button
    if(_viewMode == VIEWMODE_EDIT_QUESTION && _currentQuestion.correctAnswer == indexPath.row/2) {
        cell.checkButton.hidden = NO;
    }
    
    // show check button and outline
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION || _viewMode == VIEWMODE_EDIT_QUESTION)
    {
        if([_currentQuestion getAnswerCount] > (int)indexPath.row/2)
        {
            cell.answerTextField.alpha = 1.0;
            cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:(int)indexPath.row/2];

            if(_questionSet.isQuiz) {
                cell.checkOutline.hidden = NO;
                cell.checkOutline.enabled = YES;
                
                cell.checkButton.hidden = YES;
                cell.checkButton.enabled = NO;
            }

            [cell setEditing:NO];
            if(indexPath.row/2 == _currentQuestion.correctAnswer) {
                cell.checkButton.hidden = NO;
                cell.checkButton.enabled = YES;
                cell.checkOutline.hidden = YES;
            }

        }
        else // "add answer" button
        {
            cell.textLabel.text = @"";
            cell.answerTextField.text = @"add answer";
            cell.answerTextField.alpha = 0.25;
        }

    }
    else // VIEWMODE_ASK_QUESTION
    {
        [cell.answerTextField setEnabled:NO];
        cell.answerTextField.text = [_currentQuestion.answerText objectAtIndex:indexPath.row/2];
        cell.textLabel.text = @"";
    }
    
    // add a tag to indicate which row was clicked
    cell.tag = indexPath.row;
    cell.checkButton.tag = indexPath.row+7;
    cell.answerTextField.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_viewMode == VIEWMODE_ASK_QUESTION) // submit answer
    {
        NSLog(@"clicked answer to submit");
        
        if(_timeRemaining > 0)
        {
            // send answer to host
            Message *answerMessage = [[Message alloc] init];
            answerMessage.messageType = MSG_ANSWER;
            answerMessage.questionNumber = _currentQuestionNumber;
            answerMessage.answerNumber = (int)indexPath.row/2;
            [Message sendMessage:answerMessage toPeers:@[_host] inSession:_session];
            

            //reload view
            _currentAnswer = answerMessage.answerNumber;
            _currentAnswerAcked = NO;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_tableView reloadData];
            });
        }
        
    }
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    if(indexPath.row == [_currentQuestion getAnswerCount] * 2 || _viewMode == VIEWMODE_ASK_QUESTION)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        //update the correct answer if needed
        if(_questionSet.isQuiz)
        {
            if(_currentQuestion.correctAnswer == indexPath.row/2)
                _currentQuestion.correctAnswer = -1;
            else if(_currentQuestion.correctAnswer > indexPath.row/2)
                --_currentQuestion.correctAnswer;
        }
        
        // remove answer
        [_currentQuestion.answerText removeObjectAtIndex:indexPath.row/2];
        
        // remove row and spacer row
        NSIndexPath *p = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        [_tableView deleteRowsAtIndexPaths:@[indexPath, p] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView reloadData];
    }
    
}


-(void)moveToNextQuestion
{
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    _currentQuestion.givenAnswer = -1;
    _timeRemaining = _currentQuestion.timeLimit;
    _currentAnswer = -1;
    _currentAnswerAcked = NO;

    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [_questionNumberLabel setText:[NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1]];
        _questionTextLabel.text = _currentQuestion.questionText;
        [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
        [self.tableView reloadData];
    });
    
    // start the timer
    [self startTimer];
    
    // when we are done here, send the action-ack
    [Message sendMessageType:MSG_ACTION_ACK withActionType:AT_PLAY toPeers:@[_host] inSession:_session];
    
    
}

-(void)startTimer
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        int beginQuestionCount = _questionCount;
        while(_timeRemaining > 0)
        {
            [NSThread sleepForTimeInterval:1.0f];
            
            if(!_pollRunning || beginQuestionCount != _questionCount)
                return;

            
            --_timeRemaining;
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [_timeTextField setText:[NSString stringWithFormat:@"%d:%02d", _timeRemaining / 60, _timeRemaining % 60]];
            });
        }
    });
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"showPeerResultsPollSegue"]){
        ResultsPollViewController *controller = (ResultsPollViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
    }
    else if([segue.identifier isEqualToString:@"showPeerResultsSegue"]){
        ResultsViewController *controller = (ResultsViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        controller.stats = _stats;

    }
}


-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (IBAction)doneButtonPressed:(id)sender
{
    if([_doneButton.title isEqualToString:@"Done"]) // in edit text view .. _viewMode == EDIT OR NEW
    {
        [self.view endEditing:YES];
    }
    else // save/add new question
    {
        [_questionSet addQuestion:_currentQuestion];
        
        [Util savePollDataToPhone:_pollSet];

        [self.navigationController popViewControllerAnimated:YES];
        
        //TODO: need to resend questionset to connected peers!
        
    }
}


//
//  TextViewDelegate, for question
//

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [_doneButton setTitle:@"Done"];
    
    if([_questionTextLabel.text isEqualToString:PLACE_HOLDER_TEXT])
    {
        [_questionTextLabel setText:@""];
        _questionTextLabel.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.navigationItem setHidesBackButton:NO animated:YES];
    if(_viewMode == VIEWMODE_ADD_NEW_QUESTION)
    {
        [_doneButton setTitle:@"Save"];
        if([_questionTextLabel.text isEqualToString:@""])
        {
            [_questionTextLabel setText:PLACE_HOLDER_TEXT];
            _questionTextLabel.textColor = [UIColor lightGrayColor];
        }
    }
    else
    {
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if(textField.tag == -1) // time text field
    {
        NSString *originalNumber = textField.text;
        if([replacementString isEqualToString:@""])
        {
            originalNumber = [originalNumber stringByReplacingCharactersInRange:range withString:@""];
        }
        else
        {
            originalNumber = [originalNumber stringByAppendingString:replacementString];
        }
        originalNumber = [originalNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *newString = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[originalNumber doubleValue]]];
        self.timeTextField.text = newString;

        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _questionTextLabel.editable = NO;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [_doneButton setTitle:@"Done"];
    [_doneButton setEnabled:YES];

    
    if(textField.tag != -1) // if not time field
    {
        /*
        SpacedUITableViewCell *clickedCell = (SpacedUITableViewCell *)[[[textField superview] superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        */
        NSLog(@"clicked:%d", (int)textField.tag);
        
        //move the UI up so the keyboard doesnt hide it TODO: maybe need to max out around 5 or 6?
        [UIView beginAnimations:@"registerScroll" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
        
        int screenOffset = 0;

        // dont need to lift more than 5 or so cells
        int scale = MIN((int)textField.tag/2, 5) + 1;
        
        // check if 3.5 inch screen
        if([[UIScreen mainScreen] bounds].size.height < 568)
        {
            screenOffset = 568 - [[UIScreen mainScreen] bounds].size.height;
            
            // max out at 3 cells for smaller screens
            scale = MIN((int)textField.tag/2, 3) + 1;
        }
        
        self.view.transform = CGAffineTransformMakeTranslation(0, (-34.0 * scale) - screenOffset);
        [UIView commitAnimations];
        
        if([textField.text isEqualToString:@"add answer"])
        {
            textField.text = @"";
            textField.alpha = 1.0;

        }

    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
     _questionTextLabel.editable = YES;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    if(textField.tag == -1) // time field text
    {
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
    else // if not the time text field, its an answer field
    {
    
        //reset the view's position
        [UIView beginAnimations:@"registerScroll" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
        //self.
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView commitAnimations];
        
        
        //SpacedUITableViewCell *clickedCell = (SpacedUITableViewCell *)[[[textField superview] superview] superview];
        //NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        
        int indexClicked = (int)textField.tag;
        
        if(indexClicked/2 == [_currentQuestion getAnswerCount]) {
            NSLog(@"adding a new answer");
            [_currentQuestion addAnswer:textField.text];

        }
        else {
            NSLog(@"editing an existing answer");
            [_currentQuestion.answerText setObject:textField.text atIndexedSubscript:indexClicked/2];
        }
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
    
    
    if(_viewMode == VIEWMODE_EDIT_QUESTION)
    {
        [_doneButton setTitle:nil];
    }
    else
    {
        [_doneButton setTitle:@"Save"];
    }
    
    return;

}

//
//  MCSession
//

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"recieved data in EditQuest!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    
    if(message.messageType == MSG_ANSWER_ACK)
    {
        NSLog(@"  answer-ack, qnum:%d, ans:%d", message.questionNumber, message.answerNumber);
        if(message.questionNumber == _currentQuestionNumber && message.answerNumber == _currentAnswer)
        {
            _currentAnswerAcked = YES;
            _currentQuestion.givenAnswer = message.answerNumber;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_tableView reloadData];
            });
        }
    }
    else if(message.messageType == MSG_ACTION)
    {
        NSLog(@"  action:%d",message.actionType);
        if(message.actionType == AT_REWIND)
        {
            ++_questionCount;
            _currentQuestionNumber = message.questionNumber;
            [self moveToNextQuestion];
        }
        else if(message.actionType == AT_PLAY)
        {
            NSLog(@"  action play");
            ++_questionCount;
            if(!_pollRunning) { //meaning we were paused
                _pollRunning = YES;
                [self startTimer];
            }
            else {
                _currentQuestionNumber = message.questionNumber;
                [self moveToNextQuestion];
            }
            
            
        }
        else if(message.actionType == AT_PAUSE)
        {
            _pollRunning = NO;
        }
        else if(message.actionType == AT_FORWARD)
        {
            ++_questionCount;
            _currentQuestionNumber = message.questionNumber;
            [self moveToNextQuestion];
            
        }
        else if(message.actionType == AT_DONE) // poll is over
        {
            NSLog(@"Poll done");
            dispatch_async(dispatch_get_main_queue(), ^(void){ //TODO: goto poll complete screen
                [self performSegueWithIdentifier:@"pollDoneSegue" sender:self];
            });
        }
    }
    else if(message.messageType == MSG_POLL_RESULTS)
    {
        NSLog(@"got poll results");
        Results* results = (Results*)message;
        _stats = results.stats;
        NSLog(@"results size:%lu", (unsigned long)results.votes.count);
        int i = 0;
        for(Question* runner in _questionSet.questions)
        {

            runner.voteCounts = [results.votes objectAtIndex:i];
            ++i;
            
            int sum = 0;
            for(NSNumber* num in runner.voteCounts)
            {
                sum += [num intValue];
            }
            runner.voteCount = sum;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if(_questionSet.isQuiz)
                 [self performSegueWithIdentifier:@"showPeerResultsSegue" sender:self];
            else
                [self performSegueWithIdentifier:@"showPeerResultsPollSegue" sender:self];
        });
        
    }
    else if(message.messageType == MSG_QUESTION_SET)
    {
        NSLog(@"  got the question set");
        
        _questionSet = (QuestionSet*)message;
        
        //send question-ack to host 
        [Message sendMessageType:MSG_QUESTION_SET_ACK toPeers:@[_host] inSession:session];
        
        for(Question* cur in _questionSet.questions)  //no given answers yet
            cur.givenAnswer = -1;
        
    }
    else
    {
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
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
    NSLog(@"peerDidChangeState");
    if(state == MCSessionStateConnected) {
        NSLog(@"connected1");
    }
    else if(state == MCSessionStateNotConnected) {
        if([peerID isEqual:_host]) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:NO];
                [self.navigationController popViewControllerAnimated:NO];
            });
        }
    }

}

- (IBAction)checkButtonPressed:(id)sender
{
    NSLog(@"check button pressed!");
    
    // need to get the tag of the cell to determine which answer was clicked
    // this loop was necessary to be compatible with ios 7 and 8
    UIView* runner = sender;
    while(![runner isKindOfClass:[SpacedUITableViewCell class]])
        runner = [runner superview];
    
    int indexClicked = (int)runner.tag;
    
    NSLog(@"indexPath = %zd", indexClicked/2);
    
    if(_currentQuestion.correctAnswer == indexClicked/2) {
        _currentQuestion.correctAnswer = -1;
    }
    else {
        _currentQuestion.correctAnswer = indexClicked/2;
    }
    
    //_currentQuestion.correctAnswer = (int)indexPath.row/2;
    [_tableView reloadData];
}

- (IBAction)checkButtonOutlinePressed:(id)sender
{
    NSLog(@"check button outline pressed!");
}


@end
