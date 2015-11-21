//
//  CameraViewController.m
//  Ribbit
//
//  Created by Wilson Muñoz on 11/16/15.
//  Copyright © 2015 Wilson Muñoz. All rights reserved.
//

#import "CameraViewController.h"
#import "MobileCoreServices/UTCoreTypes.h"


@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.recepients = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //QUERY de Amistades
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
    
    //CAMARA
    if (self.image == nil && [self.videoFilePath length] == 0) {

        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        } else {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Image Picker Controller Delegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];

}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString: (NSString *) kUTTypeImage]){
    
        //Photo
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
        
            //Save Image
            
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        
        }
        
    } else {
        
        //Video
        
        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL];
        self.videoFilePath = [imagePickerURL path];
        
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
            
            //Save Video
            if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)){
               
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
            
        }
    
    }

    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

#pragma mark - Table view data source DELEGATE
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if([self.recepients containsObject:user.objectId]){
    
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    } else {
    
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){
    
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recepients addObject:user.objectId];
    
    } else {
    
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recepients removeObject:user.objectId];
    
    }
    
}

#pragma mark Actions Botón de Cámara
- (IBAction)cancel:(id)sender {
    
    [self cancelar];
    [self.tabBarController setSelectedIndex:0];
    
}


- (IBAction)send:(id)sender {
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        
        [[[UIAlertView alloc] initWithTitle:@"Please Select Photo or video to Sent" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
        
    } else {
    
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
        
    }
}


#pragma mark Helpers
- (void)cancelar {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recepients removeAllObjects];
}

-(UIImage *)resizeImage: (UIImage *)image toWidth:(float)width andHeight:(float)height{

    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(newSize);
    
        [self.image drawInRect:newRectangle];
    
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;

}


- (void) uploadMessage{

    //Es imagen o video?
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    
    if(self.image != nil){
        
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
        fileData =UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
        
    } else {
    
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
        
            [[[UIAlertView alloc] initWithTitle:@"Please Try sending Message Again" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];

        } else {
        
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recepients forKey:@"recipientsIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if(error){
                    
                    [[[UIAlertView alloc] initWithTitle:@"Please Try sending Message Again" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                    
                } else {
                    
                    //All good, limpiamos.
                    [self cancelar];
                
                }
                
            }];
        
        }
        
    }];

}

@end
