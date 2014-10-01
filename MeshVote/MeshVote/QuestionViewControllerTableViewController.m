//
//  QuestionViewControllerTableViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "QuestionViewControllerTableViewController.h"
#import "QuestionSet.h"
#import "Question.h"
#import "RunningPollViewController.h"

//#import <malloc/malloc.h> //TODO: remove on release

@interface QuestionViewControllerTableViewController ()

@property (nonatomic, strong) QuestionSet *questionSet; //change this later
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceAdvertiser *advertiser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;

@property (nonatomic, strong) NSMutableDictionary *peerList;

@property (nonatomic) int selectedQuestion;
@property (nonatomic, strong) UILabel *connectedPeersLabel;

@end


@implementation QuestionViewControllerTableViewController

- (id)init {
    self = [super init];
    if(self) {
        NSLog(@"in init question view!");
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSLog(@"in init question view!");
        //_peerList = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    

    NSLog(@"question viewdidload, userName:%@", self.userName);
    
    _questionSet = [[QuestionSet alloc] init];
    _peerList = [[NSMutableDictionary alloc] init];
    
    
    ////begin temporary debug stuff
    Question *tempQuestion1 = [[Question alloc] init];
    [tempQuestion1 setQuestionText:@"Why is the sky blue?"];
    [tempQuestion1 addAnswer:@"science"];
    [tempQuestion1 addAnswer:@"flowers"];
    [tempQuestion1 addAnswer:@"purple"];
    [tempQuestion1 addAnswer:@"stripes"];
    [tempQuestion1 setTimeLimit:15];
    
    
    Question *tempQuestion2 = [[Question alloc] init];
    [tempQuestion2 setQuestionText:@"Why is UT better than A&M?"];
    [tempQuestion2 addAnswer:@"grapefruit"];
    [tempQuestion2 addAnswer:@"tangerine"];
    [tempQuestion2 addAnswer:@"orange"];
    [tempQuestion2 addAnswer:@"peanut"];
    [tempQuestion2 addAnswer:@"banana pie"];
    [tempQuestion2 setTimeLimit:15];
    
    [_questionSet addQuestion:tempQuestion1];
    [_questionSet addQuestion:tempQuestion2];
    //end temporaru debug stuff

    
    //create my (host) peerID
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:@"mario"];
    _session = [[MCSession alloc] initWithPeer:me];
    _session.delegate = self;
    
    
    //advertise on the main channel our new session name
    NSDictionary *temp = [[NSDictionary alloc] initWithObjects:@[self.userName] forKeys:@[@"name"]];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:me discoveryInfo:temp serviceType:@"mesh-vote"];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    
    //start browsing for question takers
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:self.userName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];

    
    //create toolbar buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:nil];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPressed:)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:nil];
    forward.enabled = NO;
    rewind.enabled = NO;
    
    NSArray *buttonItems = [NSArray arrayWithObjects:spacer, rewind, spacer, play, spacer, forward, spacer, nil];
    self.toolbarItems = buttonItems;

    
    //create "hidden" label above table cells
    _connectedPeersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    _connectedPeersLabel.text = @"0 connected peers";
    _connectedPeersLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0];
    _connectedPeersLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = _connectedPeersLabel;
    [self.tableView setContentInset:UIEdgeInsetsMake(-_connectedPeersLabel.bounds.size.height, 0.0f, 0.0f, 0.0f)];

}


-(void)viewWillAppear:(BOOL)animated {
    _session.delegate = self;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}



- (void)dealloc {
    NSLog(@"dealloc");
    [_browser stopBrowsingForPeers];
    [_advertiser stopAdvertisingPeer];
    [_session disconnect];
}


- (IBAction)playPressed:(UIButton *)sender {
    NSLog(@"playPressed");
    [self performSegueWithIdentifier:@"startPollSegue" sender:self];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//
//  EditQuestionViewControllerDelegate
//

-(NSString*)getQuestionTextAtIndex:(int)index {
    return [_questionSet getQuestionTextAtIndex:index];
}

-(NSString*)getAnswerTextAtIndex:(int)index andAnswerIndex:(int)ansIndex {
    //NSLog(@"getting answer text");
    return [_questionSet getAnswerTextAtIndex:index andAnswerIndex:ansIndex];
}

-(int)getAnswerCountAtIndex:(int)index {
    return [_questionSet getAnswerCountAtIndex:index];
}

-(int)getSelectedQuestion {
    return _selectedQuestion;
}

-(Question*)getQuestionAtIndex:(int)index {
    return  [_questionSet getQuestionAtIndex:index];
}

-(void)addQuestionToSet:(Question*)question {
    [_questionSet addQuestion:question];
}



//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FOUND PEER!!");
    [_browser invitePeer:peerID toSession:_session withContext:nil timeout:17];
    
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LOST PEER!! IN QUESTIONVIEW");
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
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
    NSLog(@"number of rows:%d",[_questionSet getQuestionCount]);
    return [_questionSet getQuestionCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qcellid"]; //forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        //NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"qcellid"];
    }
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    cell.textLabel.text = [_questionSet getQuestionTextAtIndex:(int)indexPath.row];//[_questions objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    _selectedQuestion = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"showQuestion" sender:self];
    
    //TODO: this
    

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
    NSString *messageType = message.messageType;
    NSLog(@"type:%@", messageType);
    if([messageType isEqualToString:@"question-ack"]) {
        
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
    if([segue.identifier isEqualToString:@"startPollSegue"]){
        //NSLog(@"prepareForSegue");
        RunningPollViewController *controller = (RunningPollViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        controller.session = _session;
        controller.peerList = _peerList;
    }
    else if([segue.identifier isEqualToString:@"addNewQuestionSegue"]){
        //NSLog(@"prepareForSegue");
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_ADD_NEW_QUESTION;
    }
    else if([segue.identifier isEqualToString:@"showQuestion"]){
        //NSLog(@"prepareForSegue");
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_EDIT_QUESTION;
    }
    //showQuestion
    
    //addNewQuestionSegue
}

- (IBAction)addNewQuestion:(id)sender {
    _selectedQuestion = -1;
}


//
//  MCNearbyServiceAdvertiser
//

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSLog(@"recieved invite");
    //invitationHandler([@YES boolValue], _session);
}
@end
