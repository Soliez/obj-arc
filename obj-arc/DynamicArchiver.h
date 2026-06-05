#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicArchiver : NSObject

+ (BOOL)conformsToNSCoding:(id)obj;
+ (BOOL)conformsToNSSecureCoding:(id)obj;
+ (BOOL)isCodable:(id)obj;
+ (BOOL)supportsSecureCoding:(id)obj;

+ (void)logObject:(id)obj;

+ (nullable id)loadObjectFromArchiveData:(NSData *)archiveData;
+ (nullable NSData *)dumpObjectToArchiveData:(id)obj;

+ (nullable id)loadObjectFromArchiveData:(NSData *)archiveData error:(NSError **)error;
+ (nullable NSData *)dumpObjectToArchiveData:(id)obj error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
