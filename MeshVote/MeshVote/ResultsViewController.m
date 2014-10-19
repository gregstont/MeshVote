//
//  ResultsViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/30/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@property (nonatomic, strong) NSMutableDictionary* peerResults;

@property (nonatomic, strong) Colors* colors;

@end

@implementation ResultsViewController

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
    NSLog(@"in show results");
    
    //bg gradient
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    // add special done button that pops twice
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" Done" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
    
    _resultsTable.delegate = self;
    _resultsTable.dataSource = self;
    
    _colors = [[Colors alloc] init];
    _peerResults = [[NSMutableDictionary alloc] initWithCapacity:[[_voteHistory allKeys] count]];
    
    [self calculatePeerResults];
    
    [self updateStatsLabels];
    
    
    if(_questionSet.showResults) // send out results to peers
    {
        NSMutableArray* votesArray = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount]];
        for(Question* runner in _questionSet.questions)
        {
            [votesArray addObject:[runner.voteCounts copy]];
        }
        NSArray* sendArray = [votesArray copy];
        
        // construct the "Message"
        Results* results = [[Results alloc] init];
        results.messageType = MSG_POLL_RESULTS;
        results.votes = sendArray;
        results.stats = @[_meanLabel.text, _minLabel.text, _maxLabel.text, _medianLabel.text];
        [Message broadcastMessage:results inSession:_bigSession];
    }
    else // dont show results for peers
    {
        // broadcast done message
        Message* doneMessage = [[Message alloc] init];
        doneMessage.messageType = MSG_ACTION;
        doneMessage.actionType = AT_DONE;
        [Message broadcastMessage:doneMessage inSession:_bigSession];
    }

    
}

// calculate the peer results (ie percentage correct) from the voteHistory
// iterate over each peer in the history
-(void)calculatePeerResults
{
    for(NSString* key in _voteHistory)
    {
        NSMutableArray* curPeerHistory = [_voteHistory objectForKey:key];
        
        int numberCorrect = 0;
        //iterate over each question
        for(int i = 0; i < [_questionSet getQuestionCount]; ++i)
        {
            if([_questionSet getQuestionAtIndex:i].correctAnswer == [[curPeerHistory objectAtIndex:i] intValue])
            {
                ++numberCorrect;
            }
        }
        
        double score = ((double)numberCorrect) / [_questionSet getQuestionCount];
        [_peerResults setObject:[NSNumber numberWithDouble:score] forKey:key];
    }
}

-(void)updateStatsLabels
{
    if(_stats) // we have recieved the stats fromt he host
    {
        self.meanLabel.text = [_stats objectAtIndex:0];
        self.minLabel.text = [_stats objectAtIndex:1];
        self.maxLabel.text = [_stats objectAtIndex:2];
        self.medianLabel.text = [_stats objectAtIndex:3];
    }
    else //we are the host, we need to calculate
    {
        // calculate mean, median, min and max
        NSArray* scores = [[_peerResults allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"doubleValue" ascending:YES]]];
        
        int count = (int)[scores count];
        if(count > 0) {
            double sum = 0.0;
            for(NSNumber* num in scores) {
                sum += [num doubleValue];
            }
            self.meanLabel.text = [NSString stringWithFormat:@"%d", (int)((sum / count) * 100)];
            self.minLabel.text = [NSString stringWithFormat:@"%d", (int)([[scores objectAtIndex:0] doubleValue] * 100)];
            self.maxLabel.text = [NSString stringWithFormat:@"%d", (int)([[scores objectAtIndex:count - 1] doubleValue] * 100)];
            
            int median = 0;
            if(count % 2 == 0) // even number, so average middle 2
            {
                median = (int)(([[scores objectAtIndex:count/2] doubleValue] + [[scores objectAtIndex:count/2 - 1] doubleValue]) * 50);
            }
            else
            {
                median = (int)([[scores objectAtIndex:count/2] doubleValue] * 100);
            }
            self.medianLabel.text = [NSString stringWithFormat:@"%d", median];
        }
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
*/

//
//  UITableViewDataSource, UITableViewDelegate
//

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0) // individual results section
    {
        if(_voteHistory)
            return [_voteHistory count];
        else
            return 1;
    }
    else // per question
    {
        return [_questionSet getQuestionCount];

    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    NSString* labelString;
    
    if(section == 0) {
        if(_voteHistory) // ie host
            labelString = @" individual peer results";
        else
            labelString = @" your score";
    }
    else if(section == 1) {
        labelString = @" average peer score per question";
    }


    [label setText:labelString];
    [label setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [view addSubview:label];
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"];
    
    if (cell == nil)
    {
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }

    cell.answerLetterLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row + 1];
    
    if(_voteHistory == nil && indexPath.section == 1) // show peer results, so highlight wrong answers
    {
        if(!cell.doneLoading)
        {
            cell.gradeImage.alpha = 0;
            [UIView animateWithDuration:0.8 delay:indexPath.row/4.0 + 0.2 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{  cell.gradeImage.alpha = 0.6;}
                             completion:nil];
        }
        cell.doneLoading = YES;
        
        // show check mark if this question was answered correctly
        Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.row];
        if(cur.givenAnswer == cur.correctAnswer)
          [cell.gradeImage setImage:[UIImage imageNamed:@"check_icon128x128.png"]];
    }
    else
        cell.gradeImage.alpha = 0.0;
    
    // calculate the percentage to show
    double newPercent = 0.0;
    if(indexPath.section == 0) //individual peer results
    {
        if(_voteHistory) // we are host
        {
            NSString* key = [[_peerResults allKeys] objectAtIndex:indexPath.row];
            newPercent = [[_peerResults objectForKey:key] doubleValue];
            cell.answerLabel.text = [key substringToIndex:[key length] - 6];
            cell.answerLabel.hidden = NO;
        }
        else // personal peer results
        {
            int correctCount = 0;
            for(Question* cur in _questionSet.questions) {
                NSLog(@"given answer:%d",cur.givenAnswer);
                if(cur.givenAnswer == cur.correctAnswer)
                    ++correctCount;
            }
            newPercent = (correctCount + 0.0) / [_questionSet getQuestionCount];
            cell.answerLetterLabel.text = @"";
        }

    }
    else // per question results
    {
        Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.row];
        if(cur.correctAnswer == -1) // no correct answer selected
            newPercent = 1.0;
        else if(cur.voteCount == 0)
            newPercent = 0.0;
        else
            newPercent = ([[cur.voteCounts objectAtIndex:cur.correctAnswer] intValue] + 0.0) / cur.voteCount; //t his is the percent correct
    }

    // set color, low percentage red, high green
    cell.answerProgress.progressTintColor = [Colors getFadedColorFromPercent:newPercent withAlpha:1.0];
    
    // update the progress
    [cell.answerProgress setProgress:newPercent animated:YES];
    cell.answerPercentLabel.text = [NSString stringWithFormat:@"%d", (int)(newPercent * 100)];
    
    // stretch the cell
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    cell.answerProgress.transform = transform;
    
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
}


- (IBAction)resultsDoneButton:(id)sender
{
    NSLog(@"DONE");

    UINavigationController *temp = (UINavigationController*)self.presentingViewController;
    [temp popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
