//
//  EditFriendsTableViewController.m
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import "EditFriendsTableViewController.h"

@interface EditFriendsTableViewController ()

@end

@implementation EditFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error){
        
            NSLog(@"%@", error);
            
        } else {
        
            self.allUsers = objects;
            [self.tableView reloadData];
            
            self.currentUser = [PFUser currentUser];

        
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self isFriend:user]){
    
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else {
    
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    PFRelation *friendRelation = [self.currentUser relationForKey:@"friendsRelation"];

    if ([self isFriend:user]){
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        for (PFUser *friend in self.friends){
            
            
            if([friend.objectId isEqualToString:user.objectId]){
                
                [self.friends removeObject:friend];
                break;
                
            }
            
        }
        
        
        [friendRelation removeObject:user];
        
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.friends addObject:user];
        [friendRelation addObject:user];
        
        
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            
            NSLog(@"%@", error);
            
        }
    }];
    
    
}


#pragma mark - IsFriend

- (BOOL) isFriend:(PFUser *)user{
    for (PFUser *friend in self.friends){
        
        
        if([friend.objectId isEqualToString:user.objectId]){
        
            return YES;
            
        }
        
    }
    
    return NO;
}


@end
