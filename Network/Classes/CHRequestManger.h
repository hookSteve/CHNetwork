//
//  CHRequestManger.h
//  PYH
//
//  Created by syhdMacMini4 on 2018/8/27.
//  Copyright © 2018年 syhd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking-umbrella.h>
typedef void(^DGress)(float gress,float togress);
typedef void(^Failed)(id repose,NSString* url);
typedef void(^Success)(id repose,NSString* url);
typedef void(^Gress)(float gress);
@interface CHRequestManger : NSObject
+(instancetype)sharedManger;
@property(nonatomic,copy)NSString* pid;
@property (nonatomic, assign) int pageNum;
@property(nonatomic,strong)NSURLSessionDownloadTask *downloadTask;
-(void)cancelNetworkWithUrl:(NSURL*)url;
-(void)cancelNetwork;
-(void)uploadImages:(NSMutableArray*)images andandPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)uploadHeaderImage:(UIImage*)image andandPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)httpForGetUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender;
-(void)httpForPostUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender;
-(void)httpForPutUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed showProgress:(BOOL)sender;
-(void)httpForDelUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed;
-(void)httpForDelUrl:(NSString*)url andModel:(Class)model andParameters:(NSDictionary*)parameter andSuccess:(Success)success andFailed:(Failed)failed;
-(void)uploadAudio:(NSString*)audio andFileName:(NSString*)name andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)httpForDown:(NSString*)file andProgress:(Gress)gress andSuccess:(Success)success andFailed:(Failed)failed;
-(void)uploadVideo:(NSURL*)video andFimage:(UIImage*)fimage andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)uploadAudioData:(NSData*)audio andFileName:(NSString*)name andandPars:(NSDictionary*)par andUrl:(NSString*)url andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)uploadFile:(NSData*)file andName:(NSString*)name andPars:(NSDictionary*)par andUrl:(NSString*)url andModel:(Class)model andSubModel:(Class)subModel andSuccess:(Success)success andFailed:(Failed)failed andProgress:(Gress)gress;
-(void)httpForDownAndCount:(NSString*)file andProgress:(DGress)gress andSuccess:(Success)success;
@end
