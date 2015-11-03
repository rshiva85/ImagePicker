//
//  ImageViewController.m
//  ImagePicker
//
//  Created by SIVA KUMAR (YPAYCASH\30085) on 03/11/15.
//  Copyright (c) 2015 PayBlox. All rights reserved.
//

#import "ImageViewController.h"
#import "AppDelegate.h"


@interface ImageViewController (){
    NSMutableArray *arrayImages;
    NSMutableArray *arrayNames;
}

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    arrayImages = [[NSMutableArray alloc] init];
    arrayNames = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Entity"
                                                  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if ([objects count] == 0) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                              message:@"No Images to display"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:nil];
        
        [myAlertView show];
    }else {
        for (int i=0; i<objects.count; i++) {
            [arrayNames addObject:[objects[i] valueForKey:@"name"]];
            [arrayImages addObject:[objects[i] valueForKey:@"image"]];
        }
        [_tableviewImage reloadData];
    }
}
- (IBAction)onClickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableview Delegate and Datasource methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayImages.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 150, 130)];
    imageview.image = [UIImage imageWithData:[arrayImages objectAtIndex:indexPath.row]];
    [cell addSubview:imageview];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(180, 55, 140, 40)];
    lblName.numberOfLines = 2;
    lblName.text = [arrayNames objectAtIndex:indexPath.row];
    [cell addSubview:lblName];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
