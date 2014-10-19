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
#import "BackgroundLayer.h"
#include <stdlib.h>

@interface ConnectingViewController ()

@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;

// reference to the poll host - this is where we send our responses
@property (nonatomic, strong) MCPeerID* host;

// this is the set of questions received from the host
@property (nonatomic, strong) QuestionSet* questionSet;

// the question number we are going to begin at - also received from host
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
    
    // add bg gradient
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    

    // setup session
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:[Util getUniqueName:_userName]];
    _session = [[MCSession alloc] initWithPeer:me securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    _session.delegate = self;

    // start advertising the chosen session name so we can be invited by the host
    NSString* serviceType = [Util getServiceTypeFromName:_sessionName];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:nil serviceType:serviceType];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    _currentQuestionNumber = 0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    _session.delegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0];
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:(190/255.0)  green:(190/255.0)  blue:(190/255.0)  alpha:1.0];
}

- (void)dealloc
{
    NSLog(@"dealloc connecting");
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"startTakingPollSegue"])
    {
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_ASK_QUESTION;
        controller.questionSet = _questionSet;
        controller.currentQuestionNumber = _currentQuestionNumber;
        controller.session = _session;
        controller.host = _host;
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"recieved invite");
    _host = peerID;
    invitationHandler([@YES boolValue], _session);
}



//
//  MCSession
//

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"recieved data in connecting view!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if(message.messageType == MSG_QUESTION_SET)
    {
        NSLog(@"  got the question set");
        
        _questionSet = (QuestionSet*)message;
        
        
        //send question-ack to host
        [Message sendMessageType:MSG_QUESTION_SET_ACK toPeers:@[_host] inSession:_session];

    }
    
    else if(message.messageType == MSG_ANSWER_ACK)
    {
        NSLog(@"  answer-ack");
    }
    else if(message.messageType == MSG_ACTION)
    {
        NSLog(@"  action qnum:%d",message.questionNumber);
        if(message.actionType == AT_REWIND) {
            
        }
        else if(message.actionType == AT_PLAY) {
            _currentQuestionNumber = message.questionNumber;
            dispatch_async(dispatch_get_main_queue(), ^(void){
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
    else
    {
        NSLog(@"!!!! received invalid message467");
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
    if(state == MCSessionStateConnected)
    {
        NSLog(@"connected1");
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {

            [_statusLabel setText:@"connected!"];
            
            _statusLabelBottom.alpha = 0.0;
            _checkImage.alpha = 0.0;
            _statusLabelBottom.hidden = NO;
            _checkImage.hidden = NO;
            _connectingActivityIndicator.hidden = YES;
            
            [UIView animateWithDuration:1.0 delay:0.3 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ _statusLabelBottom.alpha = 1;}
                             completion:nil];
            
            [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ _checkImage.alpha = 0.6;}
                             completion:nil];
        });

    }
    else if(state == MCSessionStateNotConnected)
    {
        if([peerID isEqual:_host])
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
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
