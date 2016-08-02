//
//  ViewController.m
//  UIImagePickerController
//
//  Created by 丁瑞瑞 on 2/8/16.
//  Copyright © 2016年 Rochester. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
/** 网络请求者*/
@property (nonatomic,strong) AFHTTPSessionManager *manager;
/** 图片选择器*/
@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@end

@implementation ViewController
- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_imageV addGestureRecognizer:tap];
    _imageV.userInteractionEnabled = YES;
    _imageV.layer.cornerRadius = 50;
    _imageV.layer.masksToBounds = YES;
    _imageV.image = [UIImage imageNamed:@"fire.jpg"];
//    创建有一个图片选择器
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    //        设置代理
    imagePickerController.delegate = self;
    //        允许被编辑
    imagePickerController.allowsEditing = YES;
    self.imagePickerController = imagePickerController;
}
- (void)tapAction{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"退出" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
//    action.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [action showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
//        设置从图库里面选择图片
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }else if(buttonIndex == 0){
//        判断是是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//            设置从相机获取图片
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"请使用真机进行测试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
        }

    }
}
//当选择完图片以后进入代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    /*
     UIImagePickerControllerCropRect // 编辑裁剪区域
     UIImagePickerControllerEditedImage // 编辑后的UIImage
     UIImagePickerControllerMediaType // 返回媒体的媒体类型
     UIImagePickerControllerOriginalImage // 原始的UIImage
     UIImagePickerControllerReferenceURL // 图片地址
     */
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        //    将该图片保存到本地
        [self saveImage:image withName:@"avatar.png"];
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"avatar.png"];
        UIImage *saveImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
//
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        //    设置为头像
        self.imageV.image = saveImage;
        //    上传到服务器
        NSDictionary *dict = @{
                               @"username":@"123456",
                               };
        [self.manager POST:@"http://120.25.226.186:32812/upload" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            //将图片以表单形式上传
            /*
             Data: 需要上传的数据
             name: 服务器参数的名称
             fileName: 文件在服务器上保存的名称
             mimeType: 文件的类型
             */
            NSLog(@"%@",fullPath);
            NSData *data1=[NSData dataWithContentsOfFile:fullPath];
            [formData appendPartWithFileData:data1 name:@"file" fileName:fileName mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"%f",1.0 *uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功---%@---%@",[responseObject class],responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败---%@",error);
        }];
    }
    
}
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1); // 1为不缩放保存,取值为(0~1)
    // 获取沙河路径
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:imageName];
    // 将照片写入文件
    [imageData writeToFile:fullPath atomically:YES];
}
@end
