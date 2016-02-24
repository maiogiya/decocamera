#import "ImageViewController.h"

@interface ImageViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *grayButton;
@property (assign, nonatomic) BOOL isGray;

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *smallButton;

- (IBAction)saveButtonAction:(id)sender;
- (IBAction)grayButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.image = self.editImage;
    self.isGray = NO;
    
    // 輝度センサー監視オン
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenBrightnessDidChange:)
                                                 name:UIScreenBrightnessDidChangeNotification
                                               object:nil];
    [self updateBrightnessLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonAction:(id)sender {
    
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    //画像を保存する
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, selector, NULL);
}

//画像保存完了時のセレクタ
- (void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存終了" message:@"画像を保存しました" preferredStyle:UIAlertControllerStyleAlert];
    
    // addActionした順に左から右にボタンが配置されます
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // ボタンを押した際に処理が必要ならここに書きます。
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)grayButtonAction:(id)sender {
    
    self.isGray = !self.isGray;
    
    if (self.isGray) {
        
        [self.grayButton setTitle:@"Reset" forState:UIControlStateNormal];
        
        UIImage *image = self.editImage;
        CGRect imageRect = (CGRect){0.0, 0.0, image.size.width, image.size.height};
        
        // CoreGraphicsのモノクロ色空間を準備します
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        // ビットマップコンテキストを作りサイズと色空間を設定します
        CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        
        // ビットマップコンテキストに画像を描画します
        CGContextDrawImage(context, imageRect, [image CGImage]);
        
        // ビットマップコンテキストに描画された画像を取得します
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // 取得した画像からUIImageを作ります
        UIImage *grayScaleImage = [UIImage imageWithCGImage:imageRef];
        
        // 準備した色空間、ビットマップコンテキスト、取得した画像をメモリから解放します
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CFRelease(imageRef);
        
        // Storyboard上のUIImageViewに画像を描画します
        self.imageView.image = grayScaleImage;
    } else {
        
        self.grayButton.titleLabel.text = @"Gray";
        [self.grayButton setTitle:@"Gray" forState:UIControlStateNormal];
        
        self.imageView.image = self.editImage;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 輝度センサー監視オフ
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIScreenBrightnessDidChangeNotification
                                                  object:nil];
}

- (void)updateBrightnessLabel
{
    self.upButton.titleLabel.text = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].brightness];
}

- (void)screenBrightnessDidChange:(NSNotification *)notification
{
    UIScreen *screen = [notification object];
    self.upButton.titleLabel.text = [NSString stringWithFormat:@"%f", screen.brightness];
}

- (IBAction)upButtonTapped:(id)sender
{
    double brightness = [[UIScreen mainScreen] brightness];
    brightness += 0.1;
    if (brightness > 1.0) brightness = 1.0;
    [[UIScreen mainScreen] setBrightness:brightness];
    [self updateBrightnessLabel];
}

- (IBAction)downButtonTapped:(id)sender
{
    double brightness = [[UIScreen mainScreen] brightness];
    brightness -= 0.1;
    if (brightness < 0.0) brightness = 0.0;
    [[UIScreen mainScreen] setBrightness:brightness];
    [self updateBrightnessLabel];
}

- (IBAction)bigButtonTapped:(id)sender
{
    self.imageView.transform = CGAffineTransformMakeScale(2, 2);
    [self imageView];
}

- (IBAction)smallButtonTapped:(id)sender
{
    self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self imageView];
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end