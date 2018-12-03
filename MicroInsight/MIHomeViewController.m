//
//  MIHomeViewController.m
//  MicroInsight
//
//  Created by Jonphy on 2018/11/19.
//  Copyright © 2018 舒雄威. All rights reserved.
//

#import "MIHomeViewController.h"
#import "MIPhotographyViewController.h"
#import "MILoginViewController.h"
#import "MICommunityViewController.h"
#import "MIMyAlbumViewController.h"

@interface MIHomeViewController ()

@end

@implementation MIHomeViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

#pragma mark - IB
- (IBAction)communityBtnClick:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Community" bundle:nil];
    MICommunityViewController *vc = [board instantiateViewControllerWithIdentifier:@"MICommunityViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)photographyBtnClick:(UIButton *)sender {
    MIPhotographyViewController *vc = [[MIPhotographyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loginBtnClick:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    MILoginViewController *vc = [board instantiateViewControllerWithIdentifier:@"MILoginViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)myAlbumBtnClick:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MyAlbum" bundle:nil];
    MIMyAlbumViewController *vc = [board instantiateViewControllerWithIdentifier:@"MIMyAlbumViewController"];
    vc.albumType = MIAlbumTypePhoto;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
