//
//  UIImage+Clip.m
//  图片裁剪
//
//  Created by Coulson_Wang on 2017/6/11.
//  Copyright © 2017年 YYWang. All rights reserved.
//

#import "UIImage+Clip.h"

@implementation UIImage (Clip)

+ (UIImage *)imageWithName:(NSString *)imageName offset:(CGFloat)offset offsetColor:(UIColor *)offsetColor {
    //取得图片
    UIImage *image = [UIImage imageNamed:imageName];
    //图片宽度
    CGFloat imageW = image.size.width;
    //图片高度
    CGFloat imageH = image.size.height;
    //上下文尺寸
    CGSize contextSize = CGSizeMake(imageW + 2 * offset, imageH + 2 * offset);
    //手动创建一个Image上下文
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0);

    UIBezierPath *path;
    //判断图片横纵比，并绘制边框
    if (imageW > imageH) {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((imageW-imageH) / 2 , 0, imageH + 2 * offset, imageH + 2 * offset)];
    } else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, (imageH-imageW) / 2 , imageW + 2 * offset, imageW + 2 * offset)];
    }
    [offsetColor setFill];
    [path fill];
    //判断图片横纵比，并绘制图片
    if (imageW > imageH) {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((imageW - imageH) / 2 + offset, offset, imageH, imageH)];
    } else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(offset, (imageH-imageW) / 2 + offset, imageW, imageW)];
    }
    [path addClip];
    [image drawAtPoint:CGPointMake(offset, offset)];
    //获取生成的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)clipImageByOffset:(CGFloat)offset offsetColor:(UIColor *)offsetColor {

    //图片宽度
    CGFloat imageW = self.size.width;
    //图片高度
    CGFloat imageH = self.size.height;
    //上下文尺寸
    CGSize contextSize = CGSizeMake(imageW + 2 * offset, imageH + 2 * offset);
    //手动创建一个Image上下文
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0);
    
    UIBezierPath *path;
    //判断图片横纵比，并绘制边框
    if (imageW > imageH) {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((imageW-imageH) / 2 , 0, imageH + 2 * offset, imageH + 2 * offset)];
    } else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, (imageH-imageW) / 2 , imageW + 2 * offset, imageW + 2 * offset)];
    }
    [offsetColor setFill];
    [path fill];
    //判断图片横纵比，并绘制图片
    if (imageW > imageH) {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((imageW - imageH) / 2 + offset, offset, imageH, imageH)];
    } else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(offset, (imageH-imageW) / 2 + offset, imageW, imageW)];
    }
    [path addClip];
    [self drawAtPoint:CGPointMake(offset, offset)];
    //获取生成的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
