#import <objc/runtime.h>

#import "DynamicArchiver.h"
#import "DynamicArchiveContainer.h"


@implementation DynamicArchiver

// Runtime helpers
+ (BOOL)conformsToNSCoding:(id)obj
{
    if (!obj) { return NO; }
    return [obj conformsToProtocol:@protocol(NSCoding)];
}

+ (BOOL)conformsToNSSecureCoding:(id)obj
{
    if (!obj) { return NO; }
    return [obj conformsToProtocol:@protocol(NSSecureCoding)];
}

+ (BOOL)isCodable:(id)obj
{
    if (!obj){ return NO; }
    return ([self conformsToNSCoding:obj] || [self conformsToNSSecureCoding:obj]) ? YES : NO;
}

+ (BOOL)supportsSecureCoding:(id)obj
{
    if (!obj) { return NO; }
    Class cls = [obj class];
    if (![cls conformsToProtocol:@protocol(NSSecureCoding)]) { return NO; }
    if (![cls respondsToSelector:@selector(supportsSecureCoding)]) { return NO; }
    return [cls supportsSecureCoding];
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
    NSError *error = nil;
    id obj = [self loadObjectFromArchiveData:archiveData error:&error];
    if (!obj) {
        NSLog(@"Failed to unarchive data '%@': %@", archiveData, error.localizedDescription);
        return nil;
    }
    return obj;
}

+ (id)loadObjectFromArchiveData:(NSData *)archiveData error:(NSError **)error
{
    if (!archiveData) {
        if (error) {
            *error = [NSError errorWithDomain:@"DynamicArchiver"
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey: @"Unable to unarchive nil data"}];
        }
        return nil;
    }
    
    NSSet *whitelist = [NSSet setWithObjects:
        [NSDictionary class],
        [NSMutableDictionary class],
        [NSArray class],
        [NSMutableArray class],
        [NSSet class],
        [NSMutableSet class],
        [NSString class],
        [NSNumber class],
        [NSData class],
        [NSDate class],
        [NSURL class],
        [NSNull class],
        nil
    ];
    
    id obj = nil;
    
    @try {
        obj = [NSKeyedUnarchiver unarchivedObjectOfClasses:whitelist
                                                  fromData:archiveData
                                                     error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"DynamicArchiver"
                                         code:4
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Exception raised during unarchiving: %@", exception.reason ?: exception.name]}];
        }
        return nil;
    }
    
    /*
     If the unarchived object is an instance of our DynamicArchiveContainer class,
    reconstruct the original object using the classes reconstructedObject method
    */
    if ([obj isKindOfClass:[DynamicArchiveContainer class]]) {
        return [obj reconstructedObject];
    }
    
    return obj;
}


+ (NSData *)dumpObjectToArchiveData:(id)obj
{
    NSError *error = nil;
    NSData *data = [self dumpObjectToArchiveData:obj error:&error];
    
    if (!data && error) {
        NSLog(@"Error archiving object %@: %@", obj, error.localizedDescription);
    }
    return data;
}

+ (NSData *)dumpObjectToArchiveData:(id)obj error:(NSError **)error
{
    if (!obj){
        if (error) {
            *error = [NSError errorWithDomain:@"DynamicArchiver"
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot archive nil object"}
            ];
        }
        return nil;
    }
    
    id rootObject = obj;
    BOOL requiringSecureCoding = NO;
    
    if ([self supportsSecureCoding:obj]) {
        requiringSecureCoding = YES;
    } else if ([self conformsToNSCoding:obj]) {
        requiringSecureCoding = NO;
    } else {
        rootObject = [[DynamicArchiveContainer alloc] initWithObject:obj];
        requiringSecureCoding = YES;
    }
    
    NSData *data = nil;
    
    @try {
        data = [NSKeyedArchiver archivedDataWithRootObject:rootObject
                                     requiringSecureCoding:requiringSecureCoding
                                                     error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"DynamicArchiver"
                                         code:2
                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Exception raised during archiving: %@", exception.reason ?: exception.name]}
            ];
        }
        
        return nil;
    }
    
    return data;
}

@end
