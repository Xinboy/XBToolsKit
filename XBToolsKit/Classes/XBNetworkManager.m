//
//  XBNetworkManager.m
//  XBToolsKit
//
//  Created by Xinbo Hong on 2019/11/26.
//

#import "XBNetworkManager.h"

#import <AFNetworking/AFNetworking.h>

@interface XBNetworkManager ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end



@implementation XBNetworkManager


- (void)uploadOperation:(NSArray *)localPathArray {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //这个就是控制同时上传几张图片的，如果是1的话就是串行队列了。我是4，是并行队列。
    queue.maxConcurrentOperationCount = 4;
    
    for (int i = 0; i < localPathArray.count; i++) {
        @autoreleasepool {
            NSString *imageName = [NSString stringWithFormat:@"up_%d.jpg",i];
            
            __weak __typeof(self)weakSelf = self;
            NSBlockOperation *uploadOpe = [NSBlockOperation blockOperationWithBlock:^{
                [weakSelf uploadTaskWithLocalId:localPathArray[i]  imageount:localPathArray.count imageName:imageName];
            }];
            [queue addOperation:uploadOpe];
        }
    }
    self.queue = queue;
    
}

- (void)uploadTaskWithLocalId:(NSString *)LocalId imageount:(NSInteger)count imageName:(NSString *)imageName {
    
    
    
}

- (void)uploadImage {

}
@end
