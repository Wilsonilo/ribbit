//
//  CameraViewController.h
//  Ribbit
//
//  Created by Wilson Muñoz on 11/16/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *recepients;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

-(void)uploadMessage;

-(UIImage *)resizeImage: (UIImage *)image toWidth:(float)width andHeight:(float)height;

@end
