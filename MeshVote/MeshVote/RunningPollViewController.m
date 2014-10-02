


//
//  RunningPollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "RunningPollViewController.h"
#import "BackgroundLayer.h"
#import "Question.h"
#import "RunningAnswerTableViewCell.h"
#import "ResultsViewController.h"

#define QUESTION_DELAY 1

@interface RunningPollViewController ()

@property (nonatomic, strong) Question* currentQuestion;
@property (nonatomic) int currentQuestionNumber; //starts at 0

@property (nonatomic) int timeRemaining;
//@property (nonatomic) BOOL hasBegunPoll;

@property (nonatomic) int voteCount;

@property (nonatomic) BOOL pollRunning;

@property (nonatomic, strong) Colors *colors;

@property (nonatomic, strong) NSMutableDictionary* voteHistory;


@end

@implementation RunningPollViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _voteCount = 0;
        
    }
    return self;
}
- (NSString*)timeAsString:(int)time {
    return [NSString stringWithFormat:@"%d:%02d",time / 60, time % 60];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_hasBegunPoll = NO;
    _pollRunning = YES;
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
    
    
    [_answerTable setDataSource:self];
    [_answerTable setDelegate:self];
    
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewindPressed:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPressed:)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardPressed:)];
    forward.enabled = NO;
    
    //[_currentQuestion.timeLimit ;
    
    
    
    
    NSArray *buttonItems = [NSArray arrayWithObjects:spacer, rewind, spacer, play, spacer, forward, spacer, nil];
    self.toolbarItems = buttonItems;
    
    
    _currentQuestionNumber = 0;
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    _currentQuestion.voteCounts = [[NSMutableArray alloc] initWithCapacity:[_currentQuestion getAnswerCount]];
    for(int i = 0; i < [_currentQuestion getAnswerCount]; ++i) {
        [_currentQuestion.voteCounts addObject:[NSNumber numberWithInt:0]];
    }
    
    NSLog(@"NUMNER OF ELEMTD :%zd", _currentQuestion.voteCounts.count);
    
    _timeRemaining = _currentQuestion.timeLimit;
    //_timeRemainingLabel.text = [self timeAsString:_currentQuestion.timeLimit];//[NSString stringWithFormat:@"%d", _currentQuestion.timeLimit];
    NSLog(@"number of questions:%d", [_questionSet getQuestionCount]);
    
    
    //_totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
    _votesReceivedLabel.text = @"0";
    _voteCount = 0;
    
    
    _session.delegate = self;
    
    //
    // setup circular progress bars for time and votes received (KAProgressLabel)
    //
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
    //[_timeProgressLabel setClockWise:NO];

    [self beginPoll];
}
- (void)viewWillAppear:(BOOL)animated {
    _session.delegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:(190/255.0)  green:(190/255.0)  blue:(190/255.0)  alpha:1.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    _pollRunning = NO;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.toolbar.barTintColor = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beginPoll {
    NSLog(@"beginPoll, timeRem:%d", _timeRemaining);
    _voteCount = 0;
    _currentQuestion.voteCounts = [[NSMutableArray alloc] initWithCapacity:[_currentQuestion getAnswerCount]];
    for(int i = 0; i < [_currentQuestion getAnswerCount]; ++i) {
        [_currentQuestion.voteCounts addObject:[NSNumber numberWithInt:0]];
    }
    
    //clear the answers for connected peers
    for (NSString* key in [_peerList allKeys]) {
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:key];
        //id value = [xyz objectForKey:key];
        // do stuff
    }
    
    
    //TODO: need to verify all peers have acknowledged the question
    Message *beginMessage = [[Message alloc] init];
    beginMessage.messageType = MSG_ACTION;
    beginMessage.questionNumber = _currentQuestionNumber;
    beginMessage.actionType = AT_PLAY;
    
    [Message sendMessage:beginMessage toPeers:[_session connectedPeers] inSession:_session];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
        _votesReceivedLabel.text = @"0";
        
        self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
        self.pollQuestionText.text = _currentQuestion.questionText;
        [self.answerTable reloadData];
        self.navigationItem.title = [NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1];
        
        [_votesProgressLabel setProgress:0.0
                                  timing:TPPropertyAnimationTimingEaseOut
                                duration:1.0
                                   delay:0.0];
        [_timeProgressLabel setProgress:(_timeRemaining +0.0) / 60
                                 timing:TPPropertyAnimationTimingEaseOut
                               duration:0.4
                                  delay:0.0];
        
        //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
    //self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
    //self.pollQuestionText.text = _currentQuestion.questionText;
    if(_pollRunning) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            // background thread
            //NSLog(@"Background thread 1: waiting 5 seconds");
            // wait 5 seconds
            while(_timeRemaining > 0 && _pollRunning) {
                [NSThread sleepForTimeInterval:1.0f];
                --_timeRemaining;
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    // GUI thread
                    //NSLog(@"GUI thread 1");
                    // update label 1 text
                    self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];//@"Done with Label 1";
                    
                    [_timeProgressLabel setProgress:(_timeRemaining + 0.0)/60
                                             timing:TPPropertyAnimationTimingEaseOut
                                           duration:0.2
                                              delay:0.0];
                });
                //NSLog(@"times up");
            }
            NSLog(@"times up, questionNum:%d",_currentQuestionNumber);
            
            
            _currentQuestion.voteCount = _voteCount;
            [NSThread sleepForTimeInterval:(double)QUESTION_DELAY];
            if(_pollRunning == NO) {
                //catch the back
            }
            else if(_currentQuestionNumber < [_questionSet getQuestionCount] - 1) {
                ++_currentQuestionNumber;
                _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
                _timeRemaining = _currentQuestion.timeLimit;
                [self beginPoll];
            }
            else { //poll is over
                NSLog(@"Poll over");
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"showResultsSegue" sender:self];
                });
            }
        });
    }
    //NSLog(@"times up");
}



