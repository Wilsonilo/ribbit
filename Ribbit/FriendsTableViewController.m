//
//  FriendsTableViewController.m
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "EditFriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![PFUser currentUser]){
        
        [self.tabBarController setSelectedIndex:0];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    
}

- (void) viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if(error)
        {
            
            NSLog(@"%@", error);
        } else {
            
            self.friends = objects;
            [self.tableView reloadData];
            
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([segue.identifier isEqualToString:@"showEditFriends"]){
    
        EditFriendsTableViewController *viewController = (EditFriendsTableViewController *)segue.destinationViewController;
        
        viewController.friends = [NSMutableArray arrayWithArray:self.friends];
        
    }

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    return cell;
}


@end
