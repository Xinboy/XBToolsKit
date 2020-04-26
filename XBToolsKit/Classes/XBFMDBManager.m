//
//  FMDBManager.m
//  XBKit
//
//  Created by Xinbo Hong on 2018/12/10.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import "XBFMDBManager.h"
#import <FMDB/FMDatabase.h>

#import <objc/runtime.h>


#define kCurrentDB (FMDatabase *)self.dataBaseDict[self.dbName]
@interface XBFMDBManager ()

@property (nonatomic, strong) NSMutableDictionary *dataBaseDict;

@property (nonatomic, strong) NSString *dbName;
@end


@implementation XBFMDBManager


+ (instancetype)shareManager:(NSString *)dbName {
    NSString *dbPAth = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    if ([dbName isEqualToString:@""] || dbName == nil) {
        dbName = kDefaultDBName;
    }
    
    NSString *filePath = [dbPAth stringByAppendingPathComponent:[dbName stringByAppendingString:@".sqlite"]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL tag = [manager fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    static FMDBManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dataBaseDict = [NSMutableDictionary dictionary];
        if (tag) {
            FMDatabase *database = [FMDatabase databaseWithPath:filePath];
            [instance.dataBaseDict setValue:database forKey:dbName];
        }
    });
    
    if (!tag) {
        [manager createDirectoryAtPath:dbPAth withIntermediateDirectories:YES attributes:nil error:NULL];
        // 通过路径创建数据库
        FMDatabase *dataBase = [FMDatabase databaseWithPath:filePath];
        [instance.dataBaseDict setValue:dataBase forKey:dbName];
    }
    
    instance.dbName = dbName;
    
    return instance;
    
}

#pragma mark - --- 创建表 ---
- (BOOL)createTable:(Class)modelClass {
    return [self createTable:modelClass autoCloseDB:YES];
}

#pragma mark --- 创建表方法的私有方法

- (BOOL)createTable:(Class)modelClass autoCloseDB:(BOOL)isAutoCloseDB {
    if ([kCurrentDB open]) {
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            if (isAutoCloseDB) {
                [kCurrentDB close];
            }
            return YES;
        } else {
            BOOL isSuccess = [kCurrentDB executeUpdate:[self createTableSQL:modelClass]];
            if (isAutoCloseDB) {
                [kCurrentDB close];
            }
            return isSuccess;
        }
    } else {
        return NO;
    }
}

- (NSString *)createTableSQL:(Class)modelClass{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT ",modelClass];
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(modelClass, &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([[key substringToIndex:1] isEqualToString:@"_"]) {
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        [sql appendFormat:@", %@",key];
    }
    [sql appendString:@")"];
    
    return sql;
}


#pragma mark - --- 插入方法 ---
- (BOOL)insertModel:(id)model {
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        NSArray *modelArray = (NSArray *)model;
        return [self insertWithModelArray:modelArray];
    } else {
        return [self insertWithModel:model autoCloseDB:YES];
    }
}

- (BOOL)insertWithModelArray:(NSArray *)modelArray {
    BOOL flag = YES;
    for (id model in modelArray) {
        if ([self insertWithModel:model autoCloseDB:NO]) {
            flag = NO;
        }
    }
    // 全部插入成功才返回YES
    [kCurrentDB close];
    
    return flag;
}

#pragma mark --- 插入方法的私有方法

- (BOOL)insertWithModel:(id)model autoCloseDB:(BOOL)isAutoCloseDB {
    
    NSAssert(![model isKindOfClass:[UIResponder class]], @"必须保证模型是NSObject或者NSObject的子类,同时不响应事件");
    if ([kCurrentDB open]) {
        
        // 此时有三步操作，第一步处理完不关闭数据库
        if (![self isExitTable:[model class] autoCloseDB:NO]) {
            // 没有表的时候，先创建再插入
            BOOL isSuccess = [self createTable:[model class] autoCloseDB:NO];
            if (isSuccess) {
                NSString *dbid = [model valueForKey:@"ID"];
                id judgeModel = [self searchModel:model byID:dbid autoCloseDB:NO];
                
                if ([[judgeModel valueForKey:@"ID"] isEqualToString:dbid]) {
                    BOOL isUpdateSuccess = [self modifyModel:model byWhere:@{@"ID":dbid} autoCloseDB:NO];
                    if (isAutoCloseDB) {
                        [kCurrentDB close];
                    }
                    return isUpdateSuccess;
                } else {
                    BOOL isInsertSuccess = [kCurrentDB executeUpdate:[self insertSQL:model]];
                    if (isAutoCloseDB) {
                        [kCurrentDB close];
                    }
                    return isInsertSuccess;
                }
            } else {
                // 第二步操作失败，询问是否需要关闭,可能是创表失败，或者是已经有表
                if (isAutoCloseDB) {
                    [kCurrentDB close];
                }
                return NO;
            }
        } else {
            // 已经有表，直接x插入
            NSString *dbid = [model valueForKey:@"ID"];
            id judgeModel = [self searchModel:model byID:dbid autoCloseDB:NO];
            
            if ([[judgeModel valueForKey:@"ID"] isEqualToString:dbid]) {
                BOOL isUpdateSuccess = [self modifyModel:model byWhere:@{@"ID":dbid} autoCloseDB:NO];
                if (isAutoCloseDB) {
                    [kCurrentDB close];
                }
                return isUpdateSuccess;
            } else {
                BOOL isInsertSuccess = [kCurrentDB executeUpdate:[self insertSQL:model]];
                if (isAutoCloseDB) {
                    [kCurrentDB close];
                }
                return isInsertSuccess;
            }
        }
    } else {
        return NO;
    }
}


