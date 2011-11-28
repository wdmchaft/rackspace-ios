//
//  AccountDetailsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class Provider, RootViewController, ProvidersViewController, OpenStackAccount, ActivityIndicatorView;

@interface AccountDetailsViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *usernameTextField;
    UITextField *apiKeyTextField;
    UITextField *providerNameTextField;
    UITextField *apiEndpointTextField;
    RootViewController *rootViewController;
    ProvidersViewController *providersViewController;

    BOOL customProvider;
    NSInteger authenticationSection;
    NSInteger providerSection;
    
    BOOL tableShrunk;
    
}

@property (nonatomic, retain) Provider *provider;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) ProvidersViewController *providersViewController;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UISwitch *validateSSLSwitch;
@property (nonatomic, retain) OpenStackAccount *account;    

- (void)saveButtonPressed:(id)sender;

@end
