//
//  FMDBManager.h
//  XBKit
//
//  Created by Xinbo Hong on 2018/12/10.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kDefaultDBName = @"xinbo";


@interface XBFMDBManager : NSObject

/**
 *  @author Clarence
 *
 *  单例创建，项目唯一
 */
+ (instancetype)shareManager:(NSString *)dbName;

#pragma mark - --- 创建表 ---

/**
 根据类名创建表，如果有则跳过，没有才创建，执行完毕后自动关闭数据库

 @param modelClass 创建的类
 @return YES表示创建表格操作执行成功 或者 表格已经存在，NO则失败
 */
- (BOOL)createTable:(Class)modelClass;

#pragma mark - --- 插入数据 ---

/**
 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 如果没创建表就自动先创建，表名为模型类名
 此时执行完毕后自动关闭数据库

 @param model 模型或模型数组
 @return  YES表示创建表格操作执行成功 或者 表格已经存在，NO则失败
 */
- (BOOL)insertModel:(id)model;

#pragma mark - --- 查询 ---

/**
 查询指定类名对应的表是否存在，执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @return YES表示操作执行成功并且 modelClass 表格存在，NO则操作失败或者 modelClass 表格不存在
 */
- (BOOL)isExitTable:(Class)modelClass;


/**
 查找指定表中模型数组（所有的），执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @return 不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，
         nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 */
- (NSArray *)searchModelArray:(Class)modelClass;


/**
 根据判断条件，查找指定表中模型数组（所有的），执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @param whereDict 判断条件
 @return 不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，
         nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 */
- (id)searchModel:(Class)modelClass byWhere:(NSDictionary *)whereDict;


/**
 查找指定id的指定模型，执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @param ID 指定id
 @return 不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，
         nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 */
- (id)searchModel:(Class)modelClass byID:(NSString *)ID;

#pragma mark - --- 修改 ---


/**
 修改指定ID的指定模型，执行完毕后自动关闭数据库

 @param model 指定模型
 @param ID 指定id
 @return YES表示更新操作执行成功，NO则操作失败 或者 对应的表格不存在
 */
- (BOOL)modifyModel:(id)model byID:(NSString *)DBID;


/**
 修改符合判断条件的指定模型，执行完毕后自动关闭数据库

 @param model 指定模型
 @param whereDict 判断条件
 @return YES表示更新操作执行成功，NO则操作失败 或者 对应的表格不存在
 */
- (BOOL)modifyModel:(id)model byWhere:(NSDictionary *)whereDict;


#pragma mark - --- 删除 ---

/**
 删除数据库,执行完毕后自动关闭数据库

 @return 操作不涉及到数据库操作 YES 表示删除成功，NO则删除失败
 */
- (BOOL)dropDB;

/**
 删除对应模型的表,执行完毕后自动关闭数据库

 @param modelClass 指定模型表
 @return 操作不涉及到数据库操作 YES 表示删除成功，NO则删除失败
 */
- (BOOL)dropTable:(Class)modelClass;


/**
 删除指定表格的所有数据，执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 */
- (BOOL)deleteAllModel:(Class)modelClass;


/**
 删除指定表格的指定ID数据，执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @param ID 指定ID
 @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 */
- (BOOL)deleteModel:(Class)modelClass byID:(NSString *)ID;


/**
 删除指定表格的指定条件数据，执行完毕后自动关闭数据库

 @param modelClass 指定模型
 @param whereDict 指定条件
 @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 */
- (BOOL)deleteModel:(Class)modelClass byWhere:(NSDictionary *)whereDict;




@end