- (NSString *)insertSQL:(id)model {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([[key substringToIndex:1] isEqualToString:@"_"]) {
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        if (i == 0) {
            [sql appendString:key];
        } else {
            [sql appendFormat:@", %@",key];
        }
        [sql appendString:@") VALUES ("];
        
        for (int i = 0; i < outCount ; i++) {
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            id value = [model valueForKey:key];
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSMutableDictionary class]] ||
                [value isKindOfClass:[NSArray class]] ||
                [value isKindOfClass:[NSMutableArray class]]) {
                value = [NSString stringWithFormat:@"%@",value];
            }
            if (i == 0) {
                value = [value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value]: value;
                [sql appendFormat:@"%@", value];
            } else {
                value = [value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value]: value;
                [sql appendFormat:@", %@", value];
            }
        }
    }
    [sql appendString:@");"];
    return sql;
}


#pragma mark - --- 判断表是否存在方法 ---
- (BOOL)isExitTable:(Class)modelClass {
    return [self isExitTable:modelClass autoCloseDB:YES];
}

#pragma mark 判断表是否存在方法的私有方法

- (BOOL)isExitTable:(Class)modelClass autoCloseDB:(BOOL)isAutoCloseDB {
    if ([kCurrentDB open]) {
        FMResultSet *rs = [kCurrentDB executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", modelClass];
        
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            
            if (isAutoCloseDB) {
                [kCurrentDB close];
            }
            if (count == 0) {
                return NO;
            } else {
                return YES;
            }
        }
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return NO;
    } else {
        return NO;
    }
}


#pragma mark - --- 查询方法 ---
- (NSArray *)searchModelArray:(Class)modelClass {
    return [self searchModelArray:modelClass autoCloseDB:YES];
}

- (id)searchModel:(Class)modelClass byID:(NSString *)ID {
    return [self searchModel:modelClass byID:ID autoCloseDB:YES];
}

#pragma mark --- 查询方法私有方法
- (id)searchModel:(Class)modelClass byWhere:(NSDictionary *)whereDict {
    return [self searchModel:modelClass byWhere:whereDict autoCloseDB:YES];
}

- (id)searchModel:(Class)modelClass byID:(NSString *)DBID autoCloseDB:(BOOL)isAutoCloseDB {
    return [self searchModel:modelClass byWhere:@{@"ID": DBID} autoCloseDB:YES];
}


//底层搜索数据
- (id)searchModel:(Class)modelClass byWhere:(NSDictionary *)whereDict autoCloseDB:(BOOL)isAutoCloseDB {
    if ([kCurrentDB open]) {
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            if (isAutoCloseDB) {
                [kCurrentDB close];
            }
            return nil;
        }
        //查询数据
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE ",modelClass];
        for (NSString *whereKey in [whereDict allKeys]) {
            [sql appendFormat:@"%@ = '%@'",whereKey,whereDict[whereKey]];
        }
        [sql appendString:@";"];
        FMResultSet *rs = [kCurrentDB executeQuery:sql];
        
        
        //创建对象
        id object = nil;
        //遍历结果集
        while ([rs next]) {
            object = [[modelClass class] new];
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] ||
                        [result isKindOfClass:[NSArray class]] ||
                        [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
        }
        
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return object;
    } else {
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return nil;
    }
    
}

