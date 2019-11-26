#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AssistHeader.h"
#import "AssistTools.h"
#import "BGLogation.h"
#import "BGTask.h"
#import "SingleObjectModule.h"
#import "XBCoreDataManager.h"
#import "XBFMDBManager.h"
#import "XBLocationManager.h"
#import "XBNetworkManager.h"
#import "XBSocketManager.h"
#import "XBTimerTarget.h"

FOUNDATION_EXPORT double XBToolsKitVersionNumber;
FOUNDATION_EXPORT const unsigned char XBToolsKitVersionString[];

