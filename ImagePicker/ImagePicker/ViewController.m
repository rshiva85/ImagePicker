//
//  ViewController.m
//  ImagePicker
//
//  Created by SIVA KUMAR (YPAYCASH\30085) on 03/11/15.
//  Copyright (c) 2015 PayBlox. All rights reserved.
//

//To get Ios version for deprecated changes like actionsheet, alertview, alertcontroller
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#import "ViewController.h"
#import "AppDelegate.h"
#import "ImageViewController.h"

@interface ViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>{
    
    UIImagePickerController *pickerImage;
    NSManagedObjectContext *context;
    NSData *imageData;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.delegate = self;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickGallery:(id)sender {
    [self performSegueWithIdentifier:@"segueNext" sender:self];
}

- (IBAction)onclickSelectImage:(id)sender {
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose your option"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Camera", @"Gallery", nil];
        
        [actionSheet showInView:self.view];
        actionSheet.tag = 100;
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose your option" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
        [alertController addAction:alertActionCancel];
        
        UIAlertAction* alertActionCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerImage animated:YES completion:NULL];
        }];
        [alertController addAction:alertActionCamera];
        
        UIAlertAction* alertActionGallery = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:pickerImage animated:YES completion:NULL];
        }];
        [alertController addAction:alertActionGallery];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        // all done
    } else if (buttonIndex == 0) { // Camera
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
        }
        else{
            pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerImage animated:YES completion:NULL];
        }
    } else if (buttonIndex == 1) { // Gallery
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerImage animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    imageData = UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]);
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Image Name"
                                                          message:@"Maximum 20 characters Only"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Proceed", nil];
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [myAlertView show];

    [pickerImage dismissViewControllerAnimated:YES completion:NULL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Proceed"]){
        if ([[[alertView textFieldAtIndex:0] text] length] == 0) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Image name can not be Empty"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Proceed", nil];
            myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            [myAlertView show];
        }
        else {
            NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Entity"
                                                          inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDesc];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", [[alertView textFieldAtIndex:0] text]];
            [request setPredicate:pred];
            NSError *error;
            NSArray *objects = [context executeFetchRequest:request
                                                      error:&error];
            
            if ([objects count] == 0) {
                NSManagedObject *newImage = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"                   inManagedObjectContext:context];
                [newImage setValue:imageData forKey:@"image"];
                
                [newImage setValue:[[alertView textFieldAtIndex:0] text] forKey:@"name"];
                [alertView textFieldAtIndex:0].text = @"";
                [self.view endEditing:YES];
                [context save:&error];
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                                      message:@"Image saved Successfully"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"Gallery", nil];
                
                [myAlertView show];
            } else {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Image name already exists, Please enter other name"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"Proceed", nil];
                myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [myAlertView show];
            }
        }
    }
    else if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]){
        [self performSegueWithIdentifier:@"segueNext" sender:self];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return textField.text.length + (string.length - range.length) <= 20;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [pickerImage dismissViewControllerAnimated:YES completion:NULL];
}

@end
