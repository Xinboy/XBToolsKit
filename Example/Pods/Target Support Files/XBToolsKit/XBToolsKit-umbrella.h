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
#import "AFCompatibilityMacros.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "AFSecurityPolicy.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFURLSessionManager.h"
#import "AFAutoPurgingImageCache.h"
#import "AFImageDownloader.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UIImage+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UIProgressView+AFNetworking.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIWebView+AFNetworking.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "FMDB.h"
#import "FMResultSet.h"

FOUNDATION_EXPORT double XBToolsKitVersionNumber;
FOUNDATION_EXPORT const unsigned char XBToolsKitVersionString[];

