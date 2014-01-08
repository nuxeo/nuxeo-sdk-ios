//
//  NUXConstants.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-21.
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

#import <Foundation/Foundation.h>
#import "NUXException.h"

@class NUXRequest;
@class NUXEntity;

#if NS_BLOCKS_AVAILABLE
typedef void (^NUXBasicBlock)(void);
typedef void (^NUXResponseBlock)(NUXRequest *request);
typedef NSArray * (^NUXHierarchyBlock)(NUXEntity *entity, NSUInteger depth);
typedef BOOL (^NUXInvalidationBlock)(NUXEntity *entity);
#endif

#ifdef DEBUG
    #define NUXDebug(x, ...) NSLog(@"%s %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define NUXDebug(x, ...)
#endif