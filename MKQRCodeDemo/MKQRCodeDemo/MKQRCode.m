//
//  DCQRCode.m
//  DCQRTest
//
//  Created by Mkil on 8/22/16.
//  Copyright © 2016 Mkil. All rights reserved.
//

#import "MKQRCode.h"

typedef NS_ENUM(NSInteger, MKQRPosition)
{
    TopLeft,
    TopRight,
    BottomLeft,
    Center,
    QuietZone
};

static const CGFloat innerPositionTileOriginWidth = 3;
static const CGFloat outerPositionPathOriginLength = 6;
static const CGFloat outerPositionTileOriginWidth = 7;

@implementation MKQRCode
{
    CIImage *_outPutImage;
}


- (instancetype)init
{
    if (self = [super init]) {
        //默认值
        _info = @"http://mkiltech.com";
        _backgroundColor = [UIColor whiteColor];
        _fillColor = [UIColor blackColor];
    }
    return self;
}

- (void)setInfo:(NSString *)info withSize:(CGFloat)size
{
    _info = info;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectMake(0, 0, size, size);
    _size = CGRectGetWidth(rect) * scale;

}


- (UIImage *)generateImage
{
    
    [self generateQRCodeFilter];
    
    UIImage *OriginalImg = [self createNonInterpolatedUIImageFormCIImage:_outPutImage withSize:_size];
    
    UIGraphicsBeginImageContextWithOptions(OriginalImg.size, NO, [[UIScreen mainScreen] scale]);
    [OriginalImg drawInRect:CGRectMake(0,0 , _size, _size)];

    if (_style & MKQRCodeStyleOuter) {
        
        [self changeOuterPositionColor:_outerColor withPosition:TopLeft];
        [self changeOuterPositionColor:_outerColor withPosition:TopRight];
        [self changeOuterPositionColor:_outerColor withPosition:BottomLeft];
    }
    
    if (_style & MKQRCodeStyleInner) {
        
        CIImage *coreImage = [CIImage imageWithColor:[CIColor colorWithCGColor:_innerColor.CGColor]];
        CIFilter *cifiter = [CIFilter filterWithName:@"CICrop"];
        [cifiter setValue:[CIVector vectorWithX:0
                                              Y:0
                                              Z:10
                                              W:10]
                   forKey:@"inputRectangle"];
        [cifiter setValue:coreImage forKey:@"inputImage"];
        CIImage* filteredImage = cifiter.outputImage;
        UIImage* colorImage = [UIImage imageWithCIImage:filteredImage];
        
        [self changePositionInnerColor:colorImage withPosition:TopLeft];
        [self changePositionInnerColor:colorImage withPosition:TopRight];
        [self changePositionInnerColor:colorImage withPosition:BottomLeft];
    }
    
    if (_style & MKQRCodeStyleCenterImage) {
        
        [self changePositionInnerColor:_centerImg withPosition:Center];
    }
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

- (void)generateQRCodeFilter
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [_info dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];//通过kvo方式给一个字符串，生成二维码
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];//设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    
    CIColor *color1 = [CIColor colorWithCGColor:_fillColor.CGColor];
    CIColor *color2 = [CIColor colorWithCGColor:_backgroundColor.CGColor];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: filter.outputImage ,@"inputImage",
                                color1,@"inputColor0",
                                color2,@"inputColor1",nil];
    CIFilter *newFilter = [CIFilter filterWithName:@"CIFalseColor" withInputParameters:parameters];
    
    _outPutImage = [newFilter outputImage]; //拿到二维码图片
}

- (CGFloat)fetchVersion {
    
    return ((_outPutImage.extent.size.width - 21)/4.0 + 1);
}


- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    //创建一个DeviceRGB颜色空间
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    //CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
    //width：图片宽度像素
    //height：图片高度像素
    //bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
    //bitmapInfo：指定的位图应该包含一个alpha通道。
    //    CGBitmapInfo *bitmapInfo = CGBitmapInfo(CGImageAlphaInfo);
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CIContext *context = [CIContext contextWithOptions:nil];
    //创建CoreGraphics image
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef); CGImageRelease(bitmapImage);
    
    //原图
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    return outputImage;
}

- (void)changeOuterPositionColor:(UIColor *)color withPosition:(MKQRPosition)position {
    
    UIBezierPath *path = [self outerPositionPathWidth:_size withVersion:[self fetchVersion] wihtPosition:position];
    [color setStroke];
    [path stroke];
}
- (void)changeOuterPositionStyle:(UIImage *)image withPosition:(MKQRPosition)position{
    
    CGRect rect = [self outerPositionRectWidth:_size withVersion:[self fetchVersion] wihtPosition:position];
    [image drawInRect:rect];
}


