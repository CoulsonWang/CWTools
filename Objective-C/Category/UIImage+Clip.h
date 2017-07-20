//
//  UIImage+Clip.h
//  图片裁剪
//
//  Created by Coulson_Wang on 2017/6/11.
//  Copyright © 2017年 YYWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Clip)

+ (UIImage *)imageWithName:(NSString *)imageName offset:(CGFloat)offset offsetColor:(UIColor *)offsetColor;

- (UIImage *)clipImageByOffset:(CGFloat)offset offsetColor:(UIColor *)offsetColor;

@end
