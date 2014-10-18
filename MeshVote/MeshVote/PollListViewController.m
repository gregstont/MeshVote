//
//  PollListViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/3/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "PollListViewController.h"
#import "QuestionSet.h"
#import "QuestionViewControllerTableViewController.h"
#import "CreatePollViewController.h"
#import "BigMCSession.h"

@interface PollListViewController ()

@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;
//@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;
@property (nonatomic, strong) BigMCSession* bigSession;


@property (nonatomic, strong) NSMutableDictionary *peerList;

@property (nonatomic, strong) UILabel *connectedPeersLabel;

@property (nonatomic, strong) NSMutableArray *pollSet; //the root array of QuestionSet

//@property (nonatomic) int selectedPollNumber;

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
    
    /*
     NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_pollSet];
     NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"pollset.dat"]];
     */
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"pollset.dat"]];
    //NSData* pollData = [NSData dataWithContentsOfFile:databasePath];
    
    _pollSet = [NSKeyedUnarchiver unarchiveObjectWithFile:databasePath];
    
    if(_pollSet == nil)
        _pollSet = [[NSMutableArray alloc] init];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    

    /*
     
    ///temp for testing onlee
    
    QuestionSet *tt = [[QuestionSet alloc] init];
    tt.name = @"Quiz 1";
    tt.isQuiz = NO;
    tt.showResults = YES;
    tt.shareScores = YES;
    
    Question *tempQuestion1 = [[Question alloc] init];
    [tempQuestion1 setQuestionText:@"Why is the sky blue?"];
    [tempQuestion1 addAnswer:@"science"];
    [tempQuestion1 addAnswer:@"flowers"];
    [tempQuestion1 addAnswer:@"purple"];
    [tempQuestion1 addAnswer:@"stripes"];
    [tempQuestion1 setCorrectAnswer:2];
    [tempQuestion1 setTimeLimit:10];
    [tempQuestion1 setQuestionNumber:1];
    
    
    Question *tempQuestion2 = [[Question alloc] init];
    [tempQuestion2 setQuestionText:@"Why is UT better than A&M?"];
    [tempQuestion2 addAnswer:@"grapefruit"];
    [tempQuestion2 addAnswer:@"tangerine"];
    [tempQuestion2 addAnswer:@"orange"];
    [tempQuestion2 addAnswer:@"peanut"];
    [tempQuestion2 addAnswer:@"banana pie"];
    [tempQuestion2 setCorrectAnswer:1];
    [tempQuestion2 setTimeLimit:10];
    [tempQuestion2 setQuestionNumber:2];
    
    
    [tt addQuestion:tempQuestion1];
    [tt addQuestion:tempQuestion2];
    
    [_pollSet addObject:tt];*/
    
    /////
    _peerList = [[NSMutableDictionary alloc] init];
    
    //create my (host) peerID
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:self.userName];
    //_session = [[MCSession alloc] initWithPeer:me];
    //_session.delegate = self;
    
    _bigSession = [[BigMCSession alloc] initWithPeer:me];
    _bigSession.delegate = self;
    
    
    //advertise on the main channel our new session name
    NSDictionary *temp = [[NSDictionary alloc] initWithObjects:@[self.userName] forKeys:@[@"name"]];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:temp serviceType:@"mesh-vote"];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    
    //start browsing for question takers
    NSString* st = [self getServiceTypeFromName:self.userName];
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:st];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
    
    //create "hidden" label above table cells
    _connectedPeersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    _connectedPeersLabel.text = @"0 connected peers";
    _connectedPeersLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0];
    _connectedPeersLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = _connectedPeersLabel;
    [self.tableView setContentInset:UIEdgeInsetsMake(-_connectedPeersLabel.bounds.size.height, 0.0f, 0.0f, 0.0f)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    _returningFromAdd = NO;
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
    //_session.delegate = self;
    _bigSession.delegate = self;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    if(_pollSet.count == 0) {
        
        _createPollHintLabel.alpha = 0.0;
        _createPollHintArrow.alpha = 0.0;
        
        [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ _createPollHintArrow.alpha = 0.15; _createPollHintLabel.alpha = 0.65;}
                         completion:nil];
    }
    else {
        _createPollHintLabel.alpha = 0.0;
        _createPollHintArrow.alpha = 0.0;
    }
    _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
    [_tableView reloadData];
    //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"dealloc");
    [_browser stopBrowsingForPeers];
    [_advertiser stopAdvertisingPeer];
    //[_session disconnect];
    [_bigSession disconnect];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
} //showPollQuestionSegue
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"showPollQuestionSegue"]){
        //NSLog(@"prepareForSegue");
        //UITableViewCell *clickedCell = (UITableViewCell *)[[[sender superview] superview] superview];
        //NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        
        unsigned long selectedIndex;
        if(_returningFromAdd) { // if returing from creating a new poll, we are transfered to that new poll
            _returningFromAdd = NO;
            selectedIndex = _pollSet.count - 1;
        }
        else { //default action, user selected a cell
            selectedIndex = [self.tableView indexPathForSelectedRow].row;
        }
        
        QuestionViewControllerTableViewController *controller = (QuestionViewControllerTableViewController *)segue.destinationViewController;
        controller.questionSet = [_pollSet objectAtIndex:selectedIndex];
        //controller.session = _session;
        controller.bigSession = _bigSession;
        controller.peerList = _peerList;
        controller.pollSet = _pollSet;
    }
    else if([segue.identifier isEqualToString:@"createPollSegue"]){
        //NSLog(@"prepareForSegue");
        CreatePollViewController *controller = (CreatePollViewController *)segue.destinationViewController;
        controller.pollSet = _pollSet;
    }
}