//
//  Toolbar buttons
//

- (IBAction)rewindPressed:(UIButton *)sender {
    //[self performSegueWithIdentifier:segueToWordCategoryView sender:self];
}
- (IBAction)playPressed:(UIButton *)sender {
    NSLog(@"playPressed");
    [self performSegueWithIdentifier:@"startPollSegue" sender:self];
}
- (IBAction)forwardPressed:(UIButton *)sender {
    //[self performSegueWithIdentifier:segueToWordCategoryView sender:self];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"showResultsSegue"]){
        //NSLog(@"prepareForSegue");
        ResultsViewController *controller = (ResultsViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        NSLog(@"vote history cout:%lu", (unsigned long)_voteHistory.count);
        controller.voteHistory = _voteHistory;
    }
    //showQuestion
    
    //addNewQuestionSegue
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
    NSLog(@"number of rows in poll:%d",[_currentQuestion getAnswerCount]);
    //return [_questionSet getQuestionCount];
    return [_currentQuestion getAnswerCount];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"]; //forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }
    //NSLog(@"answer:%@", [_currentQuestion.answerText objectAtIndex:indexPath.row]);
    //cell.textLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLetterLabel.text = [_colors getLetterAtIndex:indexPath.row];
    cell.answerProgress.progressTintColor = [_colors getColorAtIndex:indexPath.row];
    cell.answerProgress.backgroundColor = [_colors getAlphaColorAtIndex:indexPath.row];
    //[cell.answerProgress.backgroundColor s]
    
    double newPercent;
    if(_voteCount == 0) {
        newPercent = 0.0;
    }
    else {
        newPercent = ([[_currentQuestion.voteCounts objectAtIndex:indexPath.row] intValue] + 0.0) / _voteCount;
    }
    //NSLog(@"newPercent: %f", newPercent);
    //cell.answerProgress.progress = newPercent;
    [cell.answerProgress setProgress:newPercent animated:YES];
    cell.answerPercentLabel.text = [NSString stringWithFormat:@"%d", (int)(newPercent * 100)];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    cell.answerProgress.transform = transform;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    //_selectedQuestion = (int)indexPath.row;
    
    //[self performSegueWithIdentifier:@"showQuestion" sender:self];
    
    //TODO: this
    
    
}

