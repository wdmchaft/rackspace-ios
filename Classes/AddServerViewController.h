//
//  AddServerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Image, ServersViewController, OpenStackRequest, LogEntryModalViewController, AccountHomeViewController;

@interface AddServerViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    
    UISlider *serverCountSlider;
    UILabel *serverCountLabel;
    UISlider *flavorSlider;
    UILabel *flavorLabel;
    UITextField *nameTextField;
    UILabel *serverNumbersLabel;
    
    NSInteger nodeCount;
    NSInteger flavorIndex;
    
    NSArray *plugins;
    
    NSMutableArray *createServerObservers;
    NSInteger successCount;
    NSInteger failureCount;
    
    OpenStackRequest *failedRequest;    
    
    NSInteger maxServers;
    
    AccountHomeViewController *accountHomeViewController;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Image *selectedImage;
@property (nonatomic, retain) ServersViewController *serversViewController;
@property (nonatomic, retain) AccountHomeViewController *accountHomeViewController;
@property (nonatomic, retain) LogEntryModalViewController *logEntryModalViewController;

- (void)saveButtonPressed:(id)sender;
- (void)setNewSelectedImage:(Image *)image;
- (void)alert:(NSString *)message request:(OpenStackRequest *)request;

@end
