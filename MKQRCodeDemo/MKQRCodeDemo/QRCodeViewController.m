//
//  QRCodeViewController.m
//  MKQRCodeDemo
//
//  Created by Mkil on 9/25/16.
//  Copyright © 2016 Mkil. All rights reserved.
//

#import "QRCodeViewController.h"

#define MKScreenWidth     [UIScreen mainScreen].bounds.size.width
#define MKScreenHeight    [UIScreen mainScreen].bounds.size.height

@implementation QRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *imgV = [[UIImageView alloc] init];
    
    imgV.frame = CGRectMake((MKScreenWidth - 300) / 2.0, (MKScreenHeight - 300) / 2.0, 300, 300);
    imgV.image = _qrCodeImage;
    
    [self.view addSubview:imgV];
    
}


@end
