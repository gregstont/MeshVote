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
    NSLog(@"sessionName:%@", _sessionName);
    // Do any additional setup after loading the view.
    //MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:@"luigi"];
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@%d",_userName,arc4random_uniform(999)]];
    
    _session = [[MCSession alloc] initWithPeer:me securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    // Set ourselves as the MCSessionDelegate
    _session.delegate = self;
    
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:nil serviceType:_sessionName];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
}

- (void)dealloc {
    NSLog(@"dealloc join");
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
        controller.currentQuestion = _tempQuestion;
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
    NSString *messageType = message.messageType;
    NSLog(@"type:%@", messageType);
    if([messageType isEqualToString:@"question"]) {
        
        //received new question, ready to begin
        _tempQuestion = (Question*)message;
        //Question *recQuestion = (Question*)message;
        NSLog(@"  question message:%@", _tempQuestion.questionText);
        //[_session sendData:testAck toPeers:peers withMode:MCSessionSendDataReliable error:&error];
        
        
        //send question-ack to host
        NSLog(@"send question-ack to host...");
        Message *questionAck = [[Message alloc] init];
        questionAck.messageType = @"question-ack";
        questionAck.questionNumber = _tempQuestion.questionNum;
        NSData *ackData = [NSKeyedArchiver archivedDataWithRootObject:questionAck];
        NSError *error;
        
        
        
        [_session sendData:ackData toPeers:@[_host] withMode:MCSessionSendDataReliable error:&error];
        if(error) {
            NSLog(@"Error sending data");
        }
    }
    
    else if([messageType isEqualToString:@"answer-ack"]) {
        NSLog(@"  answer-ack");
    }
    else if([messageType isEqualToString:@"action"]) {
        NSLog(@"  action:%d",message.actionType);
        if(message.actionType == ACTION_REWIND) {
            
        }
        else if(message.actionType == ACTION_PLAY) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // GUI thread
                //NSLog(@"GUI thread 1");
                // update label 1 text
                [self performSegueWithIdentifier:@"startTakingPollSegue" sender:self];
            });
            
            
        }
        else if(message.actionType == ACTION_PAUSE) {
            
        }
        else if(message.actionType == ACTION_FORWARD) {
            
        }
        else if(message.actionType == ACTION_DONE) { //poll is over
            
        }
    }
    else {
        NSLog(@"received invalid message");
    }
    //NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //Question *recQuestion = [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
}

@end
