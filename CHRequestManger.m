//
//  CHRequestManger.m
//  PYH
//
//  Created by syhdMacMini4 on 2018/8/27.
//  Copyright © 2018年 syhd. All rights reserved.
//

#import "CHRequestManger.h"
#import <YYModel/YYModel.h>
static CHRequestManger* _instance = nil;
@implementation CHRequestManger{
    AFHTTPSessionManager *_manager;
}
+(instancetype)sharedManger{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    [_instance initManager];
    return _instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [CHRequestManger sharedManger] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [CHRequestManger sharedManger] ;
}
-(void)initManager{
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10.0;
    _manager.securityPolicy.allowInvalidCertificates = YES;
    _manager.securityPolicy.validatesDomainName = NO;//不验证证书的域名
//    [_manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
}
-(void)cancelNetworkWithUrl:(NSURL*)url{
    for (NSURLSessionDataTask* task in _manager.tasks) {
        if ([url isEqual:task.currentRequest.URL]) {
            [task cancel];
            return;
        }
    }
}
-(void)cancelNetwork{
    [_manager.tasks makeObjectsPerformSelector:@selector(cancel)];
}
-(void)delloc
{
    [_manager invalidateSessionCancelingTasks:YES];
}
- (NSURL *)paramsWithTypeURL:(NSString*)url otherParams:(NSDictionary *)params {
    NSMutableArray *tparams = [[NSMutableArray alloc] initWithCapacity:0];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [tparams addObject:[NSString stringWithFormat:@"%@=%@",key,[[NSString stringWithFormat:@"%@",obj] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    }];
    NSString *paramString = [tparams componentsJoinedByString:@"&"];
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@",url,paramString];
    return [NSURL URLWithString:urlStr];
}
-(void)httpForPostUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender{
    if (sender) {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            [SVProgressHUD show];
        }];
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parameter];

    NSLog(@"URL:%@   Parameters:%@",[self paramsWithTypeURL:url otherParams:dic],dic);
    
    [_manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responsedic:%@",responsedic);
        
        
        if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            if (subModel) {
                success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:responsedic]],url);
            }else{
                if ([model yy_modelWithJSON:responsedic]) {
                    success([model yy_modelWithJSON:responsedic],url);
                }else{
                    success(responsedic,url);
                }
            }
        }else{
            success(responsedic,url);
        }


    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        if (data) {
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            NSDictionary *errorStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            failed(errorStr,url);
            NSLog(@"%@",errorStr);
        }else{
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            failed(nil,url);
        }

    }];
}
-(void)httpForGetUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender{
   if (sender) {
       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
           [SVProgressHUD show];
       }];
   }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parameter];
    
    NSLog(@"URL:%@   Parameters:%@",[self paramsWithTypeURL:url otherParams:dic],dic);
    [_manager GET:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responsedic:%@",responsedic);
        if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            if (subModel) {
                success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:responsedic]],url);
            }else{
                if ([model yy_modelWithJSON:responsedic]) {
                    success([model yy_modelWithJSON:responsedic],url);
                }else{
                    success(responsedic,url);
                }
            }
        }else{
            success(responsedic,url);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        if (data) {
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            NSDictionary *errorStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            failed(errorStr,url);
            NSLog(@"%@",errorStr);
        }else{
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            failed(nil,url);
        }

    }];
}
-(void)httpForPutUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender{
   if (sender) {
       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
           [SVProgressHUD show];
       }];
   }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parameter];
    NSLog(@"URL:%@   Parameters:%@",[self paramsWithTypeURL:url otherParams:dic],dic);
    [_manager PUT:url parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responsedic:%@",responsedic);
        NSString* code = responsedic[@"code"];
        NSString* msg = responsedic[@"msg"];
        if (code.intValue == 0) {
            if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
                NSDictionary *response = responsedic[@"data"];
                if (subModel) {
                    success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:response]],url);
                }else{
                    if ([model yy_modelWithJSON:response]) {
                        success([model yy_modelWithJSON:response],url);
                    }else{
                        success(response,url);
                    }
                }
            }else{
                success(responsedic,url);
            }
        }else if (code.intValue == 1001000){
            [CHUserDefaults loginOut];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (![msg isEqual:[NSNull null]]) {
                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(msg, nil)];
               }
            });
            failed(msg,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        if (data) {
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            NSDictionary *errorStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            failed(errorStr,url);
            NSLog(@"%@",errorStr);
        }else{
            [SVProgressHUD showErrorWithStatus:@"请求超时,请重试"];
            failed(nil,url);
        }
    }];
}
-(void)httpForDelUrl:(NSString*)url andModel:(Class)model andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed{
    
    [self httpForDelUrl:url andModel:model andSubModel:nil andParameters:parameter andSuccess:^(id repose, NSString *url) {
        success(repose,url);
    } andFailed:^(id repose, NSString *url) {
        failed(repose,url);
    }];
}
-(void)httpForDelUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:parameter];
    NSLog(@"URL:%@   Parameters:%@",[self paramsWithTypeURL:url otherParams:dic],dic);
    [_manager DELETE:url parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responsedic:%@",responsedic);
        NSString* code = responsedic[@"code"];
        NSString* msg = responsedic[@"msg"];
        if (code.intValue == 0) {
            if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
                NSDictionary *response = responsedic[@"data"];
                if (subModel) {
                    success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:response]],url);
                }else{
                    if ([model yy_modelWithJSON:response]) {
                        success([model yy_modelWithJSON:response],url);
                    }else{
                        success(response,url);
                    }
                }
            }else{
                success(responsedic,url);
            }
        }else if (code.intValue == 1001000){
            [CHUserDefaults loginOut];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (![msg isEqual:[NSNull null]]) {
                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(msg, nil)];
               }
            });
            failed(msg,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //[SVProgressHUD dismiss];
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        if (data) {
            NSDictionary *errorStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            failed(errorStr,url);
            NSLog(@"%@",errorStr);
        }else{
            failed(nil,url);
        }
    }];
}
-(void)uploadImages:(NSMutableArray*)images andandPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i<images.count; i++) {
            UIImage* image = images[i];
            NSDate *date = [NSDate date];
            NSDateFormatter *formormat = [[NSDateFormatter alloc]init];
            [formormat setDateFormat:@"HHmmss"];
            NSString *dateString = [formormat stringFromDate:date];
            NSString *fileName = [NSString  stringWithFormat:@"%@%d.png",dateString,i];
            NSData *imageData = [self imageData:image];
            [formData  appendPartWithFileData:imageData name:@"files[]" fileName:fileName mimeType:@"image/png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            if (subModel) {
                success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:responsedic]],url);
            }else{
                if ([model yy_modelWithJSON:responsedic]) {
                    success([model yy_modelWithJSON:responsedic],url);
                }else{
                    success(responsedic,url);
                }
            }
        }else{
            success(responsedic,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];

    
    
}
-(NSData *)imageData:(UIImage *)myimage
{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {
        if (data.length>2*1024*1024) {//2M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.05);
        }else if (data.length>1024*1024) {//1M-2M
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.2);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.4);
        }
    }
    return data;
}
-(void)uploadHeaderImage:(UIImage*)image andandPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formormat = [[NSDateFormatter alloc]init];
        [formormat setDateFormat:@"HHmmss"];
        NSString *dateString = [formormat stringFromDate:date];
        NSString *fileName = [NSString  stringWithFormat:@"%@.png",dateString];
        NSData *imageData = [self imageData:image];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];

        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            if (subModel) {
                success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:responsedic]],url);
            }else{
                if ([model yy_modelWithJSON:responsedic]) {
                    success([model yy_modelWithJSON:responsedic],url);
                }else{
                    success(responsedic,url);
                }
            }
        }else{
            success(responsedic,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)uploadFile:(NSData*)file andName:(NSString*)name andPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    
    
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:file name:@"files" fileName:name mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if(!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            if (subModel) {
                success([NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:subModel json:responsedic]],url);
            }else{
                if ([model yy_modelWithJSON:responsedic]) {
                    success([model yy_modelWithJSON:responsedic],url);
                }else{
                    success(responsedic,url);
                }
            }
        }else{
            success(responsedic,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)uploadAudio:(NSString*)audio andFileName:(NSString*)name andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData  appendPartWithFileData:[NSData dataWithContentsOfFile:audio] name:@"file" fileName:name mimeType:@"audio/wav"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if (!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            success(responsedic,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)uploadAudioData:(NSData*)audio andFileName:(NSString*)name andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData  appendPartWithFileData:audio name:@"file" fileName:name mimeType:@"audio/wav"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if (!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            success(responsedic,url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)uploadVideo:(NSURL*)video andFimage:(UIImage*)fimage andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    [_manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(fimage, 0.1);
        [formData appendPartWithFileData:imageData name:@"pic" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:video] name:@"video" fileName:@"video.mp4" mimeType:@"video/mpeg"];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        gress(uploadProgress.fractionCompleted);
        NSLog(@"---%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if (!([responsedic isEqual:[NSNull null]]||responsedic == nil)){
            success(responsedic[@"url"],url);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        [SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)httpForsBodyStream:(NSDictionary*)par andModel:(Class)model andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed{
    NSLog(@"%@",[self paramsWithTypeURL:url otherParams:par]);
    
    [_manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [[par yy_modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"JSONString:%@   %@",[par yy_modelToJSONString],[NSInputStream inputStreamWithData:data]);
        [formData appendPartWithInputStream:[NSInputStream inputStreamWithData:data] name:@"file" fileName:@"payOrder" length:data.length mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responsedic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"请求成功%@",responsedic);
        if ([[NSString stringWithFormat:@"%@",responsedic[@"code"]] isEqualToString:@"200"]) {
            success(responsedic[@"obj"],url);
        }else{
            failed(responsedic,url);
            NSString* fild;
            if (responsedic[@"message"]) {
                fild = responsedic[@"message"];
            }else{
                fild = responsedic[@"msg"];
            }
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",fild]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
        NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        failed(errorStr,url);
        //[SVProgressHUD showErrorWithStatus:errorStr];
        NSLog(@"%@",errorStr);
    }];
}
-(void)httpForDownAndCount:(NSString*)file andProgress:(DGress)gress andSuccess:(Success)success{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:file];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    
    
    /* 下载路径 */
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [path stringByAppendingPathComponent:[file componentsSeparatedByString:@"/"].lastObject];
    
    
    //NSString *filePath = [self GetPathByFileName:[self getCurrentTimeString] ofType:@"amr"];
    
    /* 开始请求下载 */
    self.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSString* to = [NSString stringWithFormat:@"%lld",downloadProgress.totalUnitCount];
        gress(downloadProgress.fractionCompleted,to.floatValue/1000/1000);

        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //[SVProgressHUD dismiss];
        success(filePath,file);
        NSLog(@"下载完成");
        
    }];
    [self.downloadTask resume];
}

-(void)httpForDown:(NSString*)file andProgress:(Gress)gress andSuccess:(Success)success andFailed:(Failed)failed{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:file];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /* 下载路径 */
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [path stringByAppendingPathComponent:url.lastPathComponent];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        gress(downloadProgress.fractionCompleted);
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //[SVProgressHUD dismiss];
        if (error) {
            NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *errorStr = [[ NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            failed(errorStr,file);
            //[SVProgressHUD showErrorWithStatus:errorStr];
            NSLog(@"%@",errorStr);
        }else{
            success(filePath,file);
            NSLog(@"下载完成");
        }

        
    }];
    [downloadTask resume];
}
-(NSString*)getCurrentTimeString{
    
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    
    return [dateformat stringFromDate:[NSDate date]];
}
-(NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type{
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* fileDirectory = [[[directory stringByAppendingPathComponent:_fileName]
                                stringByAppendingPathExtension:_type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}
- (NSData *)imageCompressToData:(UIImage *)image{
    NSData *data=UIImageJPEGRepresentation(image, 1.0);
    if (data.length>300*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(image, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(image, 0.5);
        }else if (data.length>300*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(image, 0.9);
        }
    }
    return data;
}
@end
