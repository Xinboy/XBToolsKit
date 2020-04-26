//
//  CoreDataManager.m
//  Pods
//
//  Created by Xinbo Hong on 2019/1/15.
//

#import "XBCoreDataManager.h"

@implementation XBCoreDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSError *error;
        
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:ModelName withExtension:@"model"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        NSURL *fileUrl = [NSURL fileURLWithPath:CoreDataPath];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:fileUrl options:nil error:&error];
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    }
    return self;
}

+ (instancetype)sharedManager {
    static XBCoreDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XBCoreDataManager alloc] init];
    });
    return instance;
    
}

- (BOOL)insertDataWithModelName:(NSString *)modelName setAttributeWithDict:(NSDictionary *)params {
    NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:_managedObjectContext];
    
    NSManagedObject *entityObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
    
    for (NSString *key in params) {
        [entityObject setValue:params[key] forKey:key];
//        SEL seletor = [self setFuntionWithKeyName:key];
//        if ([entityObject respondsToSelector:seletor]) {
//
//            [entityObject performSelector:seletor withObject:params[key]];
//        }
    }
    [_managedObjectContext insertObject:entityObject];
    
    return [_managedObjectContext save:nil];
}


- (NSArray *)selectDataWithModelName:(NSString *)modelName
                     predicateString:(NSString *)predicateString
                                sort:(NSArray *)identifers
                           ascending:(BOOL)ascending {
    NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:modelName];
    
    if (predicateString != nil && ![predicateString isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        fetchRequest.predicate = predicate;
    }
    
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    for (NSString *identifier in identifers) {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:identifier ascending:ascending];
        [sortDescriptors addObject:sort];
    }
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    return [_managedObjectContext executeFetchRequest:fetchRequest error:nil];

}

// 修改
- (BOOL)updateDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString
             setAttributWithDic:(NSDictionary *)params {
    NSArray *entitys = [self selectDataWithModelName:modelName predicateString:predicateString sort:nil ascending:NO];
    
    for (NSEntityDescription *entity in entitys) {
        NSManagedObject *entityObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
        for (NSString *key in params) {
            [entityObject setValue:params[key] forKey:key];
//            SEL seletor = [self setFuntionWithKeyName:key];
//            if ([entityObject respondsToSelector:seletor]) {
//
//                [entityObject performSelector:seletor withObject:params[key]];
//            }
        }
    }
    return [_managedObjectContext save:nil];
}

// 删除
- (BOOL)deleteDataWithModelName:(NSString *)modelName
                predicateString:(NSString *)predicateString {
    NSArray *entitys = [self selectDataWithModelName:modelName predicateString:predicateString sort:nil ascending:NO];
    for (NSEntityDescription *entity in entitys) {
        NSManagedObject *entityObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
        [_managedObjectContext deleteObject:entityObject];
    }
    return [_managedObjectContext save:nil];
}

// 通过一个字符串返回一个set方法
- (SEL)setFuntionWithKeyName:(NSString *)keyName {
    NSString *first = [[keyName substringFromIndex:1] uppercaseString];
    NSString *end = [keyName substringFromIndex:1];
    NSString *selString = [NSString stringWithFormat:@"set%@%@:",first,end];
    return NSSelectorFromString(selString);
}


- (NSArray *)arrayWithDataFromCoreDataWithPredicate:(NSPredicate *)predicate andEntityName:(NSString *)entityName {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    NSManagedObjectContext *context = _managedObjectContext;
    return [context executeFetchRequest:request error:nil];
}

- (void)save:(NSError **)error {
    [_managedObjectContext save:error];
}

- (void)deleteObject:(NSManagedObject *)object {
    [_managedObjectContext deleteObject:object];
}
@end
