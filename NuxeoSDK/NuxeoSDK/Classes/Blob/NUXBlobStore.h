//
//  NUXBlobStore.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-04.
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
#import "NUXDocument.h"

@interface NUXBlobStore : NSObject

@property NSNumber *countLimit;
@property NSNumber *sizeLimit;

@property NSString *filenameProperty;
@property NSString *digestProperty;

-(NSString *)blob:(NSString *)digest;
-(NSString *)blobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(BOOL)hasBlob:(NSString *)digest;
-(BOOL)hasBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(BOOL)removeBlob:(NSString *)digest;
-(BOOL)removeBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(NSString *)saveBlobFromPath:(NSString *)path withDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath error:(NSError **)error;

-(void)reset;
-(NSInteger)count;

+(id)instance;
@end
