#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicArchiver : NSObject

+ (BOOL)conformsToNSCoding:(id)obj;
+ (BOOL)conformsToNSSecureCoding:(id)obj;
+ (BOOL)isCodable:(id)obj;
+ (BOOL)supportsSecureCoding:(id)obj;

//+ (nullable Class)addNSCodingSupport:(Class)cls;
//+ (nullable Class)addNSSecureCodingSupport:(Class)cls;

+ (void)logObject:(id)obj;

+ (nullable id)loadObjectFromArchiveData:(NSData *)archiveData;
+ (nullable NSData *)dumpObjectToArchiveData:(id)obj;

@end

NS_ASSUME_NONNULL_END
