//
//  SCXcodeEditorInset.h
//  SCXcodeEditorInset
//
//  Created by Stefan Ceriu on 5/27/15.
//  Copyright (c) 2015 Stefan Ceriu. All rights reserved.
//

extern NSString *const kSCXcodeEditorBottomInsetValueKey;

extern NSString *const SCXcodeEditorInsetNSTabViewDidChangeFrameNotification;
extern NSString *const SCXcodeEditorInsetDidChangeInsetNotification;

@interface SCXcodeEditorInset : NSObject

+ (SCXcodeEditorInset *)sharedPlugin;

@property (nonatomic, assign, readonly) CGFloat editorInset;

@end
