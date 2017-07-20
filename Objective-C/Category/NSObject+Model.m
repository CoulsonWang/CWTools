//
//  NSObject+Model.m
//  字典转模型
//
//  Created by Coulson_Wang on 2017/6/23.
//  Copyright © 2017年 YYWang. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/message.h>

@implementation NSObject (Model)

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    id object = [[self alloc] init];
    
    unsigned int count;
    //取得成员变量列表
    Ivar *ivarList = class_copyIvarList([object class], &count);
    //遍历成员变量列表
    for (int i = 0; i < count; i++) {
        //取得成员变量
        Ivar ivar = ivarList[i];
        //变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //去掉下划线，得到key名
        NSString *key = [ivarName substringFromIndex:1];
        //取得value
        id value = dict[key];
        //判断是否有值，有才赋值
        if (value) {
            //成员变量的类型
            NSString *typeString = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            //处理成员变量的类型名
            typeString = [[typeString stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""];
            //判断value是不是字典，成员变量是不是字典。若前者是而后者不是，则继续进行转换
            if ([value isKindOfClass:[NSDictionary class]] && !([typeString isEqualToString:@"NSDictionary"] || [typeString isEqualToString:@"NSMutableDictionary"])) {
                //递归调用字典转模型
                value = [NSClassFromString(typeString) modelWithDict:value];
            }
            //赋值
            [object setValue:value forKey:key];
        }
    }
    
    return object;
}

@end
