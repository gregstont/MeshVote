

//
//  RunningPollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "RunningPollViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define QUESTION_DELAY 1

@interface RunningPollViewController ()

// reference to the question currently being polled
@property (nonatomic, strong) Question* currentQuestion;

// the current question index, starting at 0
@property (atomic) int currentQuestionNumber;

// number of seconds remaining
@property (nonatomic) int timeRemaining;

// number of votes received
@property (nonatomic) int voteCount;

// indicates whether the poll is paused or not
@property (atomic) BOOL pollRunning;

// vote history for results
@property (nonatomic, strong) NSMutableDictionary* voteHistory;

// for colors and letters
@property (nonatomic, strong) Colors *colors;


// toolbar items
@property (nonatomic, strong) UIBarButtonItem *rewind;
@property (nonatomic, strong) UIBarButtonItem *play;
@property (nonatomic, strong) UIBarButtonItem *pause;
@property (nonatomic, strong) UIBarButtonItem *forward;



@end

@implementation RunningPollViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
- (NSString*)timeAsString:(int)time {
    return [NSString stringWithFormat:@"%d:%02d",time / 60, time % 60];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add bg layer
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    // show nav bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    _colors = [[Colors alloc] init];
    
    //this is used to track who voted for what, and used for displaying personal results at the end
    _voteHistory = [[NSMutableDictionary alloc] init];
    
    for(NSString* peerName in _peerList) {
        
        NSLog(@"adding peer to vote history");
        NSMutableArray *newPeerHistory = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount] ];
        for(int i = 0; i < [_questionSet getQuestionCount]; ++i) {
            [newPeerHistory addObject:[NSNumber numberWithInt:-1]];
        }
        [_voteHistory setObject:newPeerHistory forKey:peerName];
    }
    
    _pollRunning = YES;
    _voteCount = 0;
    _currentQuestionNumber = 0;
    
    
    _answerTable.delegate = self;
    _answerTable.dataSource = self;
    
    _bigSession.delegate = self;

    
    // setup the toolbar
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    _rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewindPressed:)];
    _play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPressed:)];
    _pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pausePressed:)];
    _forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardPressed:)];
    _rewind.enabled = NO;
    
    NSArray *buttonItems = [NSArray arrayWithObjects:spacer, _rewind, spacer, _pause, spacer, _forward, spacer, nil];
    self.toolbarItems = buttonItems;
    
    
    // reset vote counts
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    _currentQuestion.voteCounts = [[NSMutableArray alloc] initWithCapacity:[_currentQuestion getAnswerCount]];
    for(int i = 0; i < [_currentQuestion getAnswerCount]; ++i) {
        [_currentQuestion.voteCounts addObject:[NSNumber numberWithInt:0]];
    }
    
    _timeRemaining = _currentQuestion.timeLimit;
    _votesReceivedLabel.text = @"0";

    
    
    // setup circular progress bars for time and votes received (KAProgressLabel)
    [self setupProgressBars];

    [self beginPollAndClearVotes:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    _bigSession.delegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:(190/255.0)  green:(190/255.0)  blue:(190/255.0)  alpha:1.0];
}


- (void)viewWillDisappear:(BOOL)animated
{
    _pollRunning = NO;
}


