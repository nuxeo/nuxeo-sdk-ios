//
//  NUXDocuments.m
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXDocuments.h"

@implementation NUXDocuments

-(id)init
{
    self = [super initWithEntityType:@"documents"];
    if (self) {
        // Initialize
    }
    return self;
}

- (void)dealloc
{
    _errorMessage = nil;
    _entries = nil;
}

@end
