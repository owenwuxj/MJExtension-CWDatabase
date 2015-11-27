//
//  ViewController.m
//  libsqlite3_test
//
//  Created by xalo on 15/11/27.
//  Copyright (c) 2015年 c.w. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "MJExtension+CWDatabase.h"
#import "Student.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CWDatabase *db = [CWDatabase database];
//    db.fileName = @"test.sqlite";
//    db.tableName = @"infoList";
//    
//    Person *person = [[Person alloc]init];
//    person.name = @"zhangsan";
//    person.age = 10;
//    person.address = @"xian";
//    
//    Person *person1 = [[Person alloc]init];
//    person1.name = @"lisi";
//    person1.age = 31;
//    person1.address = @"beijing";
//    
//    Person *person2 = [[Person alloc]init];
//    person2.name = @"wangwu";
//    person2.age = 17;
//    person2.address = @"nanjing";
    
//    NSArray *arr = [NSArray arrayWithObjects:person,person1,person2, nil];
    
//    [db createTabeleForModel:person];
//    [db insertIntoTableWithArray:arr];
//    NSString *string = @"select * from infoList";
//    NSArray *resurltArr = [db getModelArrayWithSQLString:string AndClassName:@"Student"];
    
//    NSLog(@"%@",resurltArr);
    
    

    
    
}

- (void)sqlite
{
    
    CWDatabase *db = [CWDatabase database];
    db.tableName = @"test.sqlite";
    
    Person *person = [[Person alloc]init];
    person.name = @"zhangsan";
    person.age = 10;
    person.address = @"xian";

    
    [db executeUpdate:@"create table if not exists infoList(name text, age integer, address text)"];
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert into infoList(name,age)values('%@',%ld)",person.name,person.age];
    
    
    NSLog(@"insertSQL=%@",insertSQL);
    
    [db executeUpdate:insertSQL];
    
    
    NSArray *result = [db executeQuery:@"select * from infoList"];
    
    NSLog(@"result= %@",result);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
