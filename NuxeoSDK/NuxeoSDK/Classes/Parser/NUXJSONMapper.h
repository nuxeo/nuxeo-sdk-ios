//
//  NUXJSONMapper.h
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

#import <Foundation/Foundation.h>

@interface NUXJSONMapper : NSObject

@property (nonatomic, retain, readonly) NSMutableDictionary * entityMapping;

+ (NUXJSONMapper *) sharedMapper;

- (void) registerEntityClass:(Class) bClass;

@end
