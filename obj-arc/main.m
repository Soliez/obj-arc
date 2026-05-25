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


BOOL isArchivable(id obj);
NSData *DumpObject(id *obj);
id LoadObject(NSData *archive);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return EXIT_SUCCESS;
}
