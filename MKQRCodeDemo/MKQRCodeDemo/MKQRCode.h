//
//  DCQRCode.h
//  DCQRTest
//
//  Created by Mkil on 8/22/16.
//  Copyright © 2016 Mkil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MKQRCodeStyle)
{
    MKQRCodeStyleDefault                = 1,
    MKQRCodeStyleOuter                  = 1 << 1,
    MKQRCodeStyleInner                  = 1 << 2,
    MKQRCodeStyleCenterImage            = 1 << 3,
};


@interface MKQRCode : NSObject

@property(nonatomic, strong) NSString *info;
@property(nonatomic, assign) CGFloat size;

@property(nonatomic, strong) UIImage  *targetImg;
@property(nonatomic, strong) UIColor *backgroundColor;
@property(nonatomic, strong) UIColor *fillColor;

@property(nonatomic, strong) UIImage *centerImg;
@property(nonatomic, strong) UIColor *outerColor;
@property(nonatomic, strong) UIColor *innerColor;

@property(nonatomic, assign) MKQRCodeStyle style;

- (void)setInfo:(NSString *)info withSize:(CGFloat)size;

- (UIImage *)generateImage;


@end
