//
//  DynamicArchiveContainer.h
//  obj-arc
//
//  Created by Erik Solis  on 2026-06-03.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicArchiveContainer : NSObject <NSSecureCoding>

@property (nonatomic, copy, readonly) NSString *originalClassName;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *encodedIvars;

- (instancetype)initWithObject:(id)obj;
- (nullable id)reconstructedObject;

@end

NS_ASSUME_NONNULL_END
