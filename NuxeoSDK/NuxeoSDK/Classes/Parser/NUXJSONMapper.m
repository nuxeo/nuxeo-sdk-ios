//
//  NUXJSONMapper.m
//  NuxeoSDK
//  Created by Matthias ROUBEROL on 2013-11-15.
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/),
 *     SmartNSoft (http://www.smartnsoft.com), and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     Matthias ROUBEROL
 */

#import "NUXJSONMapper.h"

#import "NUXEntity.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"

#define kNUXEntityTypeParam @"entity-type"


@implementation NUXJSONMapper

+ (NUXJSONMapper *) sharedMapper
{
    static dispatch_once_t pred = 0;
    __strong static NUXJSONMapper * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
        [_sharedObject setup];
    });
    return _sharedObject;
}

- (void) setup
{
    // default mapping map
    _entityMapping = [NSMutableDictionary dictionary];
    
    [self registerEntityClass:[NUXDocument class]];
    [self registerEntityClass:[NUXDocuments class]];
}


- (void) registerEntityClass:(Class) bClass
{
    // Create empty instance to get entity-type
    id obj = [[bClass alloc] init];
    if (![obj isKindOfClass:[NUXEntity class]]) {
        [NSException raise:@"Class error" format:@"Trying to register class %@ without inherite %@ class.", bClass, [NUXEntity class]];
    }
    [self.entityMapping setValue:bClass forKey:[obj valueForKey:@"entityType"]];
}

- (void)dealloc
{
    _entityMapping = nil;
}

@end
