//
//  EditFriendsTableViewController.h
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditFriendsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends;

-(BOOL) isFriend:(PFUser *)user;
@end
