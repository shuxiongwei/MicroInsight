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
//#import "SecurityUtil.h"


@implementation MIHTTPResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing  _Nullable *)error{
    
    id responseObject = [super responseObjectForResponse:response data:data error:error];
//    DLog(@"NSURLResponseURL:%@",response.URL);
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    if (![response.URL.absoluteString containsString:@"versioninfo/getVersion"] && !responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        });
        return nil;
    }
    NSError *jsError;
    NSString *dataString = [[NSString  alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSDictionary *dic;
    if ([response.URL.absoluteString isEqualToString:ApiAuctionWebSocketUrlBase]) {
        
//        dic = [self dictionaryWithJsonString:dataString];
    }else{
//        NSString *decryptStr = [SecurityUtil decryptAESData:dataString];
//        dic = [self dictionaryWithJsonString:decryptStr];
    }
   
//    DLog(@"parse dic:%@",dic);
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]|| jsError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        });
        return nil;
    }
    
    NSInteger code = [dic[@"status"] integerValue];
    if (code != ApiSessionSucessCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:dic[@"msg"]];
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
