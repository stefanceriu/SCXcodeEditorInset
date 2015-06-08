//
//  SCXcodeEditorInset.m
//  SCXcodeEditorInset
//
//  Created by Stefan Ceriu on 5/27/15.
//  Copyright (c) 2015 Stefan Ceriu. All rights reserved.
//

#import "SCXcodeEditorInset.h"
#import "DVTSourceTextView+SCXcodeEditorInset.h"

#import "IDESourceCodeEditor.h"
#import "IDEWorkspaceWindowController.h"

NSString *const kSCXcodeEditorBottomInsetPercentageKey = @"kSCXcodeEditorBottomInsetPercentageKey";

NSString *const SCXcodeEditorInsetNSTabViewDidChangeFrameNotification = @"SCXcodeEditorInsetNSTabViewDidChangeFrameNotification";
NSString *const SCXcodeEditorInsetDidChangeInsetNotification = @"SCXcodeEditorInsetDidChangeInsetNotification";

NSString *const IDESourceCodeEditorDidFinishSetupNotification = @"IDESourceCodeEditorDidFinishSetup";

NSString *const kViewMenuItemTitle = @"View";
NSString *const kEditorInsetMenuItemTitle = @"Editor Inset";
NSString *const kSizeMenuItemTitle = @"Size";

static SCXcodeEditorInset *sharedPlugin = nil;

@interface SCXcodeEditorInset ()

@property (nonatomic, weak) IDEWorkspaceWindowController *workspaceWindowController;
@property (nonatomic, assign) CGFloat editorInset;

@end

@implementation SCXcodeEditorInset

+ (void)pluginDidLoad:(NSBundle *)plugin
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
	
}

+ (SCXcodeEditorInset *)sharedPlugin
{
	return sharedPlugin;
}

- (id)init
{
	if (self = [super init]) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self createMenuItem];
		});
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{kSCXcodeEditorBottomInsetPercentageKey : @(0.3f)}];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEditorDidFinishSetup:) name:IDESourceCodeEditorDidFinishSetupNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTabViewDidChangeFrame:) name:SCXcodeEditorInsetNSTabViewDidChangeFrameNotification object:nil];
	}
	return self;
}

- (void)createMenuItem
{
	NSMenuItem *viewMenuItem = [[NSApp mainMenu] itemWithTitle:kViewMenuItemTitle];
	
	if(viewMenuItem == nil) {
		return;
	}
	
	[viewMenuItem.submenu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *editorInsetMenuItem = [[NSMenuItem alloc] initWithTitle:kEditorInsetMenuItemTitle action:nil keyEquivalent:@""];
	[viewMenuItem.submenu addItem:editorInsetMenuItem];
	
	
	NSMenu *editorInsetSubmenu = [[NSMenu alloc] init];
	{
		NSView *sizeView = [[NSView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 225.0f, 20.0f)];
		[sizeView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
		
		NSTextField *sizeViewTitleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f, 0.0f, 50.0f, 20.0f)];
		[sizeViewTitleLabel setStringValue:kSizeMenuItemTitle];
		[sizeViewTitleLabel setFont:[NSFont systemFontOfSize:14]];
		[sizeViewTitleLabel setBezeled:NO];
		[sizeViewTitleLabel setDrawsBackground:NO];
		[sizeViewTitleLabel setEditable:NO];
		[sizeViewTitleLabel setSelectable:NO];
		[sizeView addSubview:sizeViewTitleLabel];
		
		NSSlider *sizeSlider = [[NSSlider alloc] initWithFrame:CGRectMake(60.0f, 0.0f, 156.0f, 20.0f)];
		[sizeSlider setMaxValue:1.0f];
		[sizeSlider setMinValue:0.0f];
		[sizeSlider setTarget:self];
		[sizeSlider setAction:@selector(onSizeSliderValueChanged:)];
		[sizeSlider setDoubleValue:[[[NSUserDefaults standardUserDefaults] objectForKey:kSCXcodeEditorBottomInsetPercentageKey] doubleValue]];
		[sizeView addSubview:sizeSlider];
				
		NSMenuItem *editorInsetSizeMenuItem = [[NSMenuItem alloc] init];
		[editorInsetSizeMenuItem setView:sizeView];
		[editorInsetSubmenu addItem:editorInsetSizeMenuItem];
	}
	
	[editorInsetMenuItem setSubmenu:editorInsetSubmenu];
}

- (void)onSizeSliderValueChanged:(NSSlider *)sender
{
	NSEvent *event = [[NSApplication sharedApplication] currentEvent];
	if(event.type != NSLeftMouseUp) {
		return;
	}
		
	[[NSUserDefaults standardUserDefaults] setObject:@(sender.doubleValue) forKey:kSCXcodeEditorBottomInsetPercentageKey];
	[self updateEditorInset];
}

- (void)onEditorDidFinishSetup:(NSNotification*)sender
{
	self.workspaceWindowController = [[IDEWorkspaceWindowController workspaceWindowControllers] firstObject];
	[self updateEditorInset];
}

- (void)onTabViewDidChangeFrame:(NSNotification *)sender
{
	[self updateEditorInset];
}

- (void)updateEditorInset
{
	CGFloat bottomInsetPercentage = [[[NSUserDefaults standardUserDefaults] objectForKey:kSCXcodeEditorBottomInsetPercentageKey] floatValue];
	[self setEditorInset:CGRectGetHeight(self.workspaceWindowController.tabView.bounds) * bottomInsetPercentage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SCXcodeEditorInsetDidChangeInsetNotification object:nil];
}

@end