// setup circular progress bars for time and votes received (KAProgressLabel)
-(void)setupProgressBars
{
    _timeProgressLabel.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
    };
    _votesProgressLabel.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
    };
    [_votesProgressLabel setProgress:0.0
                              timing:TPPropertyAnimationTimingEaseOut
                            duration:1.0
                               delay:0.0];
    [_timeProgressLabel setProgress:(_timeRemaining +0.0) / 60
                             timing:TPPropertyAnimationTimingEaseOut
                           duration:0.4
                              delay:0.0];
    [_timeProgressLabel setColorTable: @{
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor],
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor clearColor],
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor darkGrayColor]
                                         }];
    [_votesProgressLabel setColorTable: @{
                                          NSStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor],
                                          NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor colorWithRed:1.0 green:94/255.0 blue:58/255.0 alpha:0.2],
                                          NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor colorWithRed:1.0 green:94/255.0 blue:58/255.0 alpha:0.7]
                                          }];
    [_timeProgressLabel setAlpha:0.5];
    
    [_votesProgressLabel setFrontBorderWidth:8];
    [_votesProgressLabel setBackBorderWidth:8];
    [_timeProgressLabel setBackBorderWidth:11];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)beginPollAndClearVotes:(BOOL)clear
{
    NSLog(@"beginPoll, timeRem:%d", _timeRemaining);
    if(clear)
    {
        // clear votes
        _voteCount = 0;
        _currentQuestion.voteCounts = [[NSMutableArray alloc] initWithCapacity:[_currentQuestion getAnswerCount]];
        for(int i = 0; i < [_currentQuestion getAnswerCount]; ++i) {
            [_currentQuestion.voteCounts addObject:[NSNumber numberWithInt:0]];
        }
        
        //clear the answers for connected peers
        for (NSString* key in [_peerList allKeys]) {
            [_peerList setObject:[NSNumber numberWithInt:-1] forKey:key];
        }
    }
    
    //update the toolbar buttons
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if(_currentQuestionNumber > 0)
            _rewind.enabled = YES;
        else
            _rewind.enabled = NO;
    });
    
    
    if(_pollRunning)
    {
        // send begin message to everybody
        Message *beginMessage = [[Message alloc] init];
        beginMessage.messageType = MSG_ACTION;
        beginMessage.questionNumber = _currentQuestionNumber;
        beginMessage.actionType = AT_PLAY;
        
        [Message broadcastMessage:beginMessage inSession:_bigSession];
    }
    
    
    // update the view
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        _totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
        _votesReceivedLabel.text = @"0";
        
        self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
        self.pollQuestionText.text = _currentQuestion.questionText;
        [self.answerTable reloadData];
        self.navigationItem.title = [NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1];
        
        [_votesProgressLabel setProgress:(_voteCount + 0.0)/[[_peerList allKeys] count]
                                  timing:TPPropertyAnimationTimingEaseOut
                                duration:1.0
                                   delay:0.0];
        [_timeProgressLabel setProgress:(_timeRemaining +0.0) / 60
                                 timing:TPPropertyAnimationTimingEaseOut
                               duration:0.4
                                  delay:0.0];
    });

    if(_pollRunning)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
        {
            int beginQuestionNumber = _currentQuestionNumber;

            while(_timeRemaining > 0 && _pollRunning)
            {
                [NSThread sleepForTimeInterval:1.0f];
                
                // if host press paused/forward/rewind while sleeping, catch here
                if(_pollRunning == NO || (beginQuestionNumber != _currentQuestionNumber))
                    return;
                
                --_timeRemaining;
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
                    
                    [_timeProgressLabel setProgress:(_timeRemaining + 0.0)/60
                                             timing:TPPropertyAnimationTimingEaseOut
                                           duration:0.2
                                              delay:0.0];
                });
            }
            NSLog(@"times up, questionNum:%d votecount:%d",_currentQuestionNumber,_voteCount);
            
            
            _currentQuestion.voteCount = _voteCount;
            
            // delay for slow peers
            [NSThread sleepForTimeInterval:(double)QUESTION_DELAY];
            
            if(_pollRunning == NO || (beginQuestionNumber != _currentQuestionNumber))
            {
                //catch the back
            }
            else if(_currentQuestionNumber < [_questionSet getQuestionCount] - 1)
            {
                // move to next question
                ++_currentQuestionNumber;
                _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
                _timeRemaining = _currentQuestion.timeLimit;
                [self beginPollAndClearVotes:YES];
            }
            else
            {
                // poll is over
                NSLog(@"Poll over");
                [self showResults];
            }
        });
    }
}


