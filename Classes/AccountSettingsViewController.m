//
//  AccountSettingsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/14/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountSettingsViewController.h"
#import "OpenStackAccount.h"
#import "Provider.h"
#import "RSTextFieldCell.h"
#import "UIColor+MoreColors.h"

#define kAuthSection 0
#define kProviderSection 1

#define kUsername 0
#define kAPIKey 1

#define kProviderName 0
#define kAuthEndpoint 1
#define kValidateSSL 2

@implementation AccountSettingsViewController

@synthesize account, validateSSLSwitch;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"API Account Info";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *backgroundContainer = [[UIView alloc] init];
        backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        NSString *logoFilename = @"account-settings-icon-large.png";
        UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
        osLogo.contentMode = UIViewContentModeScaleAspectFit;
        osLogo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            osLogo.alpha = 0.3;
        }
        [backgroundContainer addSubview:osLogo];
        [osLogo release];
        self.tableView.backgroundView = backgroundContainer;
        [backgroundContainer release];
    }    
    
    self.validateSSLSwitch = [[[UISwitch alloc] init] autorelease];
    [self.validateSSLSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // the rackspace view is simpler, so go ahead and show the keyboard.
    // don't for custom accounts because the keyboard hides some of the
    // fields
    if ([self.account.provider isRackspace]) {
        [usernameTextField becomeFirstResponder];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.account.provider isRackspace]) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.account.provider isRackspace]) {
        return 2;
    } else {
        return section == kAuthSection ? 2 : 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kAuthSection:
            return [NSString stringWithFormat:@"%@ Login", self.account.provider.name];
        case kProviderSection:
            return @"Provider Details";
        default:
            return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case kAuthSection:
            return [NSString stringWithFormat:@"API Version %@", self.account.apiVersion];
        default:
            return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    }
    
    if (indexPath.section == kAuthSection) {
        
        switch (indexPath.row) {
            case kUsername:
                cell.textLabel.text = @"Username";
                usernameTextField = cell.textField;
                usernameTextField.delegate = self;
                usernameTextField.secureTextEntry = NO;
                usernameTextField.returnKeyType = UIReturnKeyNext;
                usernameTextField.text = self.account.username;
                usernameTextField.placeholder = @"username";
                break;
                
            case kAPIKey:
                cell.textLabel.text = @"API Key";
                apiKeyTextField = cell.textField;
                apiKeyTextField.secureTextEntry = YES;
                apiKeyTextField.delegate = self;
                apiKeyTextField.returnKeyType = UIReturnKeyDone;
                apiKeyTextField.text = self.account.apiKey;
                
            default:
                break;
        }
        
    } else {
        
        switch (indexPath.row) {
            case kProviderName:
                cell.textLabel.text = @"Name";
                providerNameTextField = cell.textField;
                providerNameTextField.delegate = self;
                providerNameTextField.returnKeyType = UIReturnKeyNext;
                providerNameTextField.text = self.account.provider.name;
                providerNameTextField.placeholder = @"Ex: Rackspace Cloud";                
                break;
                
            case kAuthEndpoint:
                cell.textLabel.text = @"API URL";
                authURLTextField = cell.textField;
                authURLTextField.delegate = self;
                authURLTextField.returnKeyType = UIReturnKeyDone;
                authURLTextField.text = [self.account.provider.authEndpointURL description];
                break;
                
            case kValidateSSL:
                cell.textLabel.text = @"Validate SSL Certificate";
                cell.accessoryView = self.validateSSLSwitch;
                self.validateSSLSwitch.on = !account.ignoresSSLValidation;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
                
            default:
                break;
        }
        
    }
    
    return cell;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];    
    if ([textField isEqual:usernameTextField]) {
        [apiKeyTextField becomeFirstResponder];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:usernameTextField]) {
        self.account.username = result;
    } else if ([textField isEqual:apiKeyTextField]) {
        self.account.apiKey = result;
    }
    self.account.authToken = @"";
    self.account.hasBeenRefreshed = NO;
    [self.account persist];
    
    return YES;
}

#pragma mark - Switch Action

- (void)switchChanged {
    
    self.account.ignoresSSLValidation = !self.validateSSLSwitch.on;
    [self.account persist];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [account release];
    [validateSSLSwitch release];
    [super dealloc];
}


@end

