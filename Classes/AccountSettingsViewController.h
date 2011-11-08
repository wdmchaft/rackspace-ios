//
//  AccountSettingsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/14/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface AccountSettingsViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *usernameTextField;
    UITextField *apiKeyTextField;
    UITextField *providerNameTextField;
    UITextField *authURLTextField;    
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) UISwitch *validateSSLSwitch;

@end
