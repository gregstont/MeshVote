//
//  EditQuestionViewController.m
//  MeshVote
//
//  Created by Taylor Gregston on 9/19/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "EditQuestionViewController.h"

@interface EditQuestionViewController ()

@end

@implementation EditQuestionViewController

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
    NSLog(@"in editQuestion view Controller");
    _delegate = [self.navigationController.viewControllers objectAtIndex:0];
    [_questionTextLabel setText:[_delegate getQuestionTextAtIndex:[_delegate getSelectedQuestion]]];
    // Do any additional setup after loading the view.
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    NSLog(@"selectedQuestion:%d", [_delegate getSelectedQuestion]);
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
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"checking number of rows");
    
    //NSIndexPath *temp = [tableView indexPathForSelectedRow];
    
    //NSLog(@" and:%d", [_delegate getAnswerCountAtIndex:0]);
    return [_delegate getAnswerCountAtIndex:[_delegate getSelectedQuestion]]; //TODO: change this
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRow");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eq_cellid"]; //forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        //NSLog(@"Shouldnt be here!!!!!!!!!!!");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"eq_cellid"];
    }
    //NSIndexPath *temp = [tableView indexPathForSelectedRow];
    cell.textLabel.text = [_delegate getAnswerTextAtIndex:[_delegate getSelectedQuestion] andAnswerIndex:(int)indexPath.row];//@"d";//[_questionSet getQuestionTextAtIndex:(int)indexPath.row];//[_questions objectAtIndex:indexPath.row];
    
    //NSLog(@" text:%@", [_delegate getAnswerTextAtIndex:0 andAnswerIndex:(int)indexPath.row]);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

@end
