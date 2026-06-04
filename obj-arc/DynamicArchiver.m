#import <objc/runtime.h>

#import "DynamicArchiver.h"


@implementation DynamicArchiver

// Runtime helpers
+ (BOOL)conformsToNSCoding:(id)obj
{
    return [obj conformsToProtocol:@protocol(NSCoding)] ? YES : NO;
}

+ (BOOL)conformsToNSSecureCoding:(id)obj
{
    return [obj conformsToProtocol:@protocol(NSSecureCoding)] ? YES : NO;
}

+ (BOOL)isCodable:(id)obj
{
    if (!obj){ return NO; }
    return ([self conformsToNSCoding:obj] | [self conformsToNSSecureCoding:obj]) ? YES : NO;
}

+ (BOOL)supportsSecureCoding:(id)obj
{
    if (!obj){ return NO; }
    return ([self conformsToNSCoding:obj] && [self conformsToNSSecureCoding:obj]) ? YES : NO;
}

+ (BOOL)requiresSecureCoding:(id)obj
{
    if (!obj){ return NO; }
    return (![self conformsToNSCoding:obj] && [self conformsToNSSecureCoding:obj]) ? YES : NO;
}

+ (Class)addNSCodingSupport:(Class)cls
{
    if (!class_addProtocol(cls, @protocol(NSCoding))) { return nil; }
    return cls;
}

+ (Class)addNSSecureCodingSupport:(Class)cls
{
    if (!class_addProtocol(cls, @protocol(NSSecureCoding))) { return nil; }
    return cls;
}


// Debug helpers
+ (void)logObject:(id)obj
{
    if (!obj) { NSLog(@"Error: Object is nil"); return; }
    Class cls = object_getClass(obj);
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Object: %@", (obj)]];
    [lines addObject:[NSString stringWithFormat:@"Class: %@", NSStringFromClass(cls)]];
    [lines addObject:[NSString stringWithFormat:@"Superclass: %@", NSStringFromClass(class_getSuperclass(cls))]];
    [lines addObject:[NSString stringWithFormat:@"Conforms to NSCoding: %@", ([self conformsToNSCoding:obj] ? @"YES" : @"NO")]];
    [lines addObject:[NSString stringWithFormat:@"Conforms to NSSecureCoding: %@", ([self conformsToNSSecureCoding:obj] ? @"YES" : @"NO")]];
    [lines addObject:[NSString stringWithFormat:@"Responds to -count: %@", ([obj respondsToSelector:@selector(count)] ? @"YES" : @"NO")]];
    [lines addObject:[NSString stringWithFormat:@"Responds to -allKeys: %@", ([obj respondsToSelector:@selector(allKeys)] ? @"YES" : @"NO")]];
    NSString *message = [lines componentsJoinedByString:@"\n"];
    NSLog(@"%@", message);
}


// NSKeyedArchive reading/writing helpers
+ (id)loadObjectFromArchiveData:(NSData *)archiveData
{
    if (!archiveData) { return nil; }
    NSError *error = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:archiveData error:&error];
    if (!unarchiver && error) {
        NSLog(@"Error: Failed to initialize NSKeyedUnarchiver with Data '%@'. %@", archiveData, error.localizedDescription);
        return nil;
    }
    id obj = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    return obj;
}

+ (NSData *)dumpObjectToArchiveData:(id)obj
{
    if (!obj) { return nil; }
    NSError *error = nil;
    BOOL useSecureCoding = [self requiresSecureCoding:obj];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:useSecureCoding error:&error];
    if (!data && error) {
        NSLog(@"Error archiving object of class %@: %@", NSStringFromClass([obj class]), error.localizedDescription);
    }
    return data;
}

@end
