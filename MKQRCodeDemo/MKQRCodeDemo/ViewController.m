//
//  ViewController.m
//  MKQRCodeDemo
//
//  Created by Mkil on 9/25/16.
//  Copyright © 2016 Mkil. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "MKQRCode.h"

#define StyleSources @[@"DefaultStyle",@"BackgroundColorStyle",@"FillColorStyle",@"OuterStyle",@"InnerStyle",@"CenterImageStyle",@"CompositeStyle"]

typedef NS_ENUM(NSInteger, style)
{
    DefaultStyle,
    BackgroundColorStyle,
    FillColorStyle,
    OuterStyle,
    InnerStyle,
    CenterImageStyle,
    CompositeStyle
};


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"QRCode";
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return StyleSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = StyleSources[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QRCodeViewController *QRCodeVC = [[QRCodeViewController alloc] init];
    
    QRCodeVC.title = StyleSources[indexPath.row];
    
    QRCodeVC.qrCodeImage = [self generateImage:indexPath.row];
    
    [self.navigationController pushViewController:QRCodeVC animated:YES];
}


- (UIImage *)generateImage:(style) qrCodeStyle
{
    MKQRCode *code = [[MKQRCode alloc] init];
    // 内容和大小
    [code setInfo:@"https://github.com/ymkil/MKQRCode" withSize:300];

    switch (qrCodeStyle) {
        case DefaultStyle:
            //默认不用设置
            
            break;
        case BackgroundColorStyle:
            // 背景色
            
            code.backgroundColor = [UIColor yellowColor];
            break;
        case FillColorStyle:
            // 填充色
            
            code.fillColor = [UIColor lightGrayColor];
            break;
        case OuterStyle:
            //定位图案 外层颜色
            
            code.outerColor = [UIColor orangeColor];
            code.style = MKQRCodeStyleOuter;
            break;
        case InnerStyle:
            //定位图案 内层颜色
            
            code.innerColor = [UIColor redColor];
            code.style = MKQRCodeStyleInner;
            break;
        case CenterImageStyle:
            //中心图片
            
            code.centerImg = [UIImage imageNamed:@"icon.jpg"];
            code.style = MKQRCodeStyleCenterImage;
            break;
            
        case CompositeStyle:
            //综合设置
            code.innerColor = [UIColor lightGrayColor];
            code.outerColor = [UIColor orangeColor];
            code.centerImg = [UIImage imageNamed:@"icon.jpg"];

            code.style = MKQRCodeStyleCenterImage | MKQRCodeStyleOuter | MKQRCodeStyleInner;
            break;
        default:
            break;
    }
    
    
    return [code generateImage];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
