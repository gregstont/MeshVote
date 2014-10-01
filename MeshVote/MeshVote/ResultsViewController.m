//
//  ResultsViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/30/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "ResultsViewController.h"
#import "RunningAnswerTableViewCell.h"

@interface ResultsViewController ()

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
    //_resultsTable.delegate = self;
    [_resultsTable setDataSource:self];
    [_resultsTable setDelegate:self];
    // Do any additional setup after loading the view.
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
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"number of rows in results:%d",[_questionSet getQuestionCount]);
    //return [_questionSet getQuestionCount];
    return [_questionSet getQuestionCount];
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
    Question* cur = [_questionSet getQuestionAtIndex:(int)indexPath.row];
    int correctCount = [[cur.voteCounts objectAtIndex:cur.correctAnswer] intValue];
    NSLog(@"corC:%d and voteC:%d",correctCount, cur.voteCount);
    if(cur.voteCount == 0)
        newPercent = 0.0;
    else
        newPercent = (correctCount + 0.0) / cur.voteCount;
    
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
    UIColor *fadedColor = [UIColor colorWithRed:red green:green blue:0.0 alpha:1.0];
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
