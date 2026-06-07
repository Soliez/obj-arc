//
//  TestPerson.h
//  obj-arc
//
//  Created by Erik Solis  on 2026-06-07.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestPerson : NSObject
{
@public
    NSString *_name;
    NSNumber *_age;
}

- (instancetype)initWithName:(NSString *)name Age:(NSNumber *)age;
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
