//
//  ResultsPollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/6/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ResultsPollViewController.h"
#import "Colors.h"
#import "RunningAnswerTableViewCell.h"
#import "Results.h"


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
    
    _colors = [[Colors alloc] init];
    
    [_resultsTable setDataSource:self];
    [_resultsTable setDelegate:self];
    
    //send out results to peers
    if(_questionSet.showResults) {
        NSMutableArray* votesArray = [[NSMutableArray alloc] initWithCapacity:[_questionSet getQuestionCount]];
        for(Question* runner in _questionSet.questions) {
            [votesArray addObject:[runner.voteCounts copy]];
        }
        NSArray* sendArray = [votesArray copy];
        
        Results* results = [[Results alloc] init];
        results.messageType = MSG_POLL_RESULTS;
        results.votes = sendArray;
        [Message sendMessage:results toPeers:[_session connectedPeers] inSession:_session];
    }
    
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
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [_questionSet getQuestionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.

    return [_questionSet getAnswerCountAtIndex:(int)section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    NSString* labelString;
    
    labelString = [NSString stringWithFormat:@"Question %d", [_questionSet getQuestionAtIndex:(int)section].questionNumber];
    
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
    cell.answerLetterLabel.text = [_colors getLetterAtIndex:indexPath.row];

    
    
    //cell.answerProgress.progressTintColor = [_colors objectAtIndex:indexPath.row];
    //cell.answerProgress.backgroundColor = [_fadedColors objectAtIndex:indexPath.row];
    //[cell.answerProgress.backgroundColor s]
    
    double newPercent = 0.5;
    double alpha = 1.0;

    Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.section];
    int votes = [[cur.voteCounts objectAtIndex:indexPath.row] intValue];
    if(cur.voteCount == 0)
        newPercent = 0.0;
    else
        newPercent = (votes + 0.0) / cur.voteCount;
    cell.answerLabel.text = [cur.answerText objectAtIndex:indexPath.row];
    cell.answerLabel.hidden = NO;
    alpha = 0.5;

    
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
    
    //NSLog(@"newPercent:%f and %f", newPercent, (1 - newPercent));
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