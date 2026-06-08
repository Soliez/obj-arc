//
//  IOHelper.m
//  obj-arc
//
//  Created by Erik Solis  on 2026-06-07.
//

#import "IOHelper.h"

@implementation IOHelper

+ (BOOL)writeData:(NSData *)data ToURL:(NSURL *)url
{
    NSError *error = nil;
    [data writeToURL:url options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"<%@> Failed to write data '%@' to URL '%@': %@", NSStringFromClass([self class]), data, url, [error localizedDescription]);
        return NO;
    }
    return YES;
}

+ (BOOL)writeData:(NSData *)data ToFile:(NSString *)path
{
    NSError *error = nil;
    [data writeToFile:[path stringByExpandingTildeInPath] options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"<%@> Failed to write data '%@' to path '%@': %@", NSStringFromClass([self class]), data, path, [error localizedDescription]);
        return NO;
    }
    return YES;
}


+ (NSData *)convertPropertyList:(NSData *)data toFormat:(NSPropertyListFormat)format
{
    NSError *error = nil;
    NSPropertyListFormat inputFormat = 0;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&inputFormat error:&error];
    if (!plist) {
        NSLog(@"Failed to parse property list data as plist (format %lu): %@", (unsigned long)inputFormat, error);
        return nil;
    }

    if (![NSPropertyListSerialization propertyList:plist isValidForFormat:format]) {
        NSLog(@"Parsed property list is not valid for requested format %lu: %@", (unsigned long)format, plist);
        return nil;
    }

    NSData *outData = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:&error];
    if (!outData) {
        NSLog(@"Failed to serialize property list to requested format %lu: %@", (unsigned long)format, error);
        return nil;
    }
    return outData;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self];
}

@end
