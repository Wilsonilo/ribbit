//
//  ImageViewControler.m
//  Ribbit
//
//  Created by Wilson Muñoz on 11/16/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import "ImageViewControler.h"

@interface ImageViewControler ()

@end

@implementation ImageViewControler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageURL = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    self.imageView.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Mensaje de %@", senderName];
    self.navigationItem.title = title;
    
}

- (void) viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(timeOut)]){
        
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    } else {
    
        NSLog(@"Selector not found");
    
    }

}

#pragma mark  - Helpers

- (void)timeOut {
    
    [self.navigationController popViewControllerAnimated:YES];

}

@end
