//
//  InboxTableViewController.h
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface InboxTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *messages;
@property(nonatomic, strong) PFObject *selectedMessage;
@property(nonatomic, strong) AVPlayer *moviePlayer;

@end
