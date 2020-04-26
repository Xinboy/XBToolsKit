//
//  SingleObjectModule.m
//  XBCodingRepo
//
//  Created by Xinbo Hong on 2018/1/17.
//  Copyright © 2018年 Xinbo Hong. All rights reserved.
//

#import "SingleObjectModule.h"

@implementation SingleObjectModule


static SingleObjectModule *kSingleObject = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
    });
    return kSingleObject;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return kSingleObject;
}

- (id)mutableCopy {
    return kSingleObject;
}
@end
