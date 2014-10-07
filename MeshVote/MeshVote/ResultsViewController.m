//
//  ResultsViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/30/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ResultsViewController.h"
#import "RunningAnswerTableViewCell.h"
#import "Colors.h"

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
    _colors = [[Colors alloc] init];
    //_resultsTable.delegate = self;
    [_resultsTable setDataSource:self];
    [_resultsTable setDelegate:self];
    // Do any additional setup after loading the view.
    NSLog(@"count:%lul",(unsigned long)[[_voteHistory allKeys] count]);
    
    if(_questionSet.isQuiz) {
        _peerResults = [[NSMutableDictionary alloc] initWithCapacity:[[_voteHistory allKeys] count]];
        
        //calculate the peer results from the voteHistory
        //iterate over each peer in the history
        for(NSString* key in _voteHistory) {
            NSLog(@"here!");
            
            NSMutableArray* curPeerHistory = [_voteHistory objectForKey:key];
            
            int numberCorrect = 0;
            //iterate over each question
            for(int i = 0; i < [_questionSet getQuestionCount]; ++i) {
                if([_questionSet getQuestionAtIndex:i].correctAnswer == [[curPeerHistory objectAtIndex:i] intValue]) {
                    ++numberCorrect;
                }
            }
            NSLog(@"score..numCorect:%d questcount:%d", numberCorrect, [_questionSet getQuestionCount]);
            double score = ((double)numberCorrect) / [_questionSet getQuestionCount];
            [_peerResults setObject:[NSNumber numberWithDouble:score] forKey:key];
        }
        
        //calculate mean, median, min and max
        NSArray* scores = [[_peerResults allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"doubleValue" ascending:YES]]];
        
        //for testing only!
        //NSArray* scores = @[@0.5, @0.7, @0.9, @0.91];
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
            if(count % 2 == 0) { //even number, so average middle 2
                median = (int)(([[scores objectAtIndex:count/2] doubleValue] + [[scores objectAtIndex:count/2 - 1] doubleValue]) * 50);
            }
            else {
                median = (int)([[scores objectAtIndex:count/2] doubleValue] * 100);
            }
            self.medianLabel.text = [NSString stringWithFormat:@"%d", median];
        }
        
        
        
        for(NSString* key in _peerResults) {
            NSLog(@"name:%@ score:%f", key, [[_peerResults objectForKey:key] doubleValue]);
        }
    }
    else { //poll mode
        NSLog(@"poll mode results");
        /*
        CGRect bounds = [self.resultsTable bounds];
        [self.resultsTable setBounds:CGRectMake(bounds.origin.x,
                                        bounds.origin.y + 30,
                                        bounds.size.width,
                                        bounds.size.height + 30)];
         */
        //self.resultsTable.contentSize// = CGRectMake(0,0,320,480);

        //self.resultsTable.frame = CGRectMake(0,0,320,480);
        //[self.resultsTable setContentInset:UIEdgeInsetsMake(-50,0,0,0)];
        //self.resultsTable.contentOffset = CGPointMake( 0,  100);
        //self.resultsTable.contentSize = CGSizeMake(100, 200);
        //CGPoint _contentOffset = CGPointMake(_resultsTable.contentOffset.x, -100);
        //_resultsTable.contentOffset = _contentOffset;
        //_resultsTable.frame = CGRectOffset(_resultsTable.frame, 100, 200);
        //view.frame = CGRectOffset(view.frame, 5, 10);
    }
    
}
/*
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = self.resultsTable.frame;
    frame.origin.y -= 70.0;
    frame.size.height += 70.0;
    self.resultsTable.frame = frame;
}
 
- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.resultsTable.frame = CGRectMake(70,0,320,300);
}
 */

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
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section == 0) {
        NSLog(@"number of rows in results:%d",[_questionSet getQuestionCount]);
        //return [_questionSet getQuestionCount];
        return [_questionSet getQuestionCount];
    }
    else { //individual results section
        return [_voteHistory count];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    NSString* labelString;
    
    if(section == 0) {
        labelString = @" per question results";
    }
    else if(section == 1) {
        labelString =@" individual peer results";
    }


    [label setText:labelString];
    [label setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [view addSubview:label];
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"]; //forIndexPath:indexPath];
    
    //temp
    //NSArray *tempPercent = @[@"34", @"31", @"23", @"12"];
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }
    //NSLog(@"answer:%@", [_currentQuestion.answerText objectAtIndex:indexPath.row]);
    //cell.textLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    //cell.answerLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLetterLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row + 1];
    
    
    //cell.answerProgress.progressTintColor = [_colors objectAtIndex:indexPath.row];
    //cell.answerProgress.backgroundColor = [_fadedColors objectAtIndex:indexPath.row];
    //[cell.answerProgress.backgroundColor s]
    
    double newPercent = 0.5;
    double alpha = 1.0;
    if(indexPath.section == 0) {
        Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.row];
        int correctCount = [[cur.voteCounts objectAtIndex:cur.correctAnswer] intValue];
        NSLog(@"corC:%d and voteC:%d",correctCount, cur.voteCount);
        if(cur.voteCount == 0)
            newPercent = 0.0;
        else
            newPercent = (correctCount + 0.0) / cur.voteCount;
    }
    else { //personal results
        
        //NSLog(@"name:%@ score:%f", key, [[[_peerResults allKeys] objectAtIndex:indexPath.row] doubleValue]);
        NSString* key = [[_peerResults allKeys] objectAtIndex:indexPath.row];
        newPercent = [[_peerResults objectForKey:key] doubleValue]; //TODO: dont use allkeys here
        cell.answerLabel.text = [key substringToIndex:[key length] - 6];
        cell.answerLabel.hidden = NO;
        
    }

    
    //FOR TESTING ONLY
    //newPercent = ((double)arc4random() / 0x100000000);
    //newPercent = 1.0 - ((indexPath.row + 0.0) / 10);
    //newPercent =
    double red, green;
    if(newPercent < 0.5) {
        red = 1.0 - (newPercent / 4);
        green = newPercent * 2;
    }
    else {
        red = (1 - newPercent) * 2;
        green = 1.0 - ((1 - newPercent) / 4);
    }
    
    
    //
    

    //color fades from red to green indicating how many missed
    //high percentage  will be green and low red
    
    NSLog(@"newPercent:%f and %f", newPercent, (1 - newPercent));
    UIColor *fadedColor = [UIColor colorWithRed:red green:green blue:0.0 alpha:alpha];
    cell.answerProgress.progressTintColor = fadedColor;
    
    [cell.answerProgress setProgress:newPercent animated:YES];
    cell.answerPercentLabel.text = [NSString stringWithFormat:@"%d", (int)(newPercent * 100)];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    cell.answerProgress.transform = transform;
    cell.backgroundColor = [UIColor clearColor];
    
    //cell.answerProgress.progressTintColor
    /*
     cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
     cell.textLabel.text = [_questionSet getQuestionTextAtIndex:(int)indexPath.row];//[_questions objectAtIndex:indexPath.row];
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     */
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRow: %d", (int)indexPath.row);
    //_selectedQuestion = (int)indexPath.row;
    
    //[self performSegueWithIdentifier:@"showQuestion" sender:self];
    
    //TODO: this
    
    
}


- (IBAction)resultsDoneButton:(id)sender {
    NSLog(@"DONE");
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    UINavigationController *temp = (UINavigationController*)self.presentingViewController;
    [temp popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
