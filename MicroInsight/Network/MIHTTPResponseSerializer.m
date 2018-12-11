//
//  POHTTPResponseSerializer.m
//  PublicOpinion
//
//  Created by Jonphy on 2018/11/8.
//  Copyright © 2018 Xiamen Juhu Network Techonology Co.,Ltd. All rights reserved.
//

#import "MIHTTPResponseSerializer.h"
#import "MINetworkConstant.h"
#import "SVProgressHUD.h"
#import "MIBaseRequest.h"
#import "MIDataConvertion.h"
//#import "SecurityUtil.h"


@implementation MIHTTPResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing  _Nullable *)error{
    
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    NSLog(@"NSURLResponseURL:%@",response.URL);
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
   
    NSError *jsError;
    NSString *dataString = [[NSString  alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    MIDataConvertion *convertion = [[MIDataConvertion alloc]init];
    NSDictionary *dic = [convertion dictionaryWithJsonString:dataString];

   
//    DLog(@"parse dic:%@",dic);
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]|| jsError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        });
        return nil;
    }
    
    NSInteger code = [dic[@"code"] integerValue];
    if (code != ApiSessionSucessCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:dic[@"message"]];
        });
        
        if (code == ApiAccountErrorLogoutCode) {
            
//            [[SocketRocketUtility instance] SRWebSocketClose];
//            [LBLocalManager clearToken];
//            [LBLocalManager clearUserInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                UITabBarController *tab = (UITabBarController  *)[UIApplication sharedApplication].keyWindow.rootViewController;
//                UIStoryboard *board = [UIStoryboard storyboardWithName:@"Reg&Log" bundle:nil];
//                UINavigationController *nav = [board instantiateInitialViewController];
//                [tab presentViewController:nav animated:YES completion:nil];
            });
        }
    }
    return dic;
}

@end
