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

#import "TestClasses/TestPerson.h"
#import "IOHelper.h"
#import "DynamicArchiver.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TestPerson *person = [[TestPerson alloc] initWithName:@"Fyodor Dostoevsky" Age:@59];
        
        [DynamicArchiver logObject:person];
        
        NSError *error = nil;
        NSData *data = [DynamicArchiver dumpObjectToArchiveData:person error:&error];
        
        if (!data) {
            NSLog(@"Failed to archive object %@: %@", person, [error localizedDescription]);
            return EXIT_FAILURE;
        }
        
        NSLog(@"Size of archive in bytes: %lu", (unsigned long)data.length);
        NSLog(@"Archive data: %@", data);
        
        NSString *outFile = [NSString stringWithFormat:(@"/Users/erik/Developer/ObjC/obj-arc/obj-arc/TestOutput/%@_archived"), NSStringFromClass([person class])];
        
        NSData *archivePlist = [IOHelper convertPropertyList:data toFormat:NSPropertyListXMLFormat_v1_0];
        if (!archivePlist) {
            NSLog(@"Failed †ø convert archived object data %@ to a XML plist", data);
            return EXIT_FAILURE;
        }
        
        BOOL successfulWrite = [IOHelper writeData:archivePlist ToFile:outFile];
        if (successfulWrite)
        {
            NSLog(@"Wrote archived object to '%@'", outFile);
        } else {
            NSLog(@"Failed to write archived object to '%@'", outFile);
        }
        
        id restoredObj = [DynamicArchiver loadObjectFromArchiveData:data error:&error];
        
        if (!restoredObj) {
            NSLog(@"Failed to reconstruct class from archive data %@: %@", data, [error localizedDescription]);
            return EXIT_FAILURE;
        }
        
        NSLog(@"Reconstructed Object: %@", restoredObj);
        [DynamicArchiver logObject:restoredObj];
    }
    
    return EXIT_SUCCESS;
}
