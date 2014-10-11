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



@property (nonatomic) int selectedQuestion;
@property (nonatomic, strong) UILabel *connectedPeersLabel;
@property (nonatomic, strong) UIBarButtonItem *play;

@end


@implementation QuestionViewControllerTableViewController

- (id)init {
    self = [super init];
    if(self) {
        NSLog(@"in init question view!");
        
    }
    return self;
}
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSLog(@"in init question view!");
        
    }
    return self;
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    

    NSLog(@"question viewdidload, userName:%@", self.userName);
    
    //_questionSet = [[QuestionSet alloc] init];
    //_peerList = [[NSMutableDictionary alloc] init];
    
    /*
    ////begin temporary debug stuff
    Question *tempQuestion1 = [[Question alloc] init];
    [tempQuestion1 setQuestionText:@"Why is the sky blue?"];
    [tempQuestion1 addAnswer:@"science"];
    [tempQuestion1 addAnswer:@"flowers"];
    [tempQuestion1 addAnswer:@"purple"];
    [tempQuestion1 addAnswer:@"stripes"];
    [tempQuestion1 setCorrectAnswer:2];
    [tempQuestion1 setTimeLimit:5];
    
    
    Question *tempQuestion2 = [[Question alloc] init];
    [tempQuestion2 setQuestionText:@"Why is UT better than A&M?"];
    [tempQuestion2 addAnswer:@"grapefruit"];
    [tempQuestion2 addAnswer:@"tangerine"];
    [tempQuestion2 addAnswer:@"orange"];
    [tempQuestion2 addAnswer:@"peanut"];
    [tempQuestion2 addAnswer:@"banana pie"];
    [tempQuestion2 setCorrectAnswer:1];
    [tempQuestion2 setTimeLimit:5];
    
    
    [_questionSet addQuestion:tempQuestion1];
    [_questionSet addQuestion:tempQuestion2];*/
      /*  [_questionSet addQuestion:tempQuestion2];
        [_questionSet addQuestion:tempQuestion2];
        [_questionSet addQuestion:tempQuestion2];
        [_questionSet addQuestion:tempQuestion2];
        [_questionSet addQuestion:tempQuestion2];
        [_questionSet addQuestion:tempQuestion2];
    [_questionSet addQuestion:tempQuestion2];
    [_questionSet addQuestion:tempQuestion2];
    [_questionSet addQuestion:tempQuestion2];*/
    
    //end temporaru debug stuff

    /*
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
*/
    
    //create toolbar buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:nil];
    _play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPressed:)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:nil];
    forward.enabled = NO;
    rewind.enabled = NO;
    if([_questionSet getQuestionCount] == 0)
        _play.enabled = NO;
    
    NSArray *buttonItems = [NSArray arrayWithObjects:spacer, rewind, spacer, _play, spacer, forward, spacer, nil];
    self.toolbarItems = buttonItems;

    
    //create "hidden" label above table cells
    _connectedPeersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    _connectedPeersLabel.text = @"0 connected peers";
    _connectedPeersLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0];
    _connectedPeersLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = _connectedPeersLabel;
    [self.tableView setContentInset:UIEdgeInsetsMake(-_connectedPeersLabel.bounds.size.height, 0.0f, 0.0f, 0.0f)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

-(void)reloadTable {
    
    //[_tableView reloadData];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        if([_questionSet getQuestionCount] == 0)
            _play.enabled = NO;
        else
            _play.enabled = YES;
        
        _createQuestionHintLabel.alpha = 0.0;
        _createQuestionHintArrow.alpha = 0.0;
        _tipTextView.alpha = 0.0;
        
        if([_questionSet getQuestionCount] == 0) { //show creat question hint
            
            [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ _createQuestionHintArrow.alpha = 0.15; _createQuestionHintLabel.alpha = 0.65;}
                             completion:nil];
        }
        else if([_questionSet getQuestionCount] == 1) { //show (and hide) pull down hint
            
            [UIView animateWithDuration:2.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{  _tipTextView.alpha = 0.65;}
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:2.0 delay:4.0 options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{  _tipTextView.alpha = 0.0;}
                                                  completion:nil];
                             }];
            
        }
    //});
    
}


-(void)viewWillAppear:(BOOL)animated {
    _session.delegate = self;
    
    NSLog(@"question count:%d", [_questionSet getQuestionCount]);
    
    //send out updated question set to peers
    _questionSet.messageType = MSG_QUESTION_SET;
    [Message sendMessage:_questionSet toPeers:[_session connectedPeers] inSession:_session];
    
    
    //[self.navigationController setNavigationBarHidden:NO];
    //[self.navigationController setToolbarHidden:NO];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self reloadTable];
}



- (void)dealloc {
    NSLog(@"dealloc");
    //[_browser stopBrowsingForPeers];
    //[_advertiser stopAdvertisingPeer];
    //[_session disconnect];
}


- (IBAction)playPressed:(UIButton *)sender {
    NSLog(@"playPressed");
    //TODO: verify evyerbody has the questionSet
    [self performSegueWithIdentifier:@"startPollSegue" sender:self];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FOUND PEER!! in QuestionView");
    //[_browser invitePeer:peerID toSession:_session withContext:nil timeout:17];
    
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
    // Return the number of rows in the section.
    NSLog(@"number of rows:" );
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { //delete a question
        [_questionSet removeQuestionAtIndex:(int)indexPath.row];
        for(int i = (int)indexPath.row; i < [_questionSet getQuestionCount]; ++i) { //re-number the remaining questions
            [_questionSet getQuestionAtIndex:i].questionNumber = i + 1;
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView reloadData];
        //[_tableView reloadData];
        [self reloadTable];
    }
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
        
        _questionSet.messageType = MSG_QUESTION_SET;
        [Message sendMessage:_questionSet toPeers:@[peerID] inSession:_session];
        
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
        controller.session = _session;
        controller.questionSet = _questionSet;
        controller.pollSet = _pollSet;
        //NSLog(@"segue isquiz:%d", _questionSet.isQuiz);
        //controller.currentQuestion = [_questionSet getQuestionAtIndex:_selectedQuestion];
    }
    else if([segue.identifier isEqualToString:@"showQuestion"]){
        //NSLog(@"prepareForSegue");
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_EDIT_QUESTION;
        controller.session = _session;
        controller.questionSet = _questionSet;
        controller.pollSet = _pollSet;
        controller.currentQuestion = [_questionSet getQuestionAtIndex:_selectedQuestion];
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
