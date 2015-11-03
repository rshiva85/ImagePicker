//
//  ImageViewController.h
//  ImagePicker
//
//  Created by SIVA KUMAR (YPAYCASH\30085) on 03/11/15.
//  Copyright (c) 2015 PayBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableviewImage;
@end
