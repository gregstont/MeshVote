//
//  ResultsPollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/6/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ResultsPollViewController.h"


@interface ResultsPollViewController ()

@property (nonatomic, strong) Colors* colors;

@end

@implementation ResultsPollViewController

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
    
    //bg gradient
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    // add special done button
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" Done" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
    
    _colors = [[Colors alloc] init];
    
    _resultsTable.delegate = self;
    _resultsTable.dataSource = self;
    
    //send out results to peers
    if(_questionSet.showResults)
    {
        // gather vote count for each question
        NSMutableArray* votesArray = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount]];
        for(Question* runner in _questionSet.questions)
        {
            [votesArray addObject:[runner.voteCounts copy]];
        }
        NSArray* sendArray = [votesArray copy];
        
        // construct message containing results
        Results* results = [[Results alloc] init];
        results.messageType = MSG_POLL_RESULTS;
        results.votes = sendArray;
        [Message broadcastMessage:results inSession:_bigSession];
    }
    else // dont show results for peers
    {
        NSLog(@"sending done message");
        Message* doneMessage = [[Message alloc] init];
        doneMessage.messageType = MSG_ACTION;
        doneMessage.actionType = AT_DONE;
        [Message broadcastMessage:doneMessage inSession:_bigSession];
    }
    
}

-(void)goBack
{
    [self.navigationController popTwoViewControllersAnimated:YES];
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
 *///
//  UITableViewDataSource, UITableViewDelegate
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_questionSet getQuestionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return [_questionSet getAnswerCountAtIndex:(int)section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    
    NSString* text = [_questionSet getQuestionTextAtIndex:(int)section];
    
    // each cell will be sized to fit the number of lines of text
    CGSize maxSize = CGSizeMake(260, 410);
    CGRect labrect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:Nil];
    
    label.text = text;
    label.numberOfLines = 0;
    label.frame = CGRectMake(10, 17, 260, labrect.size.height + 8);
    
    [view addSubview:label];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // calculate the height based on the amount of text we are going to display
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    NSString *text = [_questionSet getQuestionTextAtIndex:(int)section];

    CGSize maxSize = CGSizeMake(260, 410);
    CGRect labrect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:Nil];
    
    return labrect.size.height + 25;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"];
    
    if (cell == nil)
    {
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }

    cell.answerLetterLabel.text = [_colors getLetterAtIndex:indexPath.row];

    
    // calculate the percent to show
    Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.section];
    int votes = [[cur.voteCounts objectAtIndex:indexPath.row] intValue];
    
    double newPercent = 0.0;
    if(cur.voteCount == 0)
        newPercent = 0.0;
    else
        newPercent = (votes + 0.0) / cur.voteCount;
    
    // the label will show the answer
    cell.answerLabel.text = [cur.answerText objectAtIndex:indexPath.row];
    cell.answerLabel.hidden = NO;

    
    // update the progress bar
    cell.answerProgress.progressTintColor = [Colors getFadedColorFromPercent:newPercent + 0.15 withAlpha:0.9];
    [cell.answerProgress setProgress:newPercent animated:!cell.doneLoading];
    cell.answerPercentLabel.text = [NSString stringWithFormat:@"%d", (int)(newPercent * 100)];
    
    // strecth the progress bar
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    cell.answerProgress.transform = transform;
    cell.backgroundColor = [UIColor clearColor];
    
    
    cell.doneLoading = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRow: %d", (int)indexPath.row);

}


- (IBAction)resultsDoneButton:(id)sender {
    NSLog(@"DONE");
    UINavigationController *temp = (UINavigationController*)self.presentingViewController;
    [temp popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end