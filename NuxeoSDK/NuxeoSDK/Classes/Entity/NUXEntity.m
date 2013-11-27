//
//  NUXEntity.m
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXEntity.h"

@implementation NUXEntity

-(id)initWithEntityType: (NSString *)entityType {
    self = [super init];
    if (self) {
        [self setValue:entityType forKeyPath:@"entityType"];
    }
    return self;
}

- (void)dealloc
{
    _entityType = nil;
    
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"NUXEntity of type %@", _entityType];
}
@end
