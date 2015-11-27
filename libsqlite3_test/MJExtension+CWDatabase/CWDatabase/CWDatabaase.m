//
//  DatabaaseHandle.m
//  UI_Lesson_16
//
//  Created by xalo on 15/9/21.
//  Copyright (c) 2015年 蓝欧科技. All rights reserved.
//

#import "CWDatabase.h"

@interface CWDatabase ()

//根据数据库文件的存储路径来打开数据库,返回被打开的数据库的指针
- (sqlite3 *)openDatabase;

//根据数据库文件的名称来返回数据库文件在沙盒中的存储路径
- (NSString *)databaseFilePathWithName:(NSString *)name;

//关闭数据库
- (BOOL)closeDatabase:(sqlite3 *)database;


@end

@implementation CWDatabase

- (NSArray *)getModelArrayWithSQLString:(NSString *)SQLString AndClassName:(id)ModelClass
{
    //得到查询返回的字典数组
    NSArray *array = [self executeQuery:SQLString];
    //定义可变数组用于返回
    NSMutableArray *resultArr = [NSMutableArray array];
    //遍历数组中的每一个字典
    for (NSDictionary *dict in array) {
       
        //定义传入的模型对象
        id aClass = [[NSClassFromString(ModelClass) alloc]init];
         //遍历每一个字典的所有key-value值
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
//            [aClass setValue:obj forKey:key];//取得时候判断类型难度太大
            
//        NSLog(@"key:%@  value:%@",key,obj);
        }];
        
        //加入结果数组
        [resultArr addObject:aClass];
        
        
    }
    return resultArr;
}


/**
 *  通过模型的所有属性和表名建表
 */
- (void)createTabeleForModel:(id)model
{
    __block NSString *tabelSQL = [NSString string];
    [model enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        if (ivar.isSrcClassFromFoundation) return;
        NSString *keyName = [ivar.name substringFromIndex:1];
        
        tabelSQL = [tabelSQL stringByAppendingFormat:@"%@ text,",keyName];
    }];
    tabelSQL = [tabelSQL substringToIndex:tabelSQL.length-1];
    
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(%@)",self.tableName,tabelSQL];
    [self executeUpdate:createSQL];
}

/**
 *  插入单个模型到数据库
 */
- (void)insertIntoTableWithObject:(id)object
{
    //定义数组单独放key和value
    NSMutableArray *keyArr = [NSMutableArray array];
    NSMutableArray *valueArr = [NSMutableArray array];
    //枚举对象的所有key-value
    [object enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        if (ivar.isSrcClassFromFoundation) return;
        NSString *keyName = [ivar.name substringFromIndex:1];
        NSString *value = [NSString stringWithFormat:@"%@",ivar.value];
        //加入数组
        [keyArr addObject:keyName];
        [valueArr addObject:value];
        
    }];
    //遍历key数组和value数组
    NSString *objectName = [NSString string];
    NSString *valueName = [NSString string];
    
    for (int i = 0; i < keyArr.count; i++) {
        objectName = [objectName stringByAppendingFormat:@"%@,",keyArr[i]];
        valueName = [valueName stringByAppendingFormat:@"'%@',",valueArr[i]];
    }
    objectName = [objectName substringToIndex:objectName.length-1];
    valueName = [valueName substringToIndex:valueName.length-1];
    
    //得到insert的SQL语句
    NSString *insertSQL = [NSString stringWithFormat:@"insert into %@(%@)values(%@)",self.tableName,objectName,valueName];
    //插入数据到本地
    [self executeUpdate:insertSQL];
}

/**
 *  插入模型数组到数据库
 */
- (void)insertIntoTableWithArray:(NSArray *)modelArray
{
    for (id object in modelArray) {
        [self insertIntoTableWithObject:object];
    }
}


#pragma mark Database Operation-
- (NSString *)databaseFilePathWithName:(NSString *)name{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:name];
    
    if (![filePath hasSuffix:@".sqlite"]){
        filePath = [filePath stringByAppendingString:@".sqlite"];
    }
    NSLog(@"%@",filePath);
    return filePath;
}



-(sqlite3 *)openDatabase{
    NSString *filePath = [self databaseFilePathWithName:self.fileName];
    //声明sqlite3类型的数据库指针变量
    sqlite3 *database = NULL;
    //sqlite3_open(a,b)是打开数据库的函数,第一个参数是c语言字符串描述的文件路径,第二个参数是需要保持数据库指针的指针变量的地址,返回值为BOOL,用来描述是否打开成功
    int result =  sqlite3_open(filePath.UTF8String, &database);
    if (result == 0) {
        return  database;
    }
    return NULL;
}


-(BOOL)closeDatabase:(sqlite3 *)database{
    if (!database) {
        return NO;
    }
    //给定指针database指向的数据库关闭,并返回结果
    BOOL result = sqlite3_close(database);
    database = NULL;
    return result;
}


#pragma mark SQL Statement execuate-

-(BOOL)executeUpdate:(NSString *)SQLString{
    //1.打开数据库
    sqlite3 *database = [self openDatabase];
    //2.执行SQL语句
    int result = sqlite3_exec(database, SQLString.UTF8String, NULL, NULL, NULL);
    //3.关闭数据库
    [self closeDatabase:database];
    //此处因为sqlite3_exec函数返回值类型是一个int型,并且有多个宏定义.
    return result == 0?YES:NO;
}


-(NSArray *)executeQuery:(NSString *)SQLString{
    //1.打开数据库
    sqlite3 *database = [self openDatabase];
    //2.声明数据集指针变量
    sqlite3_stmt *statement = NULL;
    //3.检查SQL语句,并将检查无误的SQL写入到数据集指针中 (第三个参数-1为最大值)
    int result = sqlite3_prepare(database, SQLString.UTF8String, (int)SQLString.length, &statement, NULL);

    //4.用于保存所有查询得到的记录的数组
    NSMutableArray *queryList = [NSMutableArray array];
    if (result == SQLITE_OK) {
        while (sqlite3_step(statement)==SQLITE_ROW) {
            //如果执行完step函数,statement指针中就保存一条完整记录,并返回
            int columnCount = sqlite3_column_count(statement);
            //创建一个字典用于封装一条记录的各个字段值
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i=0; i<columnCount; i++) {
                //获取字段名称
                const char *columnName = sqlite3_column_name(statement, i);
                NSString *key = [NSString stringWithCString:columnName encoding:NSUTF8StringEncoding];
                //获取当前字段的数据类型
                int type = sqlite3_column_type(statement, i);
                switch (type) {
                    case SQLITE_INTEGER:
                    {
                        int value = sqlite3_column_int(statement, i);
                        [dict setObject:[NSNumber numberWithInt:value] forKey:key];
                        break;
                    }
                    case SQLITE_TEXT:
                    {
                        const unsigned char *value = sqlite3_column_text(statement, i);
                        NSString *valueObject = [NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding];
                        [dict setObject:valueObject forKey:key];
                        break;
                    }
                    case SQLITE_FLOAT:
                    {
                        float value = sqlite3_column_double(statement, i);
                       
                        [dict setObject:[NSNumber numberWithFloat:value] forKey:key];
                        break;
                    }


                        
                    default:
                        break;
                }
            }
            [queryList addObject:dict];
        }
    }
    //5.关闭数据库
    [self closeDatabase:database];
    //6.释放数据集指针所占的内存
    sqlite3_finalize(statement);
    
    return queryList;
}


//单例方法的实现
//单例唯一不受内存限制,后面不加autorelease
+(id)database{
    static CWDatabase *db = nil;
    if (!db) {
        db = [[self alloc]init];
    }
    return db;
}




@end