-(void)showResults
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if(_questionSet.isQuiz)
            [self performSegueWithIdentifier:@"showResultsSegue" sender:self];
        else
            [self performSegueWithIdentifier:@"showResultsPollSegue" sender:self];
            
    });
}



//
//  Toolbar buttons
//

- (IBAction)rewindPressed:(UIButton *)sender
{
    --_currentQuestionNumber; //changing this number will stop previous questions thread
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    _timeRemaining = _currentQuestion.timeLimit;
    [self beginPollAndClearVotes:YES];
    
    // tell peers to go back
    Message *rewind = [[Message alloc] init];
    rewind.messageType = MSG_ACTION;
    rewind.actionType = AT_REWIND;
    rewind.questionNumber = _currentQuestionNumber;
    [Message broadcastMessage:rewind inSession:_bigSession];
}


- (IBAction)playPressed:(UIButton *)sender
{
    // update the toolbar to show pause
    NSMutableArray *newToolbar = [self.toolbarItems mutableCopy];
    [newToolbar removeObject:_play];
    [newToolbar insertObject:_pause atIndex:3];
    [self setToolbarItems:newToolbar];
    
    //start the poll
    _pollRunning = YES;
    [self beginPollAndClearVotes:NO];
}


- (IBAction)pausePressed:(UIButton *)sender
{
    _pollRunning = NO;
    
    // update the toolbar
    NSMutableArray *newToolbar = [self.toolbarItems mutableCopy];
    [newToolbar removeObject:_pause];
    [newToolbar insertObject:_play atIndex:3];
    [self setToolbarItems:newToolbar];
    
    // tell peers to pause
    Message *message = [[Message alloc] init];
    message.messageType = MSG_ACTION;
    message.actionType = AT_PAUSE;
    [Message broadcastMessage:message inSession:_bigSession];
}


- (IBAction)forwardPressed:(UIButton *)sender
{
    
    if(_currentQuestionNumber == [_questionSet getQuestionCount] - 1)
    {
        //on last question
        [self showResults];
    }
    else
    {
        // go to next question
        ++_currentQuestionNumber; //incrementing this number will stop previous questions thread
        _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
        _timeRemaining = _currentQuestion.timeLimit;
        [self beginPollAndClearVotes:YES];
        
        // tell peers to go forward
        Message *forward = [[Message alloc] init];
        forward.messageType = MSG_ACTION;
        forward.actionType = AT_FORWARD;
        forward.questionNumber = _currentQuestionNumber;
        [Message broadcastMessage:forward inSession:_bigSession];
    }
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"showResultsSegue"])
    {
        ResultsViewController *controller = (ResultsViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        controller.bigSession = _bigSession;
        controller.voteHistory = _voteHistory;
    }
    else if([segue.identifier isEqualToString:@"showResultsPollSegue"])
    {
        ResultsPollViewController *controller = (ResultsPollViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        controller.bigSession = _bigSession;
    }
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
    return [_currentQuestion getAnswerCount];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }

    cell.answerLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLetterLabel.text = [_colors getLetterAtIndex:indexPath.row];
    cell.answerProgress.progressTintColor = [_colors getColorAtIndex:indexPath.row];
    cell.answerProgress.backgroundColor = [_colors getAlphaColorAtIndex:indexPath.row];
    
    double newPercent;
    if(_voteCount == 0) {
        newPercent = 0.0;
    }
    else {
        newPercent = ([[_currentQuestion.voteCounts objectAtIndex:indexPath.row] intValue] + 0.0) / _voteCount;
    }

    [cell.answerProgress setProgress:newPercent animated:YES];
    cell.answerPercentLabel.text = [NSString stringWithFormat:@"%d", (int)(newPercent * 100)];
    
    //stretch the progress bar
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    
    // fix ios 8 bug
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        transform = CGAffineTransformTranslate(transform, 0, 1);
    
    cell.answerProgress.transform = transform;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);

}

