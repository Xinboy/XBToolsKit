//
//  CoreDataManager.h
//  Pods
//
//  Created by Xinbo Hong on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

#define CoreDataPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sqlite.db"]
#define ModelName @"Model"
@interface XBCoreDataManager : NSObject {
    //数据模型对象
    NSManagedObjectModel *_managedObjectModel;
    //创建本地持久文件对象
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    //管理数据对象
    NSManagedObjectContext *_managedObjectContext;
}

+ (instancetype)sharedManager;

/**
 添加数据
 
 @param modelName 实例名
 @param params 添加的数据
 @return 是否添加成功
 */
- (BOOL)insertDataWithModelName:(NSString *)modelName
           setAttributeWithDict:(NSDictionary *)params;

/**
 根据条件输出数据
 
 @param modelName 实例名
 @param predicateString 判断条件
 @param identifers 排序字段集合
 @param ascending 是否升序
 @return 输出数据
 */
- (NSArray *)selectDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                                sort:(NSArray *)identifers
                           ascending:(BOOL)ascending;



/**
 根据判断条件更新数据
 
 @param modelName 实例名
 @param predicateString 判断条件
 @param params 新数据字典
 @return 是否成功
 */
- (BOOL)updateDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString
             setAttributWithDic:(NSDictionary *)params;

/**
 根据判断条件删除数据
 
 @param modelName 实例名
 @param predicateString 判断条件
 @return 是否成功
 */
- (BOOL)deleteDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString;

/**
 CoreData：根据相关条件，从对应的实例中获取数据数组
 
 @param predicate 判断条件
 @param entityName 实例名
 @return 匹配的数据数组
 */
- (NSArray *)arrayWithDataFromCoreDataWithPredicate:(NSPredicate *)predicate andEntityName:(NSString *)entityName;

/**
 CoreData：保存数据
 */
- (void)save:(NSError **)error;

/**
 CoreData：删除数据
 */
- (void)deleteObject:(NSManagedObject *)object;

@end

NS_ASSUME_NONNULL_END
