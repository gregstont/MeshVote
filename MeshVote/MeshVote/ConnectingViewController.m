//
//  ConnectingViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/27/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ConnectingViewController.h"

@interface ConnectingViewController ()

@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;


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
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:@"luigi"];
    
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

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSLog(@"recieved invite");
    invitationHandler([@YES boolValue], _session);
}



//
//  MCSession
//

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"recieved data!");
    
    //NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Question *recQuestion = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"  message:%@", recQuestion.questionText);
    
    
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
        });
        //_statusLabel.text = @"connected!";
        //[_statusLabel setText:@"connected!"];
        //[_statusLabel reloadInputViews];
    }
}

@end
