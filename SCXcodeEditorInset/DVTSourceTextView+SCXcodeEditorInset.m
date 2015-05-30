//
//  DVTSourceTextView+SCXcodeEditorInset.m
//  SCXcodeEditorInset
//
//  Created by Stefan Ceriu on 5/26/15.
//  Copyright (c) 2015 Stefan Ceriu. All rights reserved.
//

#import "DVTSourceTextView+SCXcodeEditorInset.h"
#import "SCXcodeEditorInsetCommon.h"
#import "SCXcodeEditorInset.h"

@implementation DVTSourceTextView (SCXcodeEditorInset)

+ (void)load
{
	sc_swizzleInstanceMethod([self class], @selector(initWithFrame:textContainer:), @selector(sc_initWithFrame:textContainer:));
	sc_swizzleInstanceMethod([self class], @selector(textContainerOrigin), @selector(sc_textContainerOrigin));
}

- (id)sc_initWithFrame:(CGRect)frame textContainer:(id)textContainer
{	
	[self sc_initWithFrame:frame textContainer:textContainer];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sc_bottomInsetDidChange:) name:SCXcodeEditorInsetDidChangeInsetNotification object:nil];
	
	return self;
}

- (NSPoint)sc_textContainerOrigin
{
	return CGPointZero;
}

- (void)sc_bottomInsetDidChange:(NSNotification *)sender
{
	[self sc_updateTextContainerBottomInset];
}

- (void)sc_updateTextContainerBottomInset
{
	NSInteger bottomInset = [[SCXcodeEditorInset sharedPlugin] editorInset] / 2.0f;
	
	if(self.textContainerInset.height == bottomInset) {
		return;
	}
	
	[self setTextContainerInset:NSMakeSize(0.0f, bottomInset)];
	[self.layoutManager textContainerChangedGeometry:self.textContainer];
}

@end
