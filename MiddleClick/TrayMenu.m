#import "TrayMenu.h"
#import "Controller.h"
#import <Cocoa/Cocoa.h>

NSMenuItem * recent_click_items[ 4 ];

@implementation TrayMenu

- (id)initWithController:(Controller*)ctrl
{
	[super init];
	myController = ctrl;
	[self setChecks];
	return self;
}

- (void)initAccessibilityPermissionStatus:(NSMenu*)menu
{
	BOOL hasAccessibilityPermission = AXIsProcessTrusted();

	[self updateAccessibilityPermissionStatus:menu
								 hasAccessibilityPermission:hasAccessibilityPermission];

	if (!hasAccessibilityPermission) {
		[NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer* timer) {
			[self initAccessibilityPermissionStatus:menu];
		}];
	}
}
- (void)updateAccessibilityPermissionStatus:(NSMenu*)menu
								 hasAccessibilityPermission:(BOOL)isTrusted
{
	_statusItem.button.appearsDisabled = !isTrusted;
	accessibilityPermissionStatusItem.hidden = isTrusted;
	accessibilityPermissionActionItem.hidden = isTrusted;
}

- (void)openWebsite:(id)sender
{
	NSURL* url = [NSURL
								URLWithString:@"https://github.com/artginzburg/MiddleClick-Ventura"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}
- (void)openAccessibilitySettings:(id)sender
{
	BOOL isPreCatalina = (floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_15);
	if (isPreCatalina) {
		NSAppleScript *a = [[NSAppleScript alloc] initWithSource:
												@"tell application \"System Preferences\"\n"
												"activate\n"
												"reveal anchor \"Privacy_Accessibility\" of pane \"com.apple.preference.security\"\n"
												"end tell"];
		[a executeAndReturnError:nil];
		[a release];
	} else {
		NSURL* url = [NSURL
									URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}

- (void)toggleTapToClick:(id)sender
{
	[myController setMode:[sender state] == NSControlStateValueOn];
	[self setChecks];
}

- (void)resetTapToClick:(id)sender
{
	[myController resetClickMode];
	[self setChecks];
}

- (void)setChecks
{
	bool clickMode = [myController getClickMode];
	NSString* clickModeInfo = clickMode ? @"Click" : @"Click or Tap";

	int fingersQua = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fingers"];

	[infoItem setTitle:[clickModeInfo stringByAppendingFormat: @" with %d Fingers", fingersQua]];
	[tapToClickItem setState:clickMode ? NSControlStateValueOff : NSControlStateValueOn];
}

- (void)actionQuit:(id)sender
{
	[NSApp terminate:sender];
}

- (NSMenu*)createMenu
{
	NSMenu* menu = [NSMenu new];
	NSMenuItem* menuItem;



	[self createMenuAccessibilityPermissionItems:menu];

	// Add About
	menuItem = [menu addItemWithTitle:@"About MichaelClick..."
														 action:@selector(openWebsite:)
											keyEquivalent:@""];
	[menuItem setTarget:self];

	[menu addItem:[NSMenuItem separatorItem]];

	infoItem = [menu addItemWithTitle:@""
														 action:nil
											keyEquivalent:@""];
	[infoItem setTarget:self];

	tapToClickItem = [menu addItemWithTitle:@"Tap to click"
																	 action:@selector(toggleTapToClick:)
														keyEquivalent:@""];
	[tapToClickItem setTarget:self];

	NSMenuItem* resetItem = [menu addItemWithTitle:@"Reset to System Settings"
																					action:@selector(resetTapToClick:)
																	 keyEquivalent:@""];
	resetItem.alternate = YES;
	resetItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
	[resetItem setTarget:self];

	[self setChecks];

	[menu addItem:[NSMenuItem separatorItem]];

	for( size_t i = 0; i < 4; i++ ) {
		recent_click_items[ i ] = [menu addItemWithTitle:@"None"
												action:nil
										 keyEquivalent:@""];
		[recent_click_items[ i ] setTarget:self];
	}

	// Add Separator
	[menu addItem:[NSMenuItem separatorItem]];

	// Add Quit Action
	menuItem = [menu addItemWithTitle:@"Quit"
														 action:@selector(actionQuit:)
											keyEquivalent:@"q"];
	[menuItem setTarget:self];

	return menu;
}

- (void)createMenuAccessibilityPermissionItems:(NSMenu *)menu
{
	accessibilityPermissionStatusItem = [menu addItemWithTitle:@"Missing Accessibility permission" action:nil keyEquivalent:@""];
	accessibilityPermissionActionItem = [menu addItemWithTitle:@"Open Privacy Preferences" action:@selector(openAccessibilitySettings:) keyEquivalent:@","];

	[menu addItem:[NSMenuItem separatorItem]];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
	NSMenu* menu = [self createMenu];

	NSImage* icon = [NSImage imageNamed:(@"StatusIcon")];
	[icon setSize:CGSizeMake(24, 24)];

	// Check if Darkmode menubar is supported and enable templating of the icon in
	// that case.

	BOOL oldBusted = (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9);
	if (!oldBusted) {
		// 10.10 or higher, so setTemplate: is safe
		[icon setTemplate:YES];
	}

	_statusItem = [[[NSStatusBar systemStatusBar]
									statusItemWithLength:24] retain];
	_statusItem.behavior = NSStatusItemBehaviorRemovalAllowed;
	_statusItem.menu = menu;
	_statusItem.button.toolTip = @"MiddleClick";
	_statusItem.button.image = icon;

	[self initAccessibilityPermissionStatus:menu];

	[menu release];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender
										hasVisibleWindows:(BOOL)flag
{
	_statusItem.visible = true;
	return 1;
}

@end
