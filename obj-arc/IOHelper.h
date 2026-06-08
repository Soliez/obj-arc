//
//  IOHelper.h
//  obj-arc
//
//  Created by Erik Solis  on 2026-06-07.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOHelper : NSObject

+ (BOOL)writeData:(NSData *)data ToURL:(NSURL *)url;
+ (BOOL)writeData:(NSData *)data ToFile:(NSString *)path;

+ (NSData *)convertPropertyList:(NSData *)data toFormat:(NSPropertyListFormat)format;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