//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FOUND PEER!! in PollListView");
    [_browser invitePeer:peerID toSession:[_bigSession getAvailableSession] withContext:nil timeout:17]; //getSession
    
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LOST PEER!! IN PollListView");
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"error starting browser");
}


//
//  methods for maintaing the list of sessions
//





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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pollListCell"]; //forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        //NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pollListCell"];
    }
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    cell.textLabel.text = ((QuestionSet*)[_pollSet objectAtIndex:indexPath.row]).name;//[_questions objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    //_selectedPollNumber = (int)indexPath.row;
    /*_selectedQuestion = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"showQuestion" sender:self];
    */
    //TODO: this
    
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_pollSet removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[_tableView reloadData];
        [self saveDataToPhone];
    }
    
}

-(void)saveDataToPhone {
    //dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_pollSet];
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"pollset.dat"]];
    [data writeToFile:databasePath atomically:YES];
}





//
//  MCSessionDelegate
//

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSLog(@"peer changed state:");
    
    if(state == MCSessionStateConnected) {
        NSLog(@"  connected!");
        
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
        });
        
        //_questionSet.messageType = MSG_QUESTION_SET;
        //[Message sendMessage:_questionSet toPeers:@[peerID] inSession:_session];
        
    }
    else if(state == MCSessionStateNotConnected) {
        NSLog(@"  NOT connected!");
        [_peerList removeObjectForKey:peerID.displayName];
        NSLog(@"peerList count:%zd", [[_peerList allKeys] count]);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
        });
    }
    else if(state == MCSessionStateConnecting) {
        NSLog(@"  connecting...");
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"recieved data!");
    Message *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSString *messageType = message.messageType;
    //NSLog(@"type:%@", messageType);
    if(message.messageType == MSG_QUESTION_SET_ACK) { //[messageType isEqualToString:@"question-ack"]) {
        NSLog(@" got question-set-ack");
        //TODO: need to verify all peers have acknowledged the question
        
        
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

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSLog(@"recieved invite");
    //invitationHandler([@YES boolValue], _session);
}
@end
