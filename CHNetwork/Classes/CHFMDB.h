//
//  CHFMDB.h
//  KJ
//
//  Created by chenghao on 2017/11/27.
//  Copyright © 2017年 cpcp5588.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "FMDBMigrationManager.h"
@interface CHFMDB : NSObject
+(instancetype)sharedDataBase;
-(void)cacheWithKey:(NSString*)key andCache:(NSData*)cache;
- (id)getCacheWithKey:(NSString*)key andModel:(Class)model;
- (id)getCacheWithKey:(NSString*)key andModel:(Class)model andSubModel:(Class)subModel;

-(void) open :(NSString*)key;
-(void) deleteCacheWithKey:(NSString*)key ;
-(void)deleteAll;

@end

