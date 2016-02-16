//
//  MQImageCropperViewController.m
//  MQImageCropperViewController
//
//  Created by mazengyi on 16/2/16.
//  Copyright © 2016年 fansz. All rights reserved.
//

#import "MQImageCropperViewController.h"

@interface MQImageCropperViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *imageContainerScrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign) CGSize cropSize;

@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) UIView *bottomBar;

@property (nonatomic, copy) CropImageCompleteBlcok cropImageCompleteBlcok;

@property (nonatomic, assign) CGFloat factor;


@end

@implementation MQImageCropperViewController



- (instancetype)initWithImage:(UIImage *)image withCropSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.image = image;
        self.cropSize = size;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor blackColor];
    self.imageContainerScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.imageContainerScrollView.contentSize = self.view.bounds.size;
    self.imageContainerScrollView.delegate = self;
    self.imageView = [[UIImageView alloc]initWithImage:self.image];
    self.imageContainerScrollView.maximumZoomScale = 10;
    self.imageContainerScrollView.minimumZoomScale = 1;
    self.imageView.frame = self.view.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageContainerScrollView addSubview:self.imageView];
    [self.view addSubview:self.imageContainerScrollView];

    
    CGRect cropRect;
    
    CGFloat y = (self.view.bounds.size.height - self.cropSize.height) / 2;
    cropRect = CGRectMake(0, y, self.cropSize.width, self.cropSize.height);
    self.cropRect = cropRect;
    
    self.maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.maskView.userInteractionEnabled = NO;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:0]];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = maskPath.CGPath;
    
    CAShapeLayer *borderLayer= [CAShapeLayer layer];
    UIBezierPath *boardPath = [UIBezierPath bezierPath];
    [boardPath appendPath:[UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:0]];
    borderLayer.strokeColor = [UIColor greenColor].CGColor;
    borderLayer.lineWidth  = 2;
    borderLayer.frame=self.view.bounds;
    borderLayer.path = boardPath.CGPath;
    
    [self.maskView.layer addSublayer:borderLayer];
    self.maskView.layer.mask = maskLayer;
    [self.view addSubview:self.maskView];
    
    
    ///计算大小
    CGFloat factor = self.view.bounds.size.width / self.image.size.width;
    self.factor = factor;
    CGFloat height = self.image.size.height * factor;
    self.imageContainerScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    self.imageContainerScrollView.contentInset = UIEdgeInsetsMake(y, 0, y, 0);
    self.imageContainerScrollView.contentOffset = CGPointMake(0, -self.view.bounds.size.height / 2 + height / 2);
    [self.imageContainerScrollView setZoomScale:1 animated:YES];
    
    self.bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 70, self.view.bounds.size.width, 70)];
    self.bottomBar.backgroundColor = [UIColor colorWithRed:20.f / 255 green:20.f / 255 blue:20.f / 255 alpha:0.8];
    [self.view addSubview:self.bottomBar];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(15, (self.bottomBar.bounds.size.height / 2 - 20), 50, 50);
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:cancelBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"选取" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okBtn.frame = CGRectMake(self.bottomBar.frame.size.width - 65, (self.bottomBar.bounds.size.height / 2 - 20), 50, 50);
    [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:okBtn];
    
}

#pragma mark - event




- (void)cancelBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)okBtnClick
{
    
    ///计算裁剪位置
    CGRect rect =  [self.view convertRect:self.cropRect toView:self.imageView];
    
    
   rect =  CGRectMake(rect.origin.x / self.imageView.bounds.size.width * self.image.size.width, rect.origin.y / self.imageView.bounds.size.height * self.image.size.height, rect.size.width /  self.imageView.bounds.size.width * self.image.size.width, rect.size.height / self.imageView.bounds.size.height * self.image.size.height);
    if (self.cropImageCompleteBlcok) {
       UIImage *cropImage = [self getCropImageFromOriginImage:self.imageView.image cropImageSize: rect.size  cropImageRect:rect];
        self.cropImageCompleteBlcok(self.image, cropImage);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.imageContainerScrollView setZoomScale:scale animated:YES];
}

//图片裁剪
-(UIImage *)getCropImageFromOriginImage:(UIImage*)originImage cropImageSize:(CGSize)cropImageSize cropImageRect:(CGRect)cropImageRect
{
    
    UIImage *fixOrientation = [self fixOrientation:originImage];
    CGImageRef imageRef = fixOrientation.CGImage;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, cropImageRect);
    UIGraphicsBeginImageContext(cropImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, cropImageRect, subImageRef);
    UIImage* returnImage = [UIImage imageWithCGImage:subImageRef scale:originImage.scale orientation:fixOrientation.imageOrientation];
    UIGraphicsEndImageContext(); //返回裁剪的部分图像
    return returnImage;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}














@end
