//
//  SocketManager.m
//  XBKit
//
//  Created by Xinbo Hong on 2018/10/10.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import "SocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>


static  NSString * kHost = @"127.0.0.1";
static const uint16_t kPort = 6969;
static const NSInteger kMaxReConnCount = 5;

static NSString *const kHeaderIdentifier = @"ab";
static NSString *const kFooterIdentifier = @"7b";

typedef void(^SocketDataBlock)(NSMutableArray *);

@interface SocketManager()<GCDAsyncSocketDelegate> {
    GCDAsyncSocket *gcdSocket;
    NSMutableData *_currentData;
    NSMutableArray *_lastMessage;
}

//检测心跳的定时器
@property (nonatomic, strong) NSTimer *heartBeatTimer;
//断线重连当前次数
@property (nonatomic, assign) NSInteger reconnCount;
//断线重连定时器
@property (nonatomic, strong) NSTimer *reconnTimer;
//是否是断线重连状态
@property (nonatomic, assign, getter = isReconning) BOOL reconning;

@end


@implementation SocketManager

static SocketManager *instance = nil;
+ (instancetype)sharedSocket {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initSocket];
        instance.reconning = NO;
    });
    return instance;
}


- (void)initSocket {
    gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0,0)];
}

#pragma mark - 操作发送心跳包定时器
- (void)openTimer {
    [self closeTimer];
    if (self.heartBeatTimer == nil || !self.heartBeatTimer) {
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(heartCheck) userInfo:nil repeats:YES];
    }
    
}

- (void)closeTimer {
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer = nil;
}

- (void)heartCheck {
    [self sendMsg:@"心跳包内容"];
}


#pragma mark - 断线重连
- (void)startReconnect {
    [self cancelReconnect];
    
    self.reconnTimer = [NSTimer scheduledTimerWithTimeInterval:5 * (self.reconnCount + 1) target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    
}

- (void)reconnect {
    if ([gcdSocket isConnected]) {
        return;
    }
    if (self.reconnCount == kMaxReConnCount) {
        //达到最高重连次数，判断失败
        [self cancelReconnect];
    } else {
        self.reconnCount++;
    }
    [self connect];
}

- (void)cancelReconnect {
    [self.reconnTimer invalidate];
    self.reconnTimer = nil;
    self.reconning = NO;
}

#pragma mark - 防止粘包

- (void)appendingData:(id)data newData:(SocketDataBlock)block {
    //1、拼接二进制数据
    [_currentData appendData:data];
    //2、转化成字符串
    NSString *string = [[NSString alloc] initWithData:_currentData encoding:NSUTF8StringEncoding];
    NSLog(@"socket 收到的数据data = %@",string);
    //3、分割字符串
    NSArray *stringArr = [string componentsSeparatedByString:@"\n"];
    NSMutableArray *usefulStringArr = [NSMutableArray new];
    //4、获取有用的字符串
    for (NSString *str in stringArr) {
        if ([str hasPrefix:@"{"] && [str hasSuffix:@"}"]) {
            [usefulStringArr addObject:str];
            
        }
        
    }
    //5、判断有没有新的字符串
    NSMutableArray *newStringArr = [NSMutableArray new];
    for (NSString *str in usefulStringArr) {
        if (![_lastMessage containsObject:str]) {
            [newStringArr addObject:str];
            
        }
        
    }
    //6、返回新的字符串 保存老的数组
    _lastMessage = usefulStringArr;
    block([self modelArrayFrom:newStringArr]);
    _currentData = data;
}


- (NSMutableArray *)modelArrayFrom:(NSMutableArray *)stringArray {
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSString *string in stringArray) {
        //处理信息
    }
    return modelArray;
}

#pragma mark - 对外的一些接口
- (BOOL)connect {
    if (gcdSocket isConnected) {
        return YES;
    }
    NSError *error = nil;
    BOOL isSuccess =[gcdSocket connectToHost:Khost onPort:Kport error:&error];
    if (error) {
        NSLog(@"connect error: %@", error);
    }
    return isSuccess;
}

- (void)disConnect{
    if ([gcdSocket isConnected]) {
        [gcdSocket disconnect];
    }
    
}

     NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    //第二个参数，请求超时时间
    [gcdSocket writeData:data withTimeout:-1 tag:110];
    
}

- (void)pullMsg {
    //监听读数据的代理  -1永远监听，不超时，但是只收一次消息，
    //监听读数据的代理，只能监听10秒，10秒过后调用代理方法  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [gcdSocket readDataWithTimeout:-1 tag:110];
}
#pragma mark - GCDAsyncSocketDelegate

//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    
    [self pullMsg];
    
    //如果是断线重连，则取消
    if (self.isReconning) {
        [self cancelReconnect];
    }
    //心跳写在这...
    [self openTimer];
}

//连接失败调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //断线重连写在这...
    [self startReconnect];
}

//写成功的回调
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag {
    NSLog(@"写的回调,tag:%ld",tag);
}

//收到消息的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@",msg);
    
    [self pullMsg];
}

@end
