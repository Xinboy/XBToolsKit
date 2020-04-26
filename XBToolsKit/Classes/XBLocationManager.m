//
//  XBLocationManager.m
//  Pods-XBToolsKit_Example
//
//  Created by Xinbo Hong on 2019/1/15.
//

#import "XBLocationManager.h"

@interface XBLocationManager ()<CLLocationManagerDelegate>


@property (nonatomic, assign, readwrite) LocationResult locationResult;

@property (nonatomic, assign, readwrite) LocationServiceStatus locationStatus;

@property (nonatomic, copy, readwrite) CLLocation *location;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation XBLocationManager

+ (instancetype)sharedManager {
    static XBLocationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XBLocationManager alloc] init];
    });
    return instance;
}

- (void)startLocation {
    if ([self checkLocationStatus]) {
        self.locationResult = LocationResultLocating;
        [self.locationManager startUpdatingLocation];
    } else {
        [self failedLocationWithResultType:LocationResultFailed statusType:self.locationStatus];
    }
}

- (void)stopLocation {
    if ([self checkLocationStatus]) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)restartLocation {
    [self stopLocation];
    [self startLocation];
}

+ (void)showDeniedAlertController {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"友情提醒", nil) message:NSLocalizedString(@"我们需要通过您的地理位置信息获取您周边的相关数据", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"允许", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:cancelAction];
    [alertC addAction:settingAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - --- Delegate ---
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    self.location = [manager.location copy];
    NSLog(@"Current location is %@", self.location);              
    [self stopLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //如果用户还没选择是否允许定位，则不认为是定位失败
    if (self.locationStatus == LocationServiceStatusNotDetermined) {
        return;
    }
    //如果正在定位中，那么也不会通知到外面
    if (self.locationResult == LocationResultLocating) {
        return;
    }
    //
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationStatus = LocationServiceStatusNormal;
        [self restartLocation];
    } else {
        if (self.locationStatus != LocationServiceStatusNotDetermined) {
            [self failedLocationWithResultType:LocationResultDefault statusType:LocationServiceStatusDenied];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark - --- Private Methods ---
- (void)failedLocationWithResultType:(LocationResult)result
                          statusType:(LocationServiceStatus)status {
    self.locationResult = result;
    self.locationStatus = status;
}

- (BOOL)checkLocationStatus {
    BOOL result = NO;
    BOOL serviceEnable = [self locationServiceEnabled];
    LocationServiceStatus authStatus = [self locationServiceStatus];
    if (authStatus == LocationServiceStatusNormal && serviceEnable) {
        result = YES;
    } else if (authStatus == LocationServiceStatusNotDetermined) {
        result = YES;
    } else {
        return NO;
    }
    
    if (serviceEnable && result) {
        result = YES;
    } else {
        result = NO;
    }
    
    if (!result) {
        [self failedLocationWithResultType:LocationResultFailed statusType:self.locationStatus];
    }

    return result;
}


- (BOOL)locationServiceEnabled {
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationStatus = LocationServiceStatusNormal;
        return YES;
    } else {
        self.locationStatus = LocationServiceStatusUnknowError;
        return NO;
    }
}

- (LocationServiceStatus)locationServiceStatus {
    self.locationStatus = LocationServiceStatusUnknowError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        switch (authStatus) {
            case kCLAuthorizationStatusNotDetermined:
                self.locationStatus = LocationServiceStatusNotDetermined;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationStatus = LocationServiceStatusNormal;
                break;
            case kCLAuthorizationStatusDenied:
                self.locationStatus = LocationServiceStatusDenied;
                break;
                
            default:
                break;
        }
    } else {
        self.locationStatus = LocationServiceStatusClosed;
    }
    return self.locationStatus;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}
@end
