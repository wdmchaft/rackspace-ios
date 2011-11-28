//
//  AccountDetailsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountDetailsViewController.h"
#import "Provider.h"
#import "RSTextFieldCell.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "RootViewController.h"
#import "ProvidersViewController.h"
#import "OpenStackRequest.h"
#import "UIViewController+Conveniences.h"
#import "NSString+Conveniences.h"
#import "ActivityIndicatorView.h"


#define kUsername 0
#define kAPIKey 1

#define kProviderName 0
#define kAuthEndpoint 1
#define kValidateSSL 2

@implementation AccountDetailsViewController

@synthesize provider, rootViewController, providersViewController, activityIndicatorView, validateSSLSwitch, account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldsHaveValues:(NSArray *)textFields {
    
    BOOL valid = YES;
    
    for (UITextField *textField in textFields) {
        
        valid = valid && textField.text && ![@"" isEqualToString:textField.text];
        if (!valid) {
            break;
        }
        
    }
    
    return valid;
    
}

- (void)authenticate {
    
    BOOL valid = YES;
    
    if (customProvider) {
        
        valid = [self textFieldsHaveValues:[NSArray arrayWithObjects:providerNameTextField, 
                                            apiEndpointTextField, usernameTextField,
                                            apiKeyTextField, nil]];
        
    } else {
        
        valid = [self textFieldsHaveValues:[NSArray arrayWithObjects:usernameTextField,
                                            apiKeyTextField, nil]];
        
    }
    
    if (!valid) {
        [self alert:nil message:@"All fields are required."];
        return;
    }
    
    self.account = [[[OpenStackAccount alloc] init] autorelease];
    self.account.provider = provider;
    
    if (!self.account.provider) {
        Provider *p = [[Provider alloc] init];
        p.name = providerNameTextField.text;                                
        
        NSString *urlString = apiEndpointTextField.text;
        if ([urlString characterAtIndex:[urlString length] - 1] == '/') {
            urlString = [urlString substringToIndex:[urlString length] - 1];
        }
        
        p.authEndpointURL = [NSURL URLWithString:urlString];
        self.account.provider = p;
        [p release];
    }
    
    self.account.username = usernameTextField.text;
    self.account.apiKey = apiKeyTextField.text;                        
    
    if (self.validateSSLSwitch && !self.validateSSLSwitch.on) {
        self.account.ignoresSSLValidation = YES;
    } else {
        self.account.ignoresSSLValidation = NO;
    }
    
    self.activityIndicatorView = [[[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Authenticating..."] text:@"Authenticating..."] autorelease];
    [self.activityIndicatorView addToView:self.view];
    
    [[self.account.manager authenticate] success:^(OpenStackRequest *request) {
        
        [rootViewController.tableView reloadData];
        [self.account refreshCollections];
        [self.navigationController dismissModalViewControllerAnimated:YES];
        
    } failure:^(OpenStackRequest *request) {
        
        [self.activityIndicatorView removeFromSuperview];
        if ([request responseStatusCode] == 401) {
            if (!customProvider) {
                [self alert:@"Authentication failed.  Please check your User Name and Password." request:request];
            } else {
                [self alert:@"Authentication failed.  Please check your User Name and API Key." request:request];
            }
        } else {
            [self failOnBadConnection];
        }
        
    }];
    
}

#pragma mark - Button Handlers

- (void)saveButtonPressed:(id)sender {
    tableShrunk = NO;
    CGRect rect = self.tableView.frame;
    rect.size.height = 416.0;
    self.tableView.frame = rect;
    [self authenticate];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Authentication";
    providerSection = -1;
    authenticationSection = 0;
    [self addSaveButton];
    
    self.validateSSLSwitch = [[[UISwitch alloc] init] autorelease];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (provider == nil) {
        customProvider = YES;
        providerSection = 0;
        authenticationSection = 1;
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [customProvider ? providerNameTextField : usernameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [usernameTextField resignFirstResponder];
    [apiKeyTextField resignFirstResponder];
    [providerNameTextField resignFirstResponder];
    [apiEndpointTextField resignFirstResponder];
    tableShrunk = NO;
    CGRect rect = self.tableView.frame;
    rect.size.height = 416.0;
    self.tableView.frame = rect;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return customProvider ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == authenticationSection) {
        return 2;
    } else {
        return customProvider ? 3 : 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == authenticationSection) {
        if (customProvider) {
            return @"Login";
        } else {
            return [NSString stringWithFormat:@"%@ Login", provider.name];
        }
    } else if (section == providerSection) {
        return @"Provider Details";
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (customProvider) {
        return @"";
    } else {
        return provider.authHelpMessage;
    }
}

- (RSTextFieldCell *)textCell:(NSString *)labelText textField:(UITextField **)textField secure:(BOOL)secure returnKeyType:(UIReturnKeyType)returnKeyType {

    RSTextFieldCell *cell = (RSTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:labelText];
    
    if (cell == nil) {
        
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:labelText] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
        cell.textLabel.text = labelText;
        *textField = cell.textField;
        ((UITextField *)*textField).delegate = self;
        ((UITextField *)*textField).secureTextEntry = secure;
        ((UITextField *)*textField).returnKeyType = returnKeyType;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == authenticationSection) {
        
        if (indexPath.row == kUsername) {
            
            cell = [self textCell:@"Username" textField:&usernameTextField secure:NO returnKeyType:UIReturnKeyNext];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGRect rect = usernameTextField.frame;
                CGFloat offset = 19.0;
                usernameTextField.frame = CGRectMake(rect.origin.x + offset, rect.origin.y, rect.size.width - offset, rect.size.height);
            }
            
        } else if (indexPath.row == kAPIKey) {
            
            if (!customProvider) {
                cell = [self textCell:@"Password" textField:&apiKeyTextField secure:YES returnKeyType:UIReturnKeyDone];
            } else {
                cell = [self textCell:@"API Key" textField:&apiKeyTextField secure:YES returnKeyType:UIReturnKeyDone];
            }
            
        }
        
    } else if (indexPath.section == providerSection) {
        
        if (indexPath.row == kProviderName) {
            
            cell = [self textCell:@"Name" textField:&providerNameTextField secure:NO returnKeyType:UIReturnKeyNext];
            providerNameTextField.placeholder = @"Ex: Rackspace Cloud";
            
        } else if (indexPath.row == kAuthEndpoint) {
            
            cell = [self textCell:@"API URL" textField:&apiEndpointTextField secure:NO returnKeyType:UIReturnKeyNext];

        } else if (indexPath.row == kValidateSSL) {
            
            static NSString *sslID = @"SSLCell";
            cell = [self.tableView dequeueReusableCellWithIdentifier:sslID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sslID] autorelease];
                cell.textLabel.text = @"Validate SSL Certificate";
                self.validateSSLSwitch.on = YES;
                cell.accessoryView = self.validateSSLSwitch;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
        }
        
    }
    
    return cell;
    
}

#pragma mark - Text Field Delegate

- (void)tableShrinkAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    UITextField *textField = ((UITextField *)context);
    if ([textField isEqual:apiKeyTextField] || [textField isEqual:usernameTextField]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {    
    if (!tableShrunk) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [UIView beginAnimations:nil context:textField];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(tableShrinkAnimationDidStop:finished:context:)];
            CGRect rect = self.tableView.frame;
            rect.size.height = 200.0;
            self.tableView.frame = rect;
            [UIView commitAnimations];
            tableShrunk = YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    

    if ([textField isEqual:providerNameTextField]) {
        [apiEndpointTextField becomeFirstResponder];
    } else if ([textField isEqual:apiEndpointTextField]) {
        [usernameTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else if ([textField isEqual:usernameTextField]) {
        [apiKeyTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        [textField resignFirstResponder];
        tableShrunk = NO;
        CGRect rect = self.tableView.frame;
        rect.size.height = 416.0;
        self.tableView.frame = rect;
        [self authenticate];
    }
    return NO;
}

#pragma mark - Memory management

- (void)dealloc {
    [provider release];
    [rootViewController release];
    [providersViewController release];
    [activityIndicatorView release];
    [validateSSLSwitch release];
    [account release];
    [super dealloc];
}

@end
