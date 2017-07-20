//
//  NSObject+Model.h
//  字典转模型
//
//  Created by Coulson_Wang on 2017/6/23.
//  Copyright © 2017年 YYWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Model)

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
