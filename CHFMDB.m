//
//  CHFMDB.m
//  KJ
//
//  Created by chenghao on 2017/11/27.
//  Copyright © 2017年 cpcp5588.com. All rights reserved.
//

#import "CHFMDB.h"
#import <YYModel/YYModel.h>
@implementation CHFMDB{
    FMDatabaseQueue  *_queue;
    NSString *_currentKey;
}

static CHFMDB* _instance = nil;

+(instancetype) sharedDataBase
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    NSString *dbKey =  [NSString stringWithFormat:@"user_%d",[CHUserDefaults getUser].data._id];
    [_instance open:dbKey];
    return _instance ;
}
-(void) close {
    [_queue close];
    _currentKey = nil;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [CHFMDB sharedDataBase] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [CHFMDB sharedDataBase] ;
}


-(void) open :(NSString*)key {
    @synchronized(self) {
        if ([_currentKey isEqualToString:key]){
            NSLog(@"Current key is %@  , will not open new database " , key);
            return;
        }
        if (_queue !=nil){
            NSLog(@"Closing database for %@" , key);
            [self close];
        }
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",key]];
        NSError *error;
        NSLog(@"Migrate for database %@" , filePath);
        NSBundle *parentBundle = [NSBundle bundleForClass:NSClassFromString(@"CHFMDB")];
        NSBundle *migrationBundle = [NSBundle bundleWithPath:[parentBundle pathForResource:@"Migrations" ofType:@"bundle"]];
        FMDBMigrationManager *manager = [FMDBMigrationManager managerWithDatabaseAtPath:filePath migrationsBundle:migrationBundle];
        NSLog(@"Has `schema_migrations` table?: %@", manager.hasMigrationsTable ? @"YES" : @"NO");
        if (!manager.hasMigrationsTable){
            [manager createMigrationsTable: &error];
        }
        BOOL success = [manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
        NSLog(@"Origin Version: %llu", manager.originVersion);
        NSLog(@"Current version: %llu", manager.currentVersion);
        NSLog(@"All migrations: %@", manager.migrations);
        NSLog(@"Applied versions: %@", manager.appliedVersions);
        NSLog(@"Pending versions: %@", manager.pendingVersions);
        if (success){
            _currentKey = key;
            _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
            
            NSLog(@"Open db successfully for file %@",filePath);
        }else{
            NSLog(@"Failed when doing migration: %@ %@", error, [error userInfo]);
        }
    }
}
NSString *insert = @"INSERT OR REPLACE INTO model_cache (cacheId, cacheInfo) values (?,?) ";
-(void)cacheWithKey:(NSString*)key andCache:(NSData*)cache{
    if (cache) {
        [_queue inDatabase:^(FMDatabase *_db) {
            [_db beginTransaction ];
            [_db executeUpdate:insert withArgumentsInArray: @[key,cache]];
            [_db commit ];
            [_db closeOpenResultSets];
        }];
    }
}
- (id)getCacheWithKey:(NSString*)key andModel:(Class)model andSubModel:(Class)subModel{
    __block NSDictionary *responsedic;
    [_queue inDatabase:^(FMDatabase *_db) {
        FMResultSet *res = [_db executeQuery:@"SELECT * FROM model_cache WHERE cacheId = ?",key];
        NSData* cache;
        while ([res next]) {
            cache = [res dataForColumn:@"cacheInfo"];
            responsedic = [NSJSONSerialization JSONObjectWithData:cache options:NSJSONReadingMutableLeaves error:nil];
        }
        [res close];
    }];
    if (subModel) {
        return [NSArray yy_modelArrayWithClass:subModel json:responsedic];
    }else{
        return [model yy_modelWithJSON:responsedic];
    }
}

- (id)getCacheWithKey:(NSString*)key andModel:(Class)model{
    return [self getCacheWithKey:key andModel:model andSubModel:nil];
}
-(void) deleteCacheWithKey:(NSString*)key {
    [_queue inDatabase:^(FMDatabase *_db) {
        BOOL success = [_db executeUpdate:@"delete from 'model_cache' where cacheId = ?",key];
        if (success) {
            [_db closeOpenResultSets];
        }
    }];
}
-(void)deleteAll{
    [_queue inDatabase:^(FMDatabase *_db) {

    }];
}


@end
