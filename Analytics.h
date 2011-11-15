//
//  Constants.h
//  OpenStack
//
//  Created by Matthew Newberry on 05/18/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GANTracker.h"
#import <UIKit/UIKit.h>


// Analytics Keys
#define CATEGORY_SERVER @"server"
#define CATEGORY_CONTAINERS @"containers"
#define CATEGORY_FILES @"files"
#define CATEGORY_LOAD_BALANCER @"load_balancer"

#define EVENT_REBOOTED @"reboot"
#define EVENT_CREATED @"created"
#define EVENT_CREATED_MULTIPLE @"created_multiple"
#define EVENT_UPDATED @"updated"
#define EVENT_PINGED @"pinged"
#define EVENT_RESIZED @"resized"
#define EVENT_REBUILT @"rebuilt"
#define EVENT_DELETED @"deleted"
#define EVENT_BACKUP_SCHEDULE_CHANGED @"backup_schedule_changed"
#define EVENT_RENAMED @"renamed"
#define EVENT_PASSWORD_CHANGED @"password_changed"

// load balancer specific events
#define EVENT_UPDATED_LB_CONNECTION_LOGGING @"updated_lb_connection_logging"
#define EVENT_ADDED_LB_NODES @"added_lb_nodes"
#define EVENT_UPDATED_LB_NODE @"updated_lb_node"
#define EVENT_DELETED_LB_NODE @"deleted_lb_node"
#define EVENT_UPDATED_LB_CONNECTION_THROTTLING @"updated_lb_connection_throttling"
#define EVENT_DISABLED_LB_CONNECTION_THROTTLING @"disabled_lb_connection_throttling"

void TrackEvent(NSString *category, NSString *action);
void TrackViewController(UIViewController *vc);
void DispatchAnalytics();
