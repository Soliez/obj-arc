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
    return (conformsToNSCoding(obj) | conformsToNSSecureCoding(obj)) ? YES : NO;
}

BOOL supportsSecureCoding(id obj)
{
    if (!obj){ return NO; }
    return (conformsToNSCoding(obj) && conformsToNSSecureCoding(obj)) ? YES : NO;
}

BOOL requiresSecureCoding(id obj)
{
    if (!obj){ return NO; }
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
    
    [lines addObject:[NSString stringWithFormat:@"Responds to -count: %@", ([obj respondsToSelector:@selector(count)] ? @"YES" : @"NO")]];
    [lines addObject:[NSString stringWithFormat:@"Responds to -allKeys: %@", ([obj respondsToSelector:@selector(allKeys)] ? @"YES" : @"NO")]];
    
    NSString *message = [lines componentsJoinedByString:@"\n"];
    NSLog(@"%@", message);
}


id LoadObject(NSData *archiveData)
{
    NSError *error = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
                                     initForReadingFromData:archiveData
                                     error:&error];
    if (!unarchiver && error) {
        NSLog(@"Error: Failed to load initialize NSKeyedUnarchiver with Data '%@'. %@",
              archiveData,
              [error localizedDescription]);
        return nil;
    }
    
    id obj = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    return obj;
}

NSData *DumpObject(id obj)
{
    if (!obj) { return nil; }
    NSError *error = nil;
    BOOL secure = requiresSecureCoding(obj);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj
                                       requiringSecureCoding:secure
                                                       error:&error];
    if (!data && error) {
        NSLog(@"Error archiving object of class %@: %@", NSStringFromClass([obj class]), error.localizedDescription);
    }
    return data;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return EXIT_SUCCESS;
}

