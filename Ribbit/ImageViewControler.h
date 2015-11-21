//
//  ImageViewControler.h
//  Ribbit
//
//  Created by Wilson Muñoz on 11/16/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewControler : UIViewController
@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
