//
//  JoinViewControllerTableViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/17/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "JoinViewControllerTableViewController.h"


@interface JoinViewControllerTableViewController ()

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
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _sessionList = [[NSMutableArray alloc] init];
    
    MCPeerID *me = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@%d",_userName,arc4random_uniform(999)]]; //TODO: change this!
    
    // start browsing for open sessions to join
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:me serviceType:@"mesh-vote"];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
}

- (void)dealloc
{
    NSLog(@"dealloc join");
    [_browser stopBrowsingForPeers];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barTintColor = nil;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _sessionList.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;

    if(indexPath.row < _sessionList.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"sessionNameCell" forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"sessionNameCellProgress" forIndexPath:indexPath];
    }
    
    if(cell == nil) {
        NSLog(@"nil sessionNameCell");
    }
    
    if(indexPath.row < _sessionList.count)
    {
        cell.textLabel.text = [_sessionList objectAtIndex:indexPath.row];
        cell.userInteractionEnabled = YES;
    }
    else //animated progress circle thing at end of table
    {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.contentView.backgroundColor=[UIColor whiteColor];
        cell.userInteractionEnabled = NO;

        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width); //hide seperator
        spinner.alpha = 0.7;
        [cell.contentView addSubview:spinner];
        spinner.tag = 123;
        CGRect _frame = [spinner frame];
        _frame.origin.y = 10;
        _frame.origin.x= 160-(_frame.size.width/2);
        spinner.frame = _frame;
        [spinner startAnimating];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue, id:%@", segue.identifier);
    if([segue.identifier isEqualToString:@"selectedSessionSegue"])
    {
        
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];

        
        ConnectingViewController *controller = (ConnectingViewController *)segue.destinationViewController;
        controller.sessionName = [_sessionList objectAtIndex:clickedButtonPath.row];
        controller.userName = _userName;
    }
    
}




//
//  MCNearbyServiceBrowserDelegate
//

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    
    NSString* n = [info objectForKey:@"name"];
    NSLog(@"FOUND PEER: %@", n);
    
    [_sessionList addObject:n];
    [self.tableView reloadData];
    
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"LOST PEER!! IN JOINVIEW: %@", peerID.displayName);
    NSUInteger index = [_sessionList indexOfObject:peerID.displayName];
    if(index != NSNotFound) {
        [_sessionList removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"error starting browser");
}

@end
