//
//  ZXingBoard.m
//  CarAssistant
//
//  Created by Eric on 14-4-22.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "ZXingBoard.h"


@interface ZXingBoard ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, HM_STRONG) UIView *scanRectView;
@property (nonatomic, HM_STRONG) UILabel *label;
@property (nonatomic,strong) AVCaptureSession* session;
@end

@implementation ZXingBoard
@synthesize capture,scanRectView;
@synthesize type;
DEF_SIGNAL(ZXingRead)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButten *leftBtn = [[UIButten alloc]init];
    leftBtn.tagString = @"leftBtn";
    [leftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMakeBound(32, 32)];
    leftBtn.eventReceiver = self;
    [self showBarButton:HMUINavigationBar.LEFT custom:leftBtn];
    
    
    self.scanRectView = [UIView spawn];
    self.scanRectView.frame = CGRectMakeBound(260, 260);
    self.scanRectView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    [self.view addSubview:scanRectView];
    self.scanRectView.center = self.view.center;
    
    self.label = [UILabel spawn];
    self.label.frame = CGRectMakeBound(260, 260);
    self.label.centerX = self.view.centerX;
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
    [self showCapture];
}
- (void)dealloc
{
    self.scanRectView = nil;
    self.capture = nil;
    HM_SUPER_DEALLOC();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCapture{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer below:self.scanRectView.layer];
    //开始捕获
    [self.session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        //[session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
        if ([metadataObject.stringValue notEmpty]) {
            NSString *display = [NSString stringWithFormat:@"Scanned!\nContents:\n%@",  metadataObject.stringValue];
            
            self.label.text = display;
            HMSignal *signal = [self sendSignal:self.ZXingRead withObject:metadataObject.stringValue];
            if (signal.boolValue) {
                
                [self backAndRemoveWithAnimate:YES];
                // Vibrate
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            
        }
    }
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            //            self.capture.delegate = nil;
            [self backAndRemoveWithAnimate:YES];
        }
    }
}
@end
