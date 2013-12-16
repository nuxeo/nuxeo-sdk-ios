//
//  NUXException.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 16/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXException.h"

@implementation NUXException

-(id)init
{
    self = [super init];
    if (self) {
        // Empty
    }
    return self;
}

+ (void)raise:(NSString *)name format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3)
{
    va_list args;
    @try {
        va_start(args, format);
        [NUXException raise:name format:format arguments:args];
    }
    @finally {
        va_end(args);
    }
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0)
{
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:argList];
    @throw [[NUXException alloc] initWithName:name reason:reason userInfo:nil];
}

@end
