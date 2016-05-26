//
//  WriteDataVC.h
//  OCTest
//
//  Created by shaw on 16/5/24.
//  Copyright © 2016年 shaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBlueTooth/CoreBlueTooth.h>

@interface WriteDataVC : UIViewController

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@end
