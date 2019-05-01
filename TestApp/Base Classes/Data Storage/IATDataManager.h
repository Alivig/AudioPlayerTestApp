//
//  IATDataManager.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/23/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IATDataManager : NSObject

//  saves <data> to file with <key> filename to Documents folder
+ (BOOL)saveData:(NSData*)data withKey:(NSString*)key;
//  tries to retrieve NSData from file with <key> filename from Documents folder
+ (NSData*)dataForKey:(NSString*)key;
//  removes data in Documents folder for specified <key>
+ (void)removeDataForKey:(NSString*)key;

//  saves <data> to file with <key> filename to Caches folder
+ (BOOL)saveDataToCache:(NSData*)data withKey:(NSString*)key;
//  tries to retrieve NSData from file with <key> filename from Caches folder
+ (NSData*)cacheDataForKey:(NSString*)key;
//  removes data in Caches folder for specified <key>
+ (void)removeCacheDataForKey:(NSString*)key;

@end
