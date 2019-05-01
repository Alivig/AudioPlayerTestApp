//
//  IATDataManager.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/23/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDataManager.h"

static NSString *documentsFolderName = @"TestApp";
static NSString *cachesFolderName = @"TestApp";

@implementation IATDataManager

+ (NSString*)filePathForKey:(NSString*)key inFolder:(NSString*)folder inDerictoriesDomain:(NSSearchPathDirectory)domain {
    if (key == nil || ![key isKindOfClass:[NSString class]]) {
        //  no file path for empty keys
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *totalPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folder]];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:totalPath isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:totalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [totalPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", key]];
}

+ (NSString*)documentsFilePathForKey:(NSString*)key {
    return [self filePathForKey:key inFolder:documentsFolderName inDerictoriesDomain:NSDocumentDirectory];
}

+ (NSString*)cachesFilePathForKey:(NSString*)key {
    return [self filePathForKey:key inFolder:cachesFolderName inDerictoriesDomain:NSCachesDirectory];
}

+ (BOOL)saveData:(NSData*)data withKey:(NSString*)key {
    NSString *filePath = [self documentsFilePathForKey:key];
    if (filePath == nil) {
        //  not a valid path. probably something wrong with key
        return NO;
    }
    return [data writeToFile:filePath atomically:YES];
}

+ (NSData*)dataForKey:(NSString *)key {
    NSString *filePath = [self documentsFilePathForKey:key];
    if (filePath == nil) {
        //  not a valid path. probably something wrong with key
        return nil;
    }
    return [NSData dataWithContentsOfFile:filePath];
}

+ (void)removeDataForKey:(NSString *)key {
    NSString *filePath = [self documentsFilePathForKey:key];
    if (filePath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

+ (BOOL)saveDataToCache:(NSData*)data withKey:(NSString*)key {
    NSString *filePath = [self cachesFilePathForKey:key];
    if (filePath == nil) {
        //  not a valid path. probably something wrong with key
        return NO;
    }
    return [data writeToFile:filePath atomically:YES];
}

+ (NSData*)cacheDataForKey:(NSString *)key {
    NSString *filePath = [self cachesFilePathForKey:key];
    if (filePath == nil) {
        //  not a valid path. probably something wrong with key
        return nil;
    }
    return [NSData dataWithContentsOfFile:filePath];
}

+ (void)removeCacheDataForKey:(NSString *)key {
    NSString *filePath = [self cachesFilePathForKey:key];
    if (filePath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
