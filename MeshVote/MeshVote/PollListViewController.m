//
//  PollListViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "PollListViewController.h"



@interface PollListViewController ()

@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;

//the main session containing all peers
@property (nonatomic, strong) BigMCSession* bigSession;

// list of connected peers mapping to current vote index
@property (nonatomic, strong) NSMutableDictionary *peerList;

//label hidden above table indicating how many peers are connected
@property (nonatomic, strong) UILabel *connectedPeersLabel;

//the root array of QuestionSet objects
@property (nonatomic, strong) NSMutableArray *pollSet;


@end

@implementation PollListViewController

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
    
    // load poll data from disk
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"pollset.dat"]];
    
    _pollSet = [NSKeyedUnarchiver unarchiveObjectWithFile:databasePath];
    
    if(_pollSet == nil)
        _pollSet = [[NSMutableArray alloc] init];
    
    _peerList = [[NSMutableDictionary alloc] init];
    

    
    //create the bigSession with myself (the host)
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:self.userName];
    _bigSession = [[BigMCSession alloc] initWithPeer:me];
    _bigSession.delegate = self;
    
    
    //advertise on the main channel our new session name
    NSDictionary *temp = [[NSDictionary alloc] initWithObjects:@[self.userName] forKeys:@[@"name"]];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:temp serviceType:@"mesh-vote"];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    
    //start browsing for question takers
    NSString* st = [Util getServiceTypeFromName:_userName];
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:st];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];

    
    
    //create "hidden" label above table cells
    _connectedPeersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    _connectedPeersLabel.text = @"0 connected peers";
    _connectedPeersLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0];
    _connectedPeersLabel.textAlignment = NSTextAlignmentCenter;
    _tableView.tableHeaderView = _connectedPeersLabel;
    [_tableView setContentInset:UIEdgeInsetsMake(-_connectedPeersLabel.bounds.size.height, 0.0f, 0.0f, 0.0f)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.allowsMultipleSelectionDuringEditing = NO;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //flag for when creating a new poll
    _returningFromAdd = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    _bigSession.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.toolbar.barTintColor = nil;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if(_pollSet.count == 0)
    {
        // pollset empty, show hints
        _createPollHintLabel.alpha = 0.0;
        _createPollHintArrow.alpha = 0.0;
        
        [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ _createPollHintArrow.alpha = 0.15; _createPollHintLabel.alpha = 0.65;}
                         completion:nil];
    }
    else
    {
        // hide hints
        _createPollHintLabel.alpha = 0.0;
        _createPollHintArrow.alpha = 0.0;
    }
    _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"dealloc");
    [_browser stopBrowsingForPeers];
    [_advertiser stopAdvertisingPeer];
    [_bigSession disconnect];
}


#pragma mark - Navigation


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"showPollQuestionSegue"])
    {
        unsigned long selectedIndex;
        if(_returningFromAdd)
        {
            //if this flag was set, we are transfering to newly created poll
            _returningFromAdd = NO;
            selectedIndex = _pollSet.count - 1;
        }
        else
        {
            // default action, user selected a cell
            selectedIndex = [self.tableView indexPathForSelectedRow].row;
        }
        
        QuestionViewControllerTableViewController *controller = (QuestionViewControllerTableViewController *)segue.destinationViewController;
        
        controller.questionSet = [_pollSet objectAtIndex:selectedIndex];
        controller.bigSession = _bigSession;
        controller.peerList = _peerList;
        controller.pollSet = _pollSet;
    }
    else if([segue.identifier isEqualToString:@"createPollSegue"])
    {
        CreatePollViewController *controller = (CreatePollViewController *)segue.destinationViewController;
        controller.pollSet = _pollSet;
    }
}



//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"FOUND PEER!! in PollListView");
    [_browser invitePeer:peerID toSession:[_bigSession getAvailableSession] withContext:nil timeout:17];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"LOST PEER!! IN PollListView");
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"error starting browser");
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
    NSLog(@"number of rows:%lu",(unsigned long)[_pollSet count]);
    return [_pollSet count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pollListCell"];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pollListCell"];
    }
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    cell.textLabel.text = ((QuestionSet*)[_pollSet objectAtIndex:indexPath.row]).name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_pollSet removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self saveDataToPhone];
    }
    
}

// saves poll data to disk
-(void)saveDataToPhone
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_pollSet];
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"pollset.dat"]];
    [data writeToFile:databasePath atomically:YES];
}





//
//  MCSessionDelegate
//

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
    NSLog(@"peer changed state:");
    
    if(state == MCSessionStateConnected)
    {
        NSLog(@"  connected!");
        
        // add peer to peerList, initial vote to -1
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
        });
    }
    else if(state == MCSessionStateNotConnected)
    {
        NSLog(@"  NOT connected!");
        
        // remove peer from peerList
        [_peerList removeObjectForKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
        });
    }
    else if(state == MCSessionStateConnecting)
    {
        NSLog(@"  connecting...");
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"recieved data!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(message.messageType == MSG_QUESTION_SET_ACK)
    {
        NSLog(@" got question-set-ack");
        //TODO: need to verify all peers have acked the QuestionSet
        
        
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





//
//  MCNearbyServiceAdvertiser
//

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"recieved invite - shouldn't be here");
}
@end
