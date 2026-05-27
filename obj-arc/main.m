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


BOOL conformsToNSCoding(id obj)
{
    return [obj conformsToProtocol:@protocol(NSCoding)] ? YES : NO;
}

BOOL conformsToNSSecureCoding(id obj)
{
    return [obj conformsToProtocol:@protocol(NSSecureCoding)] ? YES : NO;
}

BOOL isCodable(id obj)
{
    if (!obj){ return NO; }
    Class class = object_getClass(obj);
    return (conformsToNSCoding(obj) | conformsToNSSecureCoding(obj)) ? YES : NO;
}

BOOL requiresSecureCoding(id obj)
{
    if (!obj){ return NO; }
    Class class = object_getClass(obj);
    return (!conformsToNSCoding(obj) && conformsToNSSecureCoding(obj)) ? YES : NO;
}

static void LogObject(id obj)
{
    if (!obj) { NSLog(@"Error: Object is nil"); }
    
    Class class = object_getClass(obj);
    
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    
    [lines addObject:[NSString stringWithFormat:@"Object: %@", (obj)]];
    [lines addObject:[NSString stringWithFormat:@"Class: %@", NSStringFromClass(class)]];
    [lines addObject:[NSString stringWithFormat:@"Superclass: %@", NSStringFromClass(class_getSuperclass(class))]];
    [lines addObject:[NSString stringWithFormat:@"Conforms to NSCoding: %@", (conformsToNSCoding(obj) ? @"YES" : @"NO")]];
    [lines addObject:[NSString stringWithFormat:@"Conforms to NSSecureCoding: %@", conformsToNSSecureCoding(obj) ? @"YES" : @"NO"]];
    
    NSString *message = [lines componentsJoinedByString:@"\n"];
    NSLog(@"%@", message);
}


// TODO: Implement NSKeyedArchive load/dump operations
NSData *DumpObject(id *obj);
id LoadObject(NSData *archive);



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return EXIT_SUCCESS;
}
