//
//  SocketManager.h
//  XBKit
//
//  Created by Xinbo Hong on 2018/10/10.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XBSocketManager : NSObject

+ (instancetype)sharedSocket;

- (BOOL)connect;
- (BOOL)reconnect;
- (void)disConnect;

- (void)sendMsg:(NSString *)msg;
- (void)pullMsg;

@end
