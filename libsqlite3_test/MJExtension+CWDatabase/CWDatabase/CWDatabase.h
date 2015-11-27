//
//  DatabaaseHandle.h
//  UI_Lesson_16
//
//  Created by xalo on 15/9/21.
//  Copyright (c) 2015年 蓝欧科技. All rights reserved.
//

#import "MJExtension.h"
#import <Foundation/Foundation.h>
#import <sqlite3.h>//引入Sqlite3.h头文件

//此类的作用就是封装sqlite3的函数调用,以OC方法调用的形式去操作数据库

@interface CWDatabase : NSObject

/**数据库的名称 */
@property(nonatomic, copy)NSString *fileName;

/**表名 */
@property(nonatomic, copy)NSString *tableName;




/**单例方法的声明 */
+(id)database;

/**建表 */
- (void)createTabeleForModel:(id)model;

/**执行SQL语句的方法,返回值为执行成功或者失败 */
- (BOOL)executeUpdate:(NSString *)SQLString;

/**执行查询语句的方法,返回值为查询的记录组成的数组*/
- (NSArray *)executeQuery:(NSString *)SQLString;

/**插入单个模型到数据库 */
- (void)insertIntoTableWithObject:(id)object;

/**插入模型数组到数据库 */
- (void)insertIntoTableWithArray:(NSArray *)modelArray;

/**拿出查询的模型,返回一个数组 */
- (NSArray *)getModelArrayWithSQLString:(NSString *)SQLString AndClassName:(NSString *)ModelClass;
@end
