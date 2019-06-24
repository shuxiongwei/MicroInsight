//
//  MIWatermarkVC.m
//  MicroInsight
//
//  Created by 舒雄威 on 2019/6/23.
//  Copyright © 2019 舒雄威. All rights reserved.
//

#import "MIWatermarkVC.h"

@interface MIWatermarkVC ()

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *ruleLab;

@end

@implementation MIWatermarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configUI];
}

- (void)configUI {
    self.title = @"添加水印";
    [super configLeftBarButtonItem:nil];
    
    _switchBtn.on = [MILocalData getOpenRuleWatermark];
}

- (IBAction)clickSwitchBtn:(UISwitch *)sender {
    sender.on = !sender.on;
    [MILocalData saveOpenRuleWatermark:sender.on];
}

@end
