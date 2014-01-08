//
//  NUXException.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-16-12.
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
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
 *     Arnaud Kervern
 */

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
