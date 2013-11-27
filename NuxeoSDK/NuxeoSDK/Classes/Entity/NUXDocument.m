//
//  NUXDocument.m
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXDocument.h"

@implementation NUXDocument

-(id)init
{
    self = [super initWithEntityType:@"document"];
    if (self) {
        // Initialize
    }
    return self;
}

- (void)dealloc
{
    _repository = nil;
    _uid = nil;
    _name = nil;
    _path = nil;
    _type = nil;
    _state = nil;
    _versionLabel = nil;
    _title = nil;
    _changeToken = nil;
    _lastModified = nil;
    
    _properties = nil;
    _facets = nil;
    _context = nil;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ path=%@ type=%@", [self class], _uid, _path, _type];
}
@end
