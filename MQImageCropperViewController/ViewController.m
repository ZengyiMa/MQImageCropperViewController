//
//  ViewController.m
//  MQImageCropperViewController
//
//  Created by mazengyi on 16/2/16.
//  Copyright © 2016年 fansz. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MQImageCropperViewController.h"
@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iv;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pickImage:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
#pragma mark------------UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *pickImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:NO completion:nil];
        MQImageCropperViewController *vc = [[MQImageCropperViewController alloc]initWithImage:pickImage withCropSize:CGSizeMake(self.view.bounds.size.width, 300)];
        [vc setCropImageCompleteBlcok:^(UIImage *originImage, UIImage *cropImage) {
            self.iv.image = cropImage;
        }];
        [self presentViewController:vc animated:YES completion:nil];
    }
 
    
  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
