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

//#import <malloc/malloc.h> //TODO: remove on release

@interface QuestionViewControllerTableViewController ()

@property (nonatomic, strong) QuestionSet *questionSet; //change this later
@property (readonly, NS_NONATOMIC_IOSONLY) MCNearbyServiceBrowser *browser;
@property (readonly, NS_NONATOMIC_IOSONLY) MCSession *session;

@property (nonatomic) int selectedQuestion;

@end


@implementation QuestionViewControllerTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSLog(@"in init question view!");
        
        
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
    
    /*_questions = [[NSMutableArray alloc] init];
    
    [_questions addObject:@"first!"];
    [_questions addObject:@"second!"];
    [_questions addObject:@"third!"];*/
    
    
    NSLog(@"question viewdidload");
    
    _questionSet = [[QuestionSet alloc] init];
    
    Question *tempQuestion1 = [[Question alloc] init];
    [tempQuestion1 setQuestionText:@"Why is the sky blue?"];
    [tempQuestion1 addAnswer:@"science"];
    [tempQuestion1 addAnswer:@"flowers"];
    [tempQuestion1 addAnswer:@"purple"];
    [tempQuestion1 setTimeLimit:60];
    
    
    Question *tempQuestion2 = [[Question alloc] init];
    [tempQuestion2 setQuestionText:@"Why is UT better than A&M?"];
    [tempQuestion2 addAnswer:@"grapefruit"];
    [tempQuestion2 addAnswer:@"tangerine"];
    [tempQuestion2 addAnswer:@"orange"];
    [tempQuestion2 setTimeLimit:60];
    
    [_questionSet addQuestion:tempQuestion1];
    [_questionSet addQuestion:tempQuestion2];

    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:@"mario"];
    //MCSession *mySession = [[MCSession alloc] initWithPeer:me securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    _session = [[MCSession alloc] initWithPeer:me];
    _session.delegate = self;
    
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:@"mesh-vote"];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    /*
    EditQuestionViewController *secondViewController = [[EditQuestionViewController alloc] init];
    secondViewController.delegate = self;
    [[self navigationController] pushViewController:secondViewController animated:YES];
    */
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}



- (void)dealloc {
    NSLog(@"dealloc");
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
    NSLog(@"getting answer text");
    return [_questionSet getAnswerTextAtIndex:index andAnswerIndex:ansIndex];
}

-(int)getAnswerCountAtIndex:(int)index {
    return [_questionSet getAnswerCountAtIndex:index];
}

-(int)getSelectedQuestion {
    return _selectedQuestion;
}



//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FOUND PEER!!");
    [_browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
    
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
    cell.textLabel.text = [_questionSet getQuestionTextAtIndex:(int)indexPath.row];//[_questions objectAtIndex:indexPath.row];
    
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
        //NSString *helloString = @"Hello connected!";
        //NSData *helloMessage = [helloString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *testQuestion = [NSKeyedArchiver archivedDataWithRootObject:[_questionSet getQuestionAtIndex:0]];
        NSError *error;
        
        //NSLog(@"size of myObject: %zd", malloc_size((__bridge const void *)(testQuestion)));
        
        NSMutableArray *peers = [[NSMutableArray alloc] init];
        [peers addObject:peerID];
        [_session sendData:testQuestion toPeers:peers withMode:MCSessionSendDataReliable error:&error];
        
        if(error) {
            NSLog(@"Error sending data");
        }
    }
    
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
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

- (IBAction)addNewQuestion:(id)sender {
    _selectedQuestion = -1;
}
@end
