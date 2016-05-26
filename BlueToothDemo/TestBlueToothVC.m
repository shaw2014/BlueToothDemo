//
//  TestBlueToothVC.m
//  TestDemo
//
//  Created by shaw on 16/5/24.
//  Copyright © 2016年 shaw. All rights reserved.
//

#import "TestBlueToothVC.h"
#import "BTDetailVC.h"
#import <CoreBlueTooth/CoreBlueTooth.h>

@interface TestBlueToothVC ()<CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *deviceTable;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;

@end

@implementation TestBlueToothVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc]initWithTitle:@"scan" style:UIBarButtonItemStylePlain target:self action:@selector(scan:)];
    self.navigationItem.rightBarButtonItem = scanItem;
    
    _deviceTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _deviceTable.dataSource = self;
    _deviceTable.delegate = self;
    [self.view addSubview:_deviceTable];
    
    [self.view addSubview:self.indicator];
    
    _deviceList = [[NSMutableArray alloc]init];
    _deviceDic = [[NSMutableDictionary alloc]init];
    
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
}

-(UIActivityIndicatorView *)indicator
{
    if(!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:self.view.bounds];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _indicator.hidesWhenStopped = YES;
        [_indicator stopAnimating];
    }
    
    return _indicator;
}

-(void)scan:(UIBarButtonItem *)item
{
    if(_centralManager.isScanning)
    {
        for (CBPeripheral *peer in _deviceList) {
            [_centralManager cancelPeripheralConnection:peer];
        }
        [_deviceList removeAllObjects];
        [_deviceDic removeAllObjects];
        
        [_deviceTable reloadData];
        [_centralManager stopScan];
    }
    
    [_indicator startAnimating];
    
    //用于未连接情况下，回调返回信号强度RSSI
    [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
}

#pragma mark
#pragma mark -UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CBPeripheral *peripheral = [_deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"信号强度:%@", _deviceDic[peripheral]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [_centralManager stopScan];
    
    CBPeripheral *peripheral = [_deviceList objectAtIndex:indexPath.row];
    [_centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark
#pragma mark -CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state != CBCentralManagerStatePoweredOn)
    {
        [self showErrorMsg:@"请先打开蓝牙连接"];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    //发现蓝牙设备
    [_indicator stopAnimating];
    
    if(![_deviceList containsObject:peripheral])
    {
        [_deviceList addObject:peripheral];
    }
    
    [_deviceDic setObject:RSSI forKey:peripheral];
    
    [_deviceTable reloadData];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //连接设备成功
    BTDetailVC *detailVC = [[BTDetailVC alloc]init];
    detailVC.title = peripheral.name;
    detailVC.centralManager = central;
    detailVC.selPeripheral = peripheral;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //断开连接
    [central cancelPeripheralConnection:peripheral];
    
    NSLog(@"disconnected===============");
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //连接失败
    [central cancelPeripheralConnection:peripheral];
    
    [self showErrorMsg:@"连接失败"];
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
