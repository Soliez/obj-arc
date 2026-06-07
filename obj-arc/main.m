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
