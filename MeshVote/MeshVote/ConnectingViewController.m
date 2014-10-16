//
//  ConnectingViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/27/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ConnectingViewController.h"
#import "Message.h"
#import "EditQuestionViewController.h"
#include <stdlib.h>

@interface ConnectingViewController ()

@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) Question* tempQuestion;
@property (nonatomic, strong) MCPeerID* host;

@property (nonatomic, strong) QuestionSet* questionSet;
@property (nonatomic) int currentQuestionNumber;


@end

@implementation ConnectingViewController

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
    // Do any additional setup after loading the view.
    
    _currentQuestionNumber = 0;

    //(arc4random() % y) + x;
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@%d",_userName,((arc4random() % 999999) + 100000)]]; //last 6 chars will be "unique" id
    
    
    _session = [[MCSession alloc] initWithPeer:me securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    _session.delegate = self;

    
    NSString* serviceType = [self getServiceTypeFromName:_sessionName];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:nil serviceType:serviceType];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
}

//translates name into service-type
//Must be 1–15 characters long
//Can contain only ASCII lowercase letters, numbers, and hyphens. hyphens must be single and interior
-(NSString*)getServiceTypeFromName:(NSString*)input {
    const char* c_string = [[input lowercaseString] UTF8String];
    char new_string[16];
    const char* runner = c_string;
    int newStringIndex = 0;
    while(*runner != '\0' && newStringIndex < 16) {
        
        if((*runner >= 'a' && *runner <= 'z') || (*runner >= 0 && *runner <= 9)) {
            new_string[newStringIndex] = *runner;
            ++newStringIndex;
        }
        ++runner;
    }
    new_string[newStringIndex] = '\0';
    return [NSString stringWithUTF8String:new_string];
}

-(void)viewWillAppear:(BOOL)animated {
    _session.delegate = self;
}

- (void)dealloc {
    NSLog(@"dealloc connecting");
    //[_browser stopBrowsingForPeers];
    [_advertiser stopAdvertisingPeer];
    [_session disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if([segue.identifier isEqualToString:@"startTakingPollSegue"]){
        //NSLog(@"prepareForSegue");
        //EditQuestionViewController *controller =
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_ASK_QUESTION;
        controller.questionSet = _questionSet;
        controller.currentQuestionNumber = _currentQuestionNumber;
        //controller.currentQuestion = _tempQuestion;
        controller.session = _session;
        controller.host = _host;
        //controller.userName = _nameInput.text;
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSLog(@"recieved invite");
    _host = peerID;
    invitationHandler([@YES boolValue], _session);
}



//
//  MCSession
//

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"recieved data in connecting view!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSString *messageType = message.messageType;
    //NSLog(@"type:%@", messageType);
    if(message.messageType == MSG_QUESTION_SET) { //[messageType isEqualToString:@"question-set"]) {
        NSLog(@"  got the question set");
        
        _questionSet = (QuestionSet*)message;
        
        
        //send question-ack to host //TODO: this should be in statis message class
        [Message sendMessageType:MSG_QUESTION_SET_ACK toPeers:@[_host] inSession:_session];
        
        for(Question* cur in _questionSet.questions) { //no given answers yet
            cur.givenAnswer = -1;
        }
    }
    
    else if(message.messageType == MSG_ANSWER_ACK) { //[messageType isEqualToString:@"answer-ack"]) {
        NSLog(@"  answer-ack");
    }
    else if(message.messageType == MSG_ACTION) { //[messageType isEqualToString:@"action"]) {
        NSLog(@"  action qnum:%d",message.questionNumber);
        if(message.actionType == AT_REWIND) {
            
        }
        else if(message.actionType == AT_PLAY) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // update label 1 text
                _currentQuestionNumber = message.questionNumber;
                [self performSegueWithIdentifier:@"startTakingPollSegue" sender:self];
            });
            
            
        }
        else if(message.actionType == AT_PAUSE) {
            
        }
        else if(message.actionType == AT_FORWARD) {
            
        }
        else if(message.actionType == AT_DONE) { //poll is over
            
        }
    }
    else {
        NSLog(@"!!!! received invalid message467");
    }
    //NSLog(@"  message:%@", recQuestion.questionText);
    
    
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
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // GUI thread
            //NSLog(@"GUI thread 1");
            // update label 1 text
            [_statusLabel setText:@"connected!"];
            
            _statusLabelBottom.alpha = 0.0;
            _checkImage.alpha = 0.0;
            _statusLabelBottom.hidden = NO;
            _checkImage.hidden = NO;
            _connectingActivityIndicator.hidden = YES;
            
            //labelMain.alpha = 0;
            
            [UIView animateWithDuration:1.0 delay:0.3 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ _statusLabelBottom.alpha = 1;}
                             completion:nil];
            //labelMain.alpha = 0;
            
            [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ _checkImage.alpha = 0.6;}
                             completion:nil];
        });
        //_statusLabel.text = @"connected!";
        //[_statusLabel setText:@"connected!"];
        //[_statusLabel reloadInputViews];
    }
    else if(state == MCSessionStateNotConnected) {
        if([peerID isEqual:_host]) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                _checkImage.image = [UIImage imageNamed:@"x_icon128.png"];
                [_statusLabel setText:@"disconnected"];
                [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{ _statusLabelBottom.alpha = 0;}
                                 completion:^(BOOL finished){
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }];
            });
        }
    }
}

@end
