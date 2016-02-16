//
//  MQImageCropperViewController.h
//  MQImageCropperViewController
//
//  Created by mazengyi on 16/2/16.
//  Copyright © 2016年 fansz. All rights reserved.
//

#import "ViewController.h"


typedef void(^CropImageCompleteBlcok)(UIImage *originImage, UIImage *cropImage);

@interface MQImageCropperViewController : ViewController

- (instancetype)initWithImage:(UIImage *)image withCropSize:(CGSize)size;

- (void)setCropImageCompleteBlcok:(CropImageCompleteBlcok)cropImageCompleteBlcok;

@end
