//
//  BTDetailVC.h
//  OCTest
//
//  Created by shaw on 16/5/24.
//  Copyright © 2016年 shaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBlueTooth/CoreBlueTooth.h>

@interface BTDetailVC : UIViewController

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *selPeripheral;

@end
