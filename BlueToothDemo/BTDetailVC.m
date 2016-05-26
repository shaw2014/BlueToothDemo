//
//  BTDetailVC.m
//  OCTest
//
//  Created by shaw on 16/5/24.
//  Copyright © 2016年 shaw. All rights reserved.
//

#import "BTDetailVC.h"

#import "WriteDataVC.h"

@interface BTDetailVC ()<CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *detailTable;

@end

@implementation BTDetailVC

-(void)dealloc
{
    [_centralManager cancelPeripheralConnection:_selPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(_selPeripheral)
    {
        _selPeripheral.delegate = self;
        [_selPeripheral discoverServices:nil];
    }
    
    [self.view addSubview:self.detailTable];
}

-(UITableView *)detailTable
{
    if(!_detailTable)
    {
        _detailTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _detailTable.dataSource = self;
        _detailTable.delegate = self;
    }
    
    return _detailTable;;
}

#pragma mark 
#pragma mark -UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _selPeripheral.services.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBService *service = _selPeripheral.services[section];
    return service.characteristics.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    label.backgroundColor = [UIColor lightGrayColor];
    CBService *service = _selPeripheral.services[section];
    label.text = service.UUID.UUIDString;
    
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CBService *service = _selPeripheral.services[indexPath.section];
    CBCharacteristic *character = service.characteristics[indexPath.row];
    
    cell.textLabel.text = character.UUID.UUIDString;
    
    NSMutableArray *props = [NSMutableArray array];
    if (character.properties & CBCharacteristicPropertyRead)
    {
        [props addObject:@"Read"];
    }
    if (character.properties & CBCharacteristicPropertyWrite)
    {
        [props addObject:@"Write"];
    }
    if(character.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        [props addObject:@"WriteWithoutResponse"];
    }
    if (character.properties & CBCharacteristicPropertyNotify)
    { 
        [props addObject:@"Notify"];
    }
    
    NSString *str = [props componentsJoinedByString:@", "];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Property: %@", str];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBService *service = _selPeripheral.services[indexPath.section];
    CBCharacteristic *character = service.characteristics[indexPath.row];

    WriteDataVC *dataVC = [[WriteDataVC alloc]init];
    dataVC.title = character.UUID.UUIDString;
    dataVC.peripheral = _selPeripheral;
    dataVC.characteristic = character;
    [self.navigationController pushViewController:dataVC animated:YES];
}

#pragma mark
#pragma mark -CBPeripheralDelegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error)
    {
        [self showErrorMsg:error.localizedDescription];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
    {
        [self showErrorMsg:error.localizedDescription];
        return;
    }
    
    [_detailTable reloadData];
}


//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    if(error)
//    {
//        [self showErrorMsg:error.localizedDescription];
//        
//        return;
//    }
//    
//    for (CBDescriptor *desc in characteristic.descriptors) {
//        [peripheral readValueForDescriptor:desc];
//    }
//}
//
//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
//{
//    if(error)
//    {
//        [self showErrorMsg:error.localizedDescription];
//
//        return;
//    }
//    
//    NSLog(@"descriptor value : %@", descriptor.value);
//}

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
