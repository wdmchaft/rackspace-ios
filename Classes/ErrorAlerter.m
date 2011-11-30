//
//  ErrorAlerter.m
//  OpenStack
//
//  Created by Mike Mayo on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ErrorAlerter.h"
#import "LogEntryModalViewController.h"
#import "OpenStackRequest.h"
#import "UIViewController+Conveniences.h"
#import "APILogEntry.h"


@implementation ErrorAlerter

@synthesize failedRequest, logEntryModalViewController, viewController;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // details button
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.logEntryModalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [self.viewController presentModalViewController:self.logEntryModalViewController animated:YES];
    }
}

- (void)alert:(NSString *)message request:(OpenStackRequest *)request viewController:(UIViewController *)aViewController {
    
    self.viewController = aViewController;

    NSString *title = @"Error";
    if (request.responseStatusCode == 0) {
        title = @"Connection Error";
        message = @"Please check your connection or API URL and try again.";
    }

    self.logEntryModalViewController = [[LogEntryModalViewController alloc] initWithNibName:@"LogEntryModalViewController" bundle:nil];
    self.logEntryModalViewController.logEntry = [[[APILogEntry alloc] initWithRequest:request] autorelease];
    self.logEntryModalViewController.requestDescription = [self.logEntryModalViewController.logEntry requestDescription];
    self.logEntryModalViewController.responseDescription = [self.logEntryModalViewController.logEntry responseDescription];
    self.logEntryModalViewController.requestMethod = [self.logEntryModalViewController.logEntry requestMethod];
    self.logEntryModalViewController.url = [[self.logEntryModalViewController.logEntry url] description];
    
    // present an alert with a Details button to show the API log entry
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Details", nil];
    [alert show];
    [alert release];        
}

- (void)dealloc {
    [failedRequest release];
    [logEntryModalViewController release];
    [viewController release];
    [super dealloc];
}

@end
