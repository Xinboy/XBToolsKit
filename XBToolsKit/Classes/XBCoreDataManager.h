//
//  CoreDataManager.h
//  Pods
//
//  Created by Xinbo Hong on 2019/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define CoreDataPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sqlite.db"]

@interface XBCoreDataManager : NSObject

@end

NS_ASSUME_NONNULL_END
