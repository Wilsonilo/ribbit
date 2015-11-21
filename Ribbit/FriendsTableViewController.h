//
//  FriendsTableViewController.h
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface FriendsTableViewController : UITableViewController
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;

@end
