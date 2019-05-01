//
//  IATConstants.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/18/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IATErrorDomain @"TestAppErrorDomain"

#ifdef DEBUG
#define isDebugBuild            1
#else
#define isDebugBuild            0
#endif

#if isDebugBuild

#define IATLog(desc, ...) NSLog((desc), ##__VA_ARGS__)
#define IATMarker NSLog(@"Debug Marker at %@:%d(%@)", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, NSStringFromSelector(_cmd))

#else

#define IATLog
#define IATMarker

#endif

#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height

typedef void(^IATCallbackType)(void);
typedef void(^IATSuccessCallbackType)(BOOL success);
typedef void(^IATObjectCallbackType)(NSObject *object);
typedef void(^IATArrayCallbackType)(NSArray *array);
typedef void(^IATDictionaryCallbackType)(NSDictionary *dictionary);
typedef void(^IATDataCallbackType)(NSData *data);
typedef void(^IATErrorCallbackType)(NSError *error);
typedef void(^IATProgressCallbackType)(CGFloat progress);
