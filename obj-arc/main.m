//
//  main.m
//  obj-arc
//
//  Created by Erik Solis  on 2026-05-25.
//

#import <Foundation/Foundation.h>
#import <UniformTypeIdentifiers/UTType.h>
#import <AppKit/NSPasteboard.h>
#import <objc/runtime.h>


BOOL isCodable(id obj)
{
    if (!obj){ return NO; }
    Class class = object_getClass(obj);
    return ([obj conformsToProtocol:@protocol(NSCoding)] | [obj conformsToProtocol:@protocol(NSSecureCoding)]) ? YES : NO;
}

BOOL requiresSecureCoding(id obj)
{
    if (!obj){ return NO; }
    Class class = object_getClass(obj);
    return (![obj conformsToProtocol:@protocol(NSCoding)] && [obj conformsToProtocol:@protocol(NSSecureCoding)]) ? YES : NO;
}


// TODO: Implement NSKeyedArchive load/dump operations

NSData *DumpObject(id *obj);

id LoadObject(NSData *archive);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return EXIT_SUCCESS;
}
