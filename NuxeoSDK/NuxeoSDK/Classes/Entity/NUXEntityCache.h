//
//  NUXEntityCache.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-05.
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
#import "NUXEntity.h"

/**
 *  Simple Entity Cache; without any cleanup logic.
 */
@interface NUXEntityCache : NSObject

+(NUXEntityCache *)instance;

-(id)entityWithId:(NSString *)entityId class:(Class)entityClass;
-(NSArray *)entitiesFromList:(NSString *)aListName;

-(BOOL)saveEntity:(NUXEntity<NUXEntityPersistable> *)entity;
-(BOOL)saveEntities:(NSArray *)entities withListName:(NSString *)aListName error:(NSError **)error;

-(BOOL)removeEntityWithId:(NSString *)entityId class:(Class)entityClass;
-(BOOL)removeEntitiesList:(NSString *)aListName;

-(BOOL)hasEntityWithId:(NSString *)entityId class:(Class)entityClass;
-(BOOL)hasEntityList:(NSString *)aListName;

@end