//
//  MCSessionDelegate
//

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
    NSLog(@"peer changed state in RunningView:");
    
    if(state == MCSessionStateConnected)
    {
        NSLog(@"  connected: %@", peerID.displayName);
        
        // add to peerlist with -1 vote
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:peerID.displayName];
        
        // send question set to peer
        _questionSet.messageType = MSG_QUESTION_SET;
        [Message sendMessage:_questionSet toPeers:@[peerID] inSession:session]; //session !!!
        
        
        // add peer to the vote history if not already there
        if([_voteHistory objectForKey:peerID.displayName] == nil)
        {
            // add peer
            NSMutableArray *newPeerHistory = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount] ];
            for(int i = 0; i < [_questionSet getQuestionCount]; ++i)
            {
                [newPeerHistory addObject:[NSNumber numberWithInt:-1]];
            }

            [_voteHistory setObject:newPeerHistory forKey:peerID.displayName];
            
        }

    }
    else if(state == MCSessionStateNotConnected)
    {
        NSLog(@"  NOT connected: %@",peerID.displayName);
        
        // remove from peerlist
        [_peerList removeObjectForKey:peerID.displayName];
        
    }
    else if(state == MCSessionStateConnecting)
    {
        NSLog(@"  connecting...");
    }
    
    // update connected peers label
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        _totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
    });
}


// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"recieved data, from peer:%@", peerID.displayName);
    
    // unarchive the data into a message
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];


    if(message.messageType == MSG_ACTION_ACK )
    {
        if(message.actionType == AT_PLAY) {
            NSLog(@"action-play-ack: curQues:%d", _currentQuestionNumber);
            
        }
    }
    else if(message.messageType == MSG_ANSWER)
    {
        NSLog(@"received answer:%zd from:%@", message.answerNumber, peerID.displayName);
        
        // new vote
        if([[_peerList objectForKey:peerID.displayName] isEqualToNumber:[NSNumber numberWithInt:-1]])
        {
            ++_voteCount;
            
            // update peerlist with new answer
            [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
            
            // increment the voteCounts
            int currentCount = [[_currentQuestion.voteCounts objectAtIndex:message.answerNumber] intValue];
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:++currentCount] atIndexedSubscript:message.answerNumber];
            
            //need to update table
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [_answerTable reloadData];
            });
            
            
        }
        else // someone changed their vote
        {
            // remove the old vote
            int oldAnswer = [[_peerList objectForKey:peerID.displayName] intValue];
            int oldVoteCount = [[_currentQuestion.voteCounts objectAtIndex:oldAnswer] intValue];
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:--oldVoteCount] atIndexedSubscript:oldAnswer];
            
            // add the new vote
            oldVoteCount = [[_currentQuestion.voteCounts objectAtIndex:message.answerNumber] intValue];
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:++oldVoteCount] atIndexedSubscript:message.answerNumber];
            
            // update the peerlist with new vote
            [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
            
            // update the answer table
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [_answerTable reloadData];
            });
        }
        
        // add the vote to the voteHistory
        NSMutableArray* peerHist = [_voteHistory objectForKey:peerID.displayName];
        [peerHist setObject:[NSNumber numberWithInt:message.answerNumber] atIndexedSubscript:message.questionNumber];
        
        
        // need to send answer-ack
        Message *answerAck = [[Message alloc] init];
        answerAck.messageType = MSG_ANSWER_ACK;
        answerAck.questionNumber = _currentQuestionNumber;
        answerAck.answerNumber = message.answerNumber;
        [Message sendMessage:answerAck toPeers:@[peerID] inSession:session];
        
        _currentQuestion.voteCount = _voteCount;
        
        [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            _votesReceivedLabel.text = [NSString stringWithFormat:@"%d", _voteCount];
            
            [_votesProgressLabel setProgress:(_voteCount + 0.0)/[[_peerList allKeys] count]
                                      timing:TPPropertyAnimationTimingEaseOut
                                    duration:1.0
                                       delay:0.0];
        });
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






@end