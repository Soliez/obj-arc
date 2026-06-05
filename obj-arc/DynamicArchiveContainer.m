//
//  DynamicArchiveContainer.m
//  obj-arc
//
//  Created by Erik Solis  on 2026-06-03.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "DynamicArchiveContainer.h"

@implementation DynamicArchiveContainer

+ (BOOL)supportsSecureCoding
{
    return YES;
}


+ (NSDictionary<NSString *, id> *)encodableIvarsForObject:(id)obj
{
    NSMutableDictionary<NSString *, id> *results = [NSMutableDictionary dictionary];
    
    Class cls = [obj class];
    
    while (cls && cls != [NSObject class]){
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList(cls, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            const char *nameRaw = ivar_getName(ivar);
            const char *typeEncodingRaw = ivar_getTypeEncoding(ivar);
            
            if (!nameRaw || !typeEncodingRaw) { continue; }
            
            NSString *name = [NSString stringWithUTF8String:nameRaw];
            NSString *typeEncoding = [NSString stringWithUTF8String:typeEncodingRaw];
            
            id value = nil;
            
            if ([typeEncoding hasPrefix:@"@"]) {
                /*
                 Object Ivars
                 */
                value = object_getIvar(obj, ivar);
                
                if (value && [self isFoundationArchivableObject: value]){
                    results[name] = value;
                } else if (value) {
                    DynamicArchiveContainer *archivedValue = [[DynamicArchiveContainer alloc] initWithObject:value];
                    results[name] = archivedValue;
                } else {
                    results[name] = [NSNull null];
                }
            } else {
                /*
                 TODO: Implement primitive Ivar archival support
                 */
                results[name] = [NSString stringWithFormat:@"<Unsupported Primitive Ivar: %@>", typeEncoding];
            }
        }
        free(ivars);
        cls = class_getSuperclass(cls);
    }
    return [results copy];
}


+ (BOOL)isFoundationArchivableObject:(id)obj
{
    if (!obj) { return YES; } // nil values are already archivable
    
    static NSSet<Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet<Class> *classes = [NSSet setWithObjects:
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
    });
    
    // obj is an instance of a class in the allow-list
    for (Class cls in classes) {
        if ([obj isKindOfClass:cls]) { return YES; }
    }
    
    // obj is a class that explicitly conforms to either codable protocol
    if ([obj conformsToProtocol:@protocol(NSSecureCoding)] || [obj conformsToProtocol:@protocol(NSSecureCoding)]) {
        return YES;
    }
    
    // all checks failed, obj is not archivable by default
    return NO;
}



- (instancetype)initWithObject:(id)obj
{
    self = [super init];
    if (!self) { return nil; }

    _originalClassName = NSStringFromClass([obj class]);
    _encodedIvars = [[self class] encodableIvarsForObject: obj];
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.originalClassName forKey:@"originalClassName"];
    [coder encodeObject:self.encodedIvars forKey:@"encodedIvars"];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (!self) { return nil; }
    
    _originalClassName = [coder decodeObjectOfClass:[NSString class] forKey:@"originalClassName"];
    
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
    _encodedIvars = [coder decodeObjectOfClasses:whitelist forKey:@"encodedIvars"];
   
    return self;
}


- (id)reconstructedObject
{
    Class cls = NSClassFromString(self.originalClassName);
    
    if (!cls) {
        NSLog(@"Could not find class %@", self.originalClassName);
        return nil;
    }
    
    id obj = [[cls alloc] init];
    
    if (!obj) {
        NSLog(@"Could not create an instance of %@", self.originalClassName);
        return nil;
    }
    
    for (NSString *ivarName in self.encodedIvars) {
        Ivar ivar = class_getInstanceVariable(cls, [ivarName UTF8String]);
        if (!ivar) { continue; }
        
        const char *typeEncodingRaw = ivar_getTypeEncoding(ivar);
        if (!typeEncodingRaw) { continue; }
        
        NSString *typeEncoding = [NSString stringWithUTF8String:typeEncodingRaw];
        if ([typeEncoding hasPrefix:@"@"]) { continue; }
        
        id value = self.encodedIvars[ivarName];
        
        if (value == [NSNull null]) {
            value = nil;
        } else if ([value isKindOfClass:[DynamicArchiveContainer class]]) {
            value = [value reconstructedObject];
        }
        
        object_setIvar(obj, ivar, value);
    }
    
    return obj;
}


@end
