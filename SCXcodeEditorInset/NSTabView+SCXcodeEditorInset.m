//
//  NSTabView+SCXcodeEditorInset.m
//  SCXcodeEditorInset
//
//  Created by Stefan Ceriu on 5/30/15.
//  Copyright (c) 2015 Stefan Ceriu. All rights reserved.
//

#import "NSTabView+SCXcodeEditorInset.h"
#import "SCXcodeEditorInsetCommon.h"
#import "SCXcodeEditorInset.h"

@implementation NSTabView (SCXcodeEditorInset)

+ (void)load
{
	sc_swizzleInstanceMethod([self class], @selector(resizeWithOldSuperviewSize:), @selector(sc_resizeWithOldSuperviewSize:));
}

- (void)sc_resizeWithOldSuperviewSize:(NSSize)oldSize
{
	[self sc_resizeWithOldSuperviewSize:oldSize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SCXcodeEditorInsetNSTabViewDidChangeFrameNotification object:self];
}

@end
