//
//  CHKeyChainStore.h
//  ios_care_user
//
//  Created by wdkl201810 on 2019/5/6.
//  Copyright © 2019 wdkl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHKeyChainStore : NSObject
+ (void)save:(NSString*)service data:(id)data;
+ (id)load:(NSString*)service;
+ (void)deleteKeyData:(NSString*)service;
@end

NS_ASSUME_NONNULL_END
