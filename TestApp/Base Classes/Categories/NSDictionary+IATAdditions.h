//
//  NSDictionary+IATAdditions.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/25/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IATAdditions)

- (NSString*)nonEmptyStringOrNilFromKey:(NSString*)key;

@end
