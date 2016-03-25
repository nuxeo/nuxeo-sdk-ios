//
//  NUXDocument.h
//  NuxeoSDK
//  Created by Matthias ROUBEROL on 2013-11-18.
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

#import <UIKit/UIKit.h>

#import "NUXEntity.h"
#import "NUXEntityCache.h"

@interface NUXDocument : NUXEntity <NUXEntityPersistable>

@property (nonatomic) NSString* repository;
@property (nonatomic) NSString* uid;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* path;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* state;
@property (nonatomic) NSString* versionLabel;
@property (nonatomic) NSString* parentRef;
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* changeToken;
@property (nonatomic) NSDate* lastModified;
@property (nonatomic) BOOL isCheckedOut;

@property (nonatomic) NSMutableDictionary* properties;
@property (nonatomic) NSMutableArray* facets;
@property (nonatomic) NSMutableDictionary* contextParameters;

@end
