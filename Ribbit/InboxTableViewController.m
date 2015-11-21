//
//  InboxTableViewController.m
//  Ribbit
//
//  Created by Wilson Muñoz on 11/15/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import "InboxTableViewController.h"
#import "ImageViewControler.h"


@interface InboxTableViewController ()

@end

@implementation InboxTableViewController


- (IBAction)logout:(id)sender {
    
//    [PFUser logOut];
//    [self.tabBarController setSelectedIndex:1];
    
    //Aplicar en will appear si esta logeado el usuario antes de hacer el query, si no mandar no hacer nada.

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        NSLog(@"Current user: %@", currentUser.username);
        
        //[self performSegueWithIdentifier:@"irATabs" sender:self];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
        //PFUser *currentUser = [PFUser currentUser];
        //        NSLog(@"%@", currentUser.username);
        self.navigationItem.hidesBackButton = YES;
        
    
    } else {
        
        
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        
        logInViewController.fields = (PFLogInFieldsUsernameAndPassword
                                      | PFLogInFieldsLogInButton
                                      | PFLogInFieldsSignUpButton
                                      | PFLogInFieldsPasswordForgotten);
        
        [self presentViewController:logInViewController animated:YES completion:nil];
    
    }
}

- (void) viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipientsIds" equalTo:[[PFUser currentUser] objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if(error)
        {
            
            NSLog(@"%@", error);
            
        } else {
            
            //Get messages
            self.messages = objects;
            [self.tableView reloadData];
//            NSLog(@"Retrieved %d messages", [self.messages count]);

        }
        
        
    }];
        
    
    } else {
    
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        
        logInViewController.fields = (PFLogInFieldsUsernameAndPassword
                                      | PFLogInFieldsLogInButton
                                      | PFLogInFieldsSignUpButton
                                      | PFLogInFieldsPasswordForgotten);
        
        [self presentViewController:logInViewController animated:YES completion:nil];
    
    
    }
    

}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

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
    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    NSString *filetype = [message objectForKey:@"fileType"];
    
    if([filetype isEqualToString:@"image"]){
        
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
        
    
    } else {
    
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *filetype = [self.selectedMessage objectForKey:@"fileType"];
    
    if([filetype isEqualToString:@"image"]){
        
        //Vamos el view para ver la imagen.
        [self performSegueWithIdentifier:@"showImage" sender:self];
        
        
    } else {
        
        //Mostramos video
        PFFile *urlVideo = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:urlVideo.url];
        
        self.moviePlayer = [AVPlayer playerWithURL:fileURL];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:fileURL];
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [layer setFrame:self.view.bounds];
        CGRect frame = layer.frame;
        layer.frame = CGRectMake(frame.origin.x, frame.origin.y - 30, frame.size.width, frame.size.height);
        [self.view.layer addSublayer: layer];
        [self.moviePlayer play];
        
        
    }
    
    NSMutableArray *recepientsIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientsIds"]];
    
    if([recepientsIds count] == 1){
        
        [self.selectedMessage deleteInBackground];
    
    
    } else {
        
        [recepientsIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recepientsIds forKey:@"recepientsId"];
        [self.selectedMessage saveInBackground];
    
    }

    
}

#pragma mark - Parse LOGIN

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    
    [[[UIAlertView alloc] initWithTitle:@"Need Info" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
    
    return NO;
    
}
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Login Error, Wrong Password or Username" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Parse SIGNUP

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Failed to Sign Up" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Segues.

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showImage"]){
        
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewControler *imageViewController = (ImageViewControler *)segue.destinationViewController;
        
        imageViewController.message = self.selectedMessage;
    
    }
}

@end
