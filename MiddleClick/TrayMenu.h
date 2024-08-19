#import "Controller.h"
#import <Foundation/Foundation.h>

extern NSMenuItem * recent_click_items[ 4 ];

@interface TrayMenu : NSObject <NSFileManagerDelegate> {
@private
  NSStatusItem* _statusItem;
  Controller* myController;
  NSMenuItem* accessibilityPermissionStatusItem;
  NSMenuItem* accessibilityPermissionActionItem;
  NSMenuItem* infoItem;
  NSMenuItem* tapToClickItem;
}
- (id)initWithController:(Controller*)ctrl;
- (void)setChecks;
- (void)toggleTapToClick:(id)sender;
- (void)resetTapToClick:(id)sender;
@end
