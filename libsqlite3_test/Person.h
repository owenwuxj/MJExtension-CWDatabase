//
//  Person.h
//  libsqlite3_test
//
//  Created by xalo on 15/11/27.
//  Copyright (c) 2015年 c.w. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, assign)NSUInteger age;
@property(nonatomic, copy)NSString *address;

@end
