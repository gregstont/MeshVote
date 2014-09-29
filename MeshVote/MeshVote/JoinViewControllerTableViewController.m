//
//  JoinViewControllerTableViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/17/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "JoinViewControllerTableViewController.h"
#import "ConnectingViewController.h"
#import <UIKit/UITableViewCell.h>
#include <stdlib.h>

@interface JoinViewControllerTableViewController ()

//@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;
//@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;

@property (nonatomic, strong) NSMutableArray* sessionList;

@end

@implementation JoinViewControllerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"in JOIN viewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _sessionList = [[NSMutableArray alloc] init];
    
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@%d",_userName,arc4random_uniform(999)]]; //TODO: change this!
    //_session = [[MCSession alloc] initWithPeer:me securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    // Set ourselves as the MCSessionDelegate
    //_session.delegate = self;
    
    //MCAdvertiserAssistant *myAssist = [[MCAdvertiserAssistant alloc] initWithServiceType:@"MeshVote" discoveryInfo:nil session:mySession];
    //myAssist.delegate = self;
    //[myAssist start];
    
    //start browsing for open sessions to join
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:@"mesh-vote"];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
    
    /*_advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:nil serviceType:@"mesh-vote"];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
     */
    
    NSLog(@"end of JOIN viewDidLoad");
}

- (void)dealloc {
    NSLog(@"dealloc join");
    [_browser stopBrowsingForPeers];
    //[_advertiser stopAdvertisingPeer];
    //[_session disconnect];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}



//
// for advertiser delegate
//



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    return _sessionList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sessionNameCell" forIndexPath:indexPath];
    
    if(cell == nil) {
        NSLog(@"nil sessionNameCell");
    }
    
    cell.textLabel.text = [_sessionList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    NSLog(@"usrname:%@", [_sessionList objectAtIndex:indexPath.row]);
    //_selectedSessionName = [_sessionList objectAtIndex:indexPath.row];
    //NSLog(@"selSesName: %@", _selectedSessionName);
    

    //[_browser stopBrowsingForPeers];
    //TODO: maybe use new peerid?
    //MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:@"luigi2"];
    
    
    /*
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_browser.myPeerID discoveryInfo:nil serviceType:[_sessionList objectAtIndex:indexPath.row]];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
     */
    
    //_selectedQuestion = (int)indexPath.row;
    
    //[self performSegueWithIdentifier:@"showQuestion" sender:self];
    
    //TODO: this
    
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    if([segue.identifier isEqualToString:@"selectedSessionSegue"]){
        //NSLog(@"prepareForSegue:%@", _selectedSessionName);
        
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];

        
        ConnectingViewController *controller = (ConnectingViewController *)segue.destinationViewController;
        controller.sessionName = [_sessionList objectAtIndex:clickedButtonPath.row];
        controller.userName = _userName;
    }
    
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSLog(@"peerDidChangeState");
    if(state == MCSessionStateConnected) {
        
    }
}

// Received data from remote peer
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



//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSString* n = [info objectForKey:@"name"];
    NSLog(@"FOUND PEER: %@", n);
    
    [_sessionList addObject:n];
    [self.tableView reloadData];
    //[_browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
    
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LOST PEER!!");
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"error starting browser");
}

@end
