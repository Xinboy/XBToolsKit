//
//  TimerTarget.m
//  XBToolsKit
//
//  Created by Xinbo Hong on 2019/9/7.
//

#import "XBTimerTarget.h"

@interface XBTimerTarget ()

@property (nonatomic, weak) id target;

@property (nonatomic, assign) SEL selector;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation XBTimerTarget

- (void)timerTargetAction:(NSTimer *)timer {
    if (self.target) {
        IMP imp = [self.target methodForSelector:self.selector];
        void (*func)(id, SEL, NSTimer*) = (void *)imp;
        func(self.target, self.selector, timer);
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