//
//  MCSessionDelegate
//

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSLog(@"peer changed state in RunningView:");
    
    if(state == MCSessionStateConnected) {
        NSLog(@"  connected: %@", peerID.displayName);
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
        });
        //_questionSet.messageType = @"question-set";
        _questionSet.messageType = MSG_QUESTION_SET;
        
        [Message sendMessage:_questionSet toPeers:@[peerID] inSession:_session];
        
        
        NSLog(@"HEREEEEE1");
        //add peer to the vote history if not already there
        if([_voteHistory objectForKey:peerID.displayName] == nil) { //add peer
            NSLog(@"adding peer to vote history");
            NSMutableArray *newPeerHistory = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount] ];
            for(int i = 0; i < [_questionSet getQuestionCount]; ++i) {
                [newPeerHistory addObject:[NSNumber numberWithInt:-1]];
            }
            [_voteHistory setObject:newPeerHistory forKey:peerID.displayName];
            
        }

    }
    else if(state == MCSessionStateNotConnected) {
        NSLog(@"  NOT connected: %@",peerID.displayName);
        [_peerList removeObjectForKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _totalConnectedLabel.text = [NSString stringWithFormat:@"%zd", [[_peerList allKeys] count]];
        });
    }
    else if(state == MCSessionStateConnecting) {
        NSLog(@"  connecting...");
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"recieved data, from peer:%@", peerID.displayName);
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];


    if(message.messageType == MSG_ACTION_ACK ) { //[messageType isEqualToString:@"action-ack"]) {
        NSLog(@"in action-ack");
        if(message.actionType == AT_PLAY) {
            NSLog(@"action-play-ack: curQues:%d", _currentQuestionNumber);
            
        }
    }
    else if(message.messageType == MSG_ANSWER) { //[messageType isEqualToString:@"answer"]) {
        NSLog(@"received answer:%zd from:%@", message.answerNumber, peerID.displayName);
        //if([_peerList ])
        
        //new vote
        if([[_peerList objectForKey:peerID.displayName] isEqualToNumber:[NSNumber numberWithInt:-1]]) {
            ++_voteCount;
            [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
            int currentCount = [[_currentQuestion.voteCounts objectAtIndex:message.answerNumber] intValue];
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:++currentCount] atIndexedSubscript:message.answerNumber];
            
            //need to update table
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_answerTable reloadData];
                //_votesReceivedLabel.text = [NSString stringWithFormat:@"%d", _voteCount];
            });
            
            
        }
        else { //someone changed their vote
            //NSNumber *oldAnswer = [_peerList objectForKey:peerID.displayName];
            
            //remove the old vote
            int oldAnswer = [[_peerList objectForKey:peerID.displayName] intValue];
            int oldVoteCount = [[_currentQuestion.voteCounts objectAtIndex:oldAnswer] intValue];
            NSLog(@"old answer:%zd", oldAnswer);
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:--oldVoteCount] atIndexedSubscript:oldAnswer];
            
            //add the new vote
            oldVoteCount = [[_currentQuestion.voteCounts objectAtIndex:message.answerNumber] intValue];
            [_currentQuestion.voteCounts setObject:[NSNumber numberWithInt:++oldVoteCount] atIndexedSubscript:message.answerNumber];
            
            //update the peerlist with new vote
            [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
            
            //update the answer table
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_answerTable reloadData];
                //_votesReceivedLabel.text = [NSString stringWithFormat:@"%d", _voteCount];
            });
        }
        
        //add the vote to the voteHistory
        NSMutableArray* peerHist = [_voteHistory objectForKey:peerID.displayName];
        [peerHist setObject:[NSNumber numberWithInt:message.answerNumber] atIndexedSubscript:message.questionNumber];
        
        
        //need to send answer-ack
        Message *answerAck = [[Message alloc] init];
        answerAck.messageType = MSG_ANSWER_ACK;
        answerAck.questionNumber = _currentQuestionNumber;
        answerAck.answerNumber = message.answerNumber;
        [Message sendMessage:answerAck toPeers:[_session connectedPeers] inSession:_session];
        
        
        [_peerList setObject:[NSNumber numberWithInt:message.answerNumber] forKey:peerID.displayName];
        //++_voteCount;
        dispatch_async(dispatch_get_main_queue(), ^(void){
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