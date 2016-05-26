//
//  WriteDataVC.m
//  OCTest
//
//  Created by shaw on 16/5/24.
//  Copyright © 2016年 shaw. All rights reserved.
//

#import "WriteDataVC.h"

@interface WriteDataVC ()<CBPeripheralDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) BOOL isNotifying;

@end

@implementation WriteDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *notifyItem = [[UIBarButtonItem alloc]initWithTitle:@"open notify" style:UIBarButtonItemStylePlain target:self action:@selector(notify:)];
    self.navigationItem.rightBarButtonItem = notifyItem;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.borderWidth = 0.5f;
    btn.frame = CGRectMake((self.view.bounds.size.width - 120) / 2.0f, 100, 120, 45);
    [btn setTitle:@"write" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(writeData:) forControlEvents:UIControlEventTouchUpInside];
    [btn setEnabled:NO];
    [self.view addSubview:btn];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(btn.frame) + 20, self.view.bounds.size.width - 40, 250) textContainer:nil];
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [UIColor redColor].CGColor;
    _textView.editable = NO;
    _textView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_textView];
    
    _peripheral.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_isNotifying && _characteristic.isNotifying)
    {
        [_peripheral setNotifyValue:NO forCharacteristic:_characteristic];
    }
}

-(void)notify:(UIBarButtonItem *)item
{
    if(_peripheral && _characteristic)
    {
        [_peripheral setNotifyValue:!_isNotifying forCharacteristic:_characteristic];
    }
}

-(void)setIsNotifying:(BOOL)isNotifying
{
    _isNotifying = isNotifying;
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;

    item.title = _isNotifying ? @"close notify" : @"open notify";
}

-(void)writeData:(UIButton *)btn
{
    /*
    Byte bytes[8];
    bytes[0] = 0xAC;
    bytes[1] = 0x02;
    bytes[2] = 0xFE;
    bytes[3] = 0x06;
    bytes[4] = 0x03;
    bytes[5] = 0x00;
    bytes[6] = 0xCC;
    bytes[7] = (bytes[2] + bytes[3] + bytes[4] + bytes[5] + bytes[6]) & 0xff;
    
    NSData *sendData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    [self writeValue:sendData toCharacteristic:_characteristic];
     */
}

#pragma mark -write data
-(void)writeValue:(NSData *)value toCharacteristic:(CBCharacteristic *)characteristic
{
    if(characteristic.properties & CBCharacteristicPropertyWrite ||
       characteristic.properties & CBCharacteristicWriteWithResponse ||
       characteristic.properties & CBCharacteristicWriteWithoutResponse)
    {
        [_peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        [self showErrorMsg:@"该属性不可写"];
        return;
    }
}

#pragma mark 
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        [self showErrorMsg:error.localizedDescription];
        return;
    }
    
    self.isNotifying = characteristic.isNotifying;
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        [self showErrorMsg:error.localizedDescription];
        return;
    }
    
    NSLog(@"22======================2222");
    NSLog(@"get value : %@", characteristic.value);
    
    _textView.text = [_textView.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n", characteristic.value]];
    [_textView setContentOffset:CGPointMake(0, _textView.contentSize.height - _textView.bounds.size.height) animated:YES];
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        [self showErrorMsg:error.localizedDescription];
        return;
    }
    
    _textView.text = [_textView.text stringByAppendingString:@"write success !"];
}

#pragma mark -show message
-(void)showErrorMsg:(NSString *)errMsg
{
    [[[UIAlertView alloc]initWithTitle:@"提示" message:errMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
