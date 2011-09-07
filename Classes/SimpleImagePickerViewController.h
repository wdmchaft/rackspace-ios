//
//  SimpleImagePickerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

#define kModeChooseImage 0
#define kModeRebuildServer 1

@class ServerViewController;

@interface SimpleImagePickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    IBOutlet UIPickerView *pickerView;
    NSDictionary *images;
    NSMutableArray *stringKeys;
    NSString *selectedFamily;
    id delegate;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSString *selectedImageId;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, retain) ServerViewController *serverViewController;

// should respond to setNewSelectedImage:(Image *)image;
@property (nonatomic, retain) id delegate;

@end
