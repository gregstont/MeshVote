//
//  QuestionViewControllerTableViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/16/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "QuestionViewControllerTableViewController.h"



@interface QuestionViewControllerTableViewController ()

// index of question clicked, -1 if adding new question
@property (nonatomic) int selectedQuestion;

// label hidden above table indicating how many peers are connected
@property (nonatomic, strong) UILabel *connectedPeersLabel;

// play button on toolbar
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    

    NSLog(@"question viewdidload, userName:%@", self.userName);
    
    
    // create toolbar buttons
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

    
    // create "hidden" label above table cells
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

-(void)reloadTable
{
    
    if([_questionSet getQuestionCount] == 0)
        _play.enabled = NO;
    else
        _play.enabled = YES;

}


-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"question count:%d", [_questionSet getQuestionCount]);

    _bigSession.delegate = self;
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    
    //send out updated question set to peers
    _questionSet.messageType = MSG_QUESTION_SET;
    [Message broadcastMessage:_questionSet inSession:_bigSession];
    
    
    // reset toolbar colors
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.toolbar.barTintColor = nil;
    
    // reload data
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self reloadTable];
}



- (IBAction)playPressed:(UIButton *)sender
{
    NSLog(@"playPressed");
    // TODO: verify evyerbody has the questionSet
    [self performSegueWithIdentifier:@"startPollSegue" sender:self];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//
//  UITableViewDataSource, UITableViewDelegate
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"number of rows:%d",[_questionSet getQuestionCount]);
    return [_questionSet getQuestionCount] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == [_questionSet getQuestionCount]) // show tip cell
    {
        TipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid-tip"];
        
        // Configure the cell...
        if (cell == nil)
        {
            cell = [[TipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid-tip"];
        }
        
        // hide seperator and oher things
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
        
        cell.createQuestionHintLabel.alpha = 0.0;
        cell.createQuestionHintArrow.alpha = 0.0;
        cell.tipTextView.alpha = 0.0;
        cell.tipTextView.hidden = NO;
        
        if(cell.loaded) // loaded flag added to prevent animation bug
        {
            if([_questionSet getQuestionCount] == 0) // show create question hint
            {
                [UIView animateWithDuration:1.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{ cell.createQuestionHintArrow.alpha = 0.15; cell.createQuestionHintLabel.alpha = 0.65;}
                                 completion:nil];
            }
            if([_questionSet getQuestionCount] < 3) // show (and hide) pull down hint
            {
                [UIView animateWithDuration:1.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{  cell.tipTextView.alpha = 0.75;}
                                 completion:^(BOOL finished){
                                     [UIView animateWithDuration:2.0 delay:10.0 options:UIViewAnimationOptionCurveEaseIn
                                                      animations:^{  cell.tipTextView.alpha = 0.0;}
                                                      completion:nil];
                                 }];
            }
        }
        
        cell.loaded = YES;
        return cell;
    }
    else // normal cell
    {
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qcellid"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"qcellid"];
        }
        cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        cell.textLabel.text = [_questionSet getQuestionTextAtIndex:(int)indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    
    _selectedQuestion = (int)indexPath.row;
    
    [self performSegueWithIdentifier:@"showQuestion" sender:self];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) // delete a question
    {
        // remove question from the set
        [_questionSet removeQuestionAtIndex:(int)indexPath.row];
        
        // re-number the remaining questions
        for(int i = (int)indexPath.row; i < [_questionSet getQuestionCount]; ++i) {
            [_questionSet getQuestionAtIndex:i].questionNumber = i + 1;
        }
        
        // reload table
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self reloadTable];

        // save to disk
        [Util savePollDataToPhone:_pollSet];
    }
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
        
        // add peer to peerlist with -1 vote
        [_peerList setObject:[NSNumber numberWithInt:-1] forKey:peerID.displayName];
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            _connectedPeersLabel.text = [NSString stringWithFormat:@"%zd connected peers", [[_peerList allKeys] count]];
        });
        
        // send question set to newly connected peer
        _questionSet.messageType = MSG_QUESTION_SET;
        [Message sendMessage:_questionSet toPeers:@[peerID] inSession:session];
        
    }
    else if(state == MCSessionStateNotConnected)
    {
        NSLog(@"  NOT connected!");
        
        // remove from peerlist
        [_peerList removeObjectForKey:peerID.displayName];
        
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


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    
    if([segue.identifier isEqualToString:@"startPollSegue"])
    {
        RunningPollViewController *controller = (RunningPollViewController *)segue.destinationViewController;
        controller.questionSet = _questionSet;
        controller.bigSession = _bigSession;
        controller.peerList = _peerList;
    }
    else if([segue.identifier isEqualToString:@"addNewQuestionSegue"])
    {
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_ADD_NEW_QUESTION;
        controller.questionSet = _questionSet;
        controller.pollSet = _pollSet;
    }
    else if([segue.identifier isEqualToString:@"showQuestion"])
    {
        EditQuestionViewController *controller = (EditQuestionViewController *)segue.destinationViewController;
        controller.viewMode = VIEWMODE_EDIT_QUESTION;
        controller.questionSet = _questionSet;
        controller.pollSet = _pollSet;
        controller.currentQuestion = [_questionSet getQuestionAtIndex:_selectedQuestion];
    }
}

- (IBAction)addNewQuestion:(id)sender
{
    _selectedQuestion = -1;
}



@end