- (void)changePositionInnerColor:(UIImage *) image withPosition:(MKQRPosition)position{
    
    CGRect rect = [self innerPositionRectWidth:_size withVersion:[self fetchVersion] wihtPosition:position];
    [image drawInRect:rect];
}


- (CGRect)innerPositionRectWidth:(CGFloat )width withVersion:(CGFloat )version wihtPosition:(MKQRPosition) position
{
    CGFloat leftMargin = width * 3 / ((version - 1) * 4 + 21);
    CGFloat tileWidth = leftMargin;
    CGFloat centerImageWith = width * 7 / ((version - 1) * 4 + 21);
    
    CGRect rect = CGRectMake(leftMargin + 1.5, leftMargin + 1.5, leftMargin - 3, leftMargin - 3);
    rect = CGRectIntegral(rect);
    rect = CGRectInset(rect, -1, -1);
    
    CGFloat offset;
    switch (position) {
        case TopLeft:
            
            break;
        case TopRight:
            
            offset = width - tileWidth - leftMargin*2;
            rect = CGRectOffset(rect, offset, 0);
            break;
        case BottomLeft:
            
            offset = width - tileWidth - leftMargin * 2;
            rect = CGRectOffset(rect, 0, offset);
            break;
        case Center:
            
            rect = CGRectMake(CGPointZero.x, CGPointZero.y, centerImageWith, centerImageWith);
            offset = width/2 - centerImageWith/2;
            rect = CGRectOffset(rect, offset, offset);
            break;
        default:
            rect = CGRectZero;
            break;
    }
    
    return rect;
}


- (CGRect)outerPositionRectWidth:(CGFloat )width withVersion:(CGFloat )version wihtPosition:(MKQRPosition) position
{
    CGFloat zonePathWidth = width/((version - 1) * 4 + 21);
    
    CGFloat outerPositionWidth = zonePathWidth * outerPositionTileOriginWidth;
    CGRect rect = CGRectMake(zonePathWidth, zonePathWidth, outerPositionWidth, outerPositionWidth);
    
    rect = CGRectIntegral(rect);
    rect = CGRectInset(rect, -1, -1);
    
    CGFloat offset;
    switch (position) {
        case TopLeft:
            
            break;
        case TopRight:
            
            offset = width - outerPositionWidth - zonePathWidth * 2;
            rect = CGRectOffset(rect, offset, 0);
            
            break;
        case BottomLeft:
            
            offset = width - outerPositionWidth - zonePathWidth * 2;
            rect = CGRectOffset(rect, 0, offset);
    
        default:
            
            rect = CGRectZero;
            break;
    }
    
    return rect;
}


- (UIBezierPath *) outerPositionPathWidth:(CGFloat)width withVersion:(CGFloat )version wihtPosition:(MKQRPosition) position
{
    CGFloat zonePathWidth = width/((version - 1) * 4 + 21);
    CGFloat positionFrameWidth = zonePathWidth * outerPositionPathOriginLength;
    CGPoint topLeftPoint = CGPointMake(zonePathWidth * 1.5, zonePathWidth * 1.5);
    CGRect rect = CGRectMake(topLeftPoint.x - 0.2, topLeftPoint.y - 0.2, positionFrameWidth, positionFrameWidth);
    
    rect = CGRectIntegral(rect);
    rect = CGRectInset(rect, 1, 1);
    UIBezierPath *path;
    CGFloat offset;
    switch (position) {
        case TopLeft:
            
            path = [UIBezierPath bezierPathWithRect:rect];
            path.lineWidth = zonePathWidth + 1.5;
            path.lineCapStyle = kCGLineCapSquare;
            break;
        case TopRight:
            
            offset = width - positionFrameWidth - topLeftPoint.x * 2;
            rect = CGRectOffset(rect, offset, 0);
            path = [UIBezierPath bezierPathWithRect:rect];
            path.lineWidth = zonePathWidth + 1.5;
            path.lineCapStyle = kCGLineCapSquare;
            break;
        case BottomLeft:
            
            offset = width - positionFrameWidth - topLeftPoint.x * 2;
            rect = CGRectOffset(rect, 0, offset);
            path = [UIBezierPath bezierPathWithRect:rect];
            path.lineWidth = zonePathWidth + 1.5;
            path.lineCapStyle = kCGLineCapSquare;
            break;
        case QuietZone:
            rect = CGRectMake(zonePathWidth * 0.5, zonePathWidth * 0.5, width - zonePathWidth, width - zonePathWidth);
            path = [UIBezierPath bezierPathWithRect:rect];
            path.lineWidth = zonePathWidth + [UIScreen mainScreen].scale;
            path.lineCapStyle = kCGLineCapSquare;
            break;
        default:
            
            path = [UIBezierPath bezierPath];
            break;
    }
    return path;
    
}



@end
