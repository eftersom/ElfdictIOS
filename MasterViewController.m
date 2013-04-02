//
//  MasterViewController.m
//  ElfDictIOS
//
//  Created by Rebecca Mitchell on 3/31/13.
//  Copyright (c) 2013 Rebecca M. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ElfDictServiceConnector.h"
#import "WordDefinition.h"

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (![self.tableView.backgroundView isKindOfClass:[UIImageView class]]) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Background.png"]];
        self.tableView.backgroundView = backgroundView;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar button
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    ElfDictServiceConnector *conn = [[ElfDictServiceConnector alloc] initWithHandler: ^(NSDictionary *result) {
        // Success handler
        m_searchResult = result;
        [self.tableView reloadData];
    } andFailureHandler: ^(NSString *errorMessage) {
        // Failure handler
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Sorry!"
                                                        message: errorMessage
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }];
    
    [conn lookup: [searchBar text]];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[m_searchResult allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 0-based index starting with the first key in the dictionary, moving up. Since the dictionary only understands
    // string identifiers (such as "Sindarin" and "Quenya") numbers can't be used. Thus, we need to acquire all keys,
    // and get the key for the provided section index. This is beneath. 
    NSString *key = [[m_searchResult allKeys] objectAtIndex: section];
    
    if (key == nil) {
        return 0;
    }
    
    // Knowing the key, acquire the NSArray of WordDefinition, and count how many objects it contains.
    return [[m_searchResult objectForKey: key] count];
}

- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [[m_searchResult allKeys] objectAtIndex: section];
    
    return key;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];
    
    UILabel *sectionLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    
    sectionLabel.backgroundColor=[UIColor clearColor];
    sectionLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
    
    
    NSString *key = [[m_searchResult allKeys] objectAtIndex: section];
    
    sectionLabel.text=[NSString stringWithFormat:@"%@", key];
    [tempView addSubview:sectionLabel];

    return tempView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *key = [[m_searchResult allKeys] objectAtIndex: indexPath.section];
    NSMutableArray *definitionArray = [m_searchResult objectForKey: key];
    WordDefinition *definition = [definitionArray objectAtIndex: indexPath.row];
    

    cell.textLabel.text = [definition word];
    cell.detailTextLabel.text = [definition translation];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    

    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        // m_search result contains a hashtable of languages, we get the selected section by finding the language at that position.
        NSString *key = [[m_searchResult allKeys] objectAtIndex: indexPath.section];
        //Get the elements under the selected section using the key hash. 
        NSMutableArray *definitionArray = [m_searchResult objectForKey: key];
        //gte the selected objectat the specified position of array.
        WordDefinition *definition = [definitionArray objectAtIndex: indexPath.row];
    
        [[segue destinationViewController] setDetailItem:definition];
    }
}

@end
