//
//  AssistHeader.h
//  Pods
//
//  Created by Xinbo Hong on 2019/1/15.
//  常用的通用g宏

#ifndef AssistHeader_h
#define AssistHeader_h

/********** 单例宏定义 **********/
// .h
#define singleton_interface(class) + (instancetype)shared##class;
// .m
#define singleton_implementation(class) \
static class *kSingleObject = nil;\
+ (instancetype)sharedInstance {\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
kSingleObject = [[super allocWithZone:NULL] init];\
});\
return kSingleObject;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
return [self sharedInstance];\
}\
- (id)copy {\
return kSingleObject;\
}\
- (id)mutableCopy {\
return kSingleObject;\
}
/* 使用方式
 .h文件
 singleton_interface(Class)
 .m文件
 singleton_implementation(Class)
 */

/********** 个性化输出内容 **********/
#ifdef DEBUG
#define NSLog(fmt, ...) NSLog(@"\n------------------[Line %d] Begin-------------------------\n类和方法: %s\n信息内容: " fmt @"\n------------------[Line %d] End-------------------------\n",__LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__, __LINE__)
#else
#define NSLog(...)
#endif

/********** NSCoding 的自动归档解档 **********/
#define XBCodingRuntime_EncodeWithCoder(Class) \ unsigned int outCount = 0;\
Ivar *ivars = class_copyIvarList([Class class], &outCount);\ for (int i = 0; i < outCount; i++) {\
Ivar ivar = ivars[i];\ NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\
[aCoder encodeObject:[self valueForKey:key] forKey:key];\
}\
free(ivars);

#define XBCodingRuntime_InitWithCoder(Class)\ if (self = [super init]) {\ unsigned int outCount = 0;\
Ivar *ivars = class_copyIvarList([Class class], &outCount);\ for (int i = 0; i < outCount; i++) {\
Ivar ivar = ivars[i];\ NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\ id value = [aDecoder decodeObjectForKey:key];\ if (value) {\
[self setValue:value forKey:key];\
}\
}\
free(ivars);\
}\ return self;

/* 使用方式
 - (void)encodeWithCoder:(NSCoder *)aCoder {
 XBCodingRuntime_EncodeWithCoder(Father)
 }
 - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
 XBCodingRuntime_InitWithCoder(Father)
 }
 */

/********** NSCoding 的自动归档解档 **********/
#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
#define iOS8_10 (iOS8 && ([[UIDevice currentDevice].systemVersion doubleValue] <= 10.0))

#endif /* AssistHeader_h */
