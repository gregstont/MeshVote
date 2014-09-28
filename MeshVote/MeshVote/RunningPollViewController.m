//
//  RunningPollViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/28/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "RunningPollViewController.h"
#import "BackgroundLayer.h"
#import "Question.h"
#import "RunningAnswerTableViewCell.h"

@interface RunningPollViewController ()

@property (nonatomic, strong) Question* currentQuestion;
@property (nonatomic) int currentQuestionNumber; //starts at 0

@property (nonatomic, strong) NSArray* letters;
@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic) int timeRemaining;

@end

@implementation RunningPollViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSString*)timeAsString:(int)time {
    return [NSString stringWithFormat:@"%d:%02d",time / 60, time % 60];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //TODO: make this global or typedef or something
    _colors = [[NSMutableArray alloc] init];
    [_colors addObject:[[UIColor alloc] initWithRed:0.258 green:0.756 blue:0.631 alpha:1.0]]; //green
    [_colors addObject:[[UIColor alloc] initWithRed:0 green:0.592 blue:0.929 alpha:1.0]]; //blue
    [_colors addObject:[[UIColor alloc] initWithRed:0.905 green:0.713 blue:0.231 alpha:1.0]]; //yellow
    [_colors addObject:[[UIColor alloc] initWithRed:1 green:0.278 blue:0.309 alpha:1.0]]; //red
    
    _letters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
    
    
    [_answerTable setDataSource:self];
    [_answerTable setDelegate:self];
    
    CAGradientLayer *bgLayer = [BackgroundLayer lightBlueGradient]; //actually grey
    //CAGradientLayer *bgLayer2 = [BackgroundLayer testGradient]; //test grey
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewindPressed:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPressed:)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardPressed:)];
    forward.enabled = NO;
    
    //[_currentQuestion.timeLimit ;
    
    
    
    
    NSArray *buttonItems = [NSArray arrayWithObjects:spacer, rewind, spacer, play, spacer, forward, spacer, nil];
    self.toolbarItems = buttonItems;

    
    _currentQuestionNumber = 0;
    _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
    
    _timeRemaining = _currentQuestion.timeLimit;
    //_timeRemainingLabel.text = [self timeAsString:_currentQuestion.timeLimit];//[NSString stringWithFormat:@"%d", _currentQuestion.timeLimit];
    NSLog(@"number of questions:%d", [_questionSet getQuestionCount]);
    
    [self beginPoll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beginPoll {
    NSLog(@"beginPoll, timeRem:%d", _timeRemaining);
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
        self.pollQuestionText.text = _currentQuestion.questionText;
        [self.answerTable reloadData];
        self.navigationItem.title = [NSString stringWithFormat:@"Question %d", _currentQuestionNumber + 1];

        //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
    //self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];
    //self.pollQuestionText.text = _currentQuestion.questionText;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // background thread
        //NSLog(@"Background thread 1: waiting 5 seconds");
        // wait 5 seconds
        while(_timeRemaining > 0) {
            [NSThread sleepForTimeInterval:1.0f];
            --_timeRemaining;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // GUI thread
                //NSLog(@"GUI thread 1");
                // update label 1 text
                self.timeRemainingLabel.text = [self timeAsString:_timeRemaining];//@"Done with Label 1";
            });
            //NSLog(@"times up");
        }
        NSLog(@"times up, questionNum:%d",_currentQuestionNumber);
        if(_currentQuestionNumber < [_questionSet getQuestionCount] - 1) {
            ++_currentQuestionNumber;
            _currentQuestion = [_questionSet getQuestionAtIndex:_currentQuestionNumber];
            _timeRemaining = _currentQuestion.timeLimit;
            [self beginPoll];
        }
    });
    //NSLog(@"times up");
}

-(void)nextQuestion {
    
}

//
//  Toolbar buttons
//

- (IBAction)rewindPressed:(UIButton *)sender {
    //[self performSegueWithIdentifier:segueToWordCategoryView sender:self];
}
- (IBAction)playPressed:(UIButton *)sender {
    NSLog(@"playPressed");
    [self performSegueWithIdentifier:@"startPollSegue" sender:self];
}
- (IBAction)forwardPressed:(UIButton *)sender {
    //[self performSegueWithIdentifier:segueToWordCategoryView sender:self];
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
    NSLog(@"number of rows in poll:%d",[_currentQuestion getAnswerCount]);
    //return [_questionSet getQuestionCount];
    return [_currentQuestion getAnswerCount];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunningAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runPollCell"]; //forIndexPath:indexPath];
    
    //temp
    NSArray *tempPercent = @[@"34", @"31", @"23", @"12"];
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[RunningAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"runPollCell"];
    }
    NSLog(@"answer:%@", [_currentQuestion.answerText objectAtIndex:indexPath.row]);
    //cell.textLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLabel.text = [_currentQuestion.answerText objectAtIndex:indexPath.row];
    cell.answerLetterLabel.text = [_letters objectAtIndex:indexPath.row];
    cell.answerProgress.progressTintColor = [_colors objectAtIndex:indexPath.row];
    cell.answerProgress.progress = [[tempPercent objectAtIndex:indexPath.row] doubleValue] / 100.0f;
    cell.answerPercentLabel.text = [tempPercent objectAtIndex:indexPath.row];
    
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

@end