- (NSArray *)searchModelArray:(Class)modelClass autoCloseDB:(BOOL)isAutoCloseDB {
    if ([kCurrentDB open]) {
        if (![self isExitTable:modelClass autoCloseDB:NO]) {
            return nil;
        }
        FMResultSet *rs = [kCurrentDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
        NSMutableArray *modelArray = [NSMutableArray array];
        //遍历结果集
        while ([rs next]) {
            //创建对象
            id object = [[modelClass class] new];
            
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] ||
                        [result isKindOfClass:[NSMutableDictionary class]] ||
                        [result isKindOfClass:[NSArray class]] ||
                        [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
            [modelArray addObject:object];
        }
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return modelArray;
    } else {
        return nil;
    }
}

#pragma mark - ---更新方法 ---
- (BOOL)modifyModel:(id)model byID:(NSString *)DBID {
    return [self modifyModel:model byWhere:@{@"ID": DBID} autoCloseDB:YES];
}

- (BOOL)modifyModel:(id)model byWhere:(NSDictionary *)whereDict {
    return [self modifyModel:model byWhere:whereDict autoCloseDB:YES];
}


#pragma mark --- 更新方法私有方法
- (BOOL)modifyModel:(id)model byWhere:(NSDictionary *)whereDict autoCloseDB:(BOOL)isAutoCloseDB {
    if ([kCurrentDB open]) {
        if ([self isExitTable:[model class] autoCloseDB:NO]) {
            if (isAutoCloseDB) {
                [kCurrentDB close];
            }
            return  NO;
        }
        // 修改数据@"UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList([model superclass], &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            id value = [model valueForKey:key];
            /**
             *  @author gitKong
             *
             *  防止属性没赋值
             */
            if (value == [NSNull null]) {
                value = @"";
            }
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]] ||
                [value isKindOfClass:[NSMutableArray class]]) {
                value = [NSString stringWithFormat:@"'%@'",value];
            }
            if (i == 0) {
                [sql appendFormat:@"%@ = %@", key, value];
            } else {
                [sql appendFormat:@", %@ = %@", key, value];
            }
        }
//        [sql appendFormat:@"WHERE id = '%@';",DBID];
        
        [sql appendFormat:@"WHERE "];
        
        for (NSString *whereKey in [whereDict allKeys]) {
            [sql appendFormat:@"%@ = '%@'",whereKey,whereDict[whereKey]];
        }
        [sql appendString:@";"];
        
        
        BOOL isSuccess = [kCurrentDB executeUpdate:sql];
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return isSuccess;
    } else {
        if (isAutoCloseDB) {
            [kCurrentDB close];
        }
        return NO;
    }
}

#pragma mark - ---删除方法 ---

- (BOOL)dropDB {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *sqlFilePath = [path stringByAppendingPathComponent:[self.dbName stringByAppendingString:@".sqlite"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:sqlFilePath error:NULL];
}


- (BOOL)dropTable:(Class)modelClass {
    if ([kCurrentDB open]) {
        if (![self isExitTable:modelClass autoCloseDB:NO]) {
            return NO;
        }
        
        NSMutableString*sql = [NSMutableString stringWithFormat:@"DROP TABLE %@;",modelClass];
        BOOL isSuccess = [kCurrentDB executeUpdate:sql];
        [kCurrentDB close];
        return isSuccess;
    } else {
        return NO;
    }
}


- (BOOL)deleteAllModel:(Class)modelClass {
    if ([kCurrentDB open]) {
        
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            return NO;
        }
        NSArray *modelArray = [self searchModelArray:modelClass autoCloseDB:NO];
        if (modelArray && modelArray.count) {
            NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@;", modelClass];
            BOOL isSuccess = [kCurrentDB executeUpdate:sql];
            [kCurrentDB close];
            return isSuccess;
        }
        return NO;
    } else {
        return NO;
    }
}

- (BOOL)deleteModel:(Class)modelClass byID:(NSString *)ID {
    [self deleteModel:modelClass byWhere:@{@"ID":ID}];
}

- (BOOL)deleteModel:(Class)modelClass byWhere:(NSDictionary *)whereDict {
    if ([kCurrentDB open]) {
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            return NO;
        }
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE ",modelClass];
        
        for (NSString *whereKey in [whereDict allKeys]) {
            [sql appendFormat:@"%@ = '%@'",whereKey,whereDict[whereKey]];
        }
        [sql appendString:@";"];
        
        BOOL isSuccess = [kCurrentDB executeUpdate:sql];
        [kCurrentDB close];
        return isSuccess;
    } else {
        return NO;
    }
}

@end
