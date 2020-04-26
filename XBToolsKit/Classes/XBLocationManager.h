//
//  XBLocationManager.h
//  Pods-XBToolsKit_Example
//
//  Created by Xinbo Hong on 2019/1/15.
//  主要参考CTNetworking 框架

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, LocationServiceStatus) {
    //默认
    LocationServiceStatusDefault = 0,
    //正常
    LocationServiceStatusNormal,
    //未知错误
    LocationServiceStatusUnknowError,
    //系统定位关闭
    LocationServiceStatusClosed,
    //用户不允许使用定位
    LocationServiceStatusDenied,
    //没有网络
    LocationServiceStatusNoNetwork,
    //用户还没做出是否要允许应用使用定位功能的决定，
    //第一次安装应用的时候会提示用户做出是否允许使用定位功能的决定
    LocationServiceStatusNotDetermined,
};

typedef NS_ENUM(NSInteger, LocationResult) {
    //默认
    LocationResultDefault = 0,
    //定位中
    LocationResultLocating,
    //定位成功
    LocationResultSuccess,
    //定位失败
    LocationResultFailed,
    //调用API参数有误
    LocationResultParamsError,
    //超时
    LocationResultTimeout,
    //没有网络
    LocationResultNoNetwork,
    //API没有返回/返回数据有误
    LocationResultNoContent,
};

@interface XBLocationManager : NSObject

@property (nonatomic, assign, readonly) LocationResult locationResult;

@property (nonatomic, assign, readonly) LocationServiceStatus locationStatus;

@property (nonatomic, copy, readonly) CLLocation *location;

+ (instancetype)sharedManager;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;

+ (void)showDeniedAlertController;
@end
