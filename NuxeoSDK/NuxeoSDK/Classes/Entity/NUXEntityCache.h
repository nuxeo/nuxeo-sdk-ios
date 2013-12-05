//
//  NUXEntityCache.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 05/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXEntity.h"

@protocol NUXEntityPersistable <NSObject>

@required
-(NSString *)entityId;

@end

@interface NUXEntityCache : NSObject

+(NUXEntityCache *)instance;

-(NUXEntity<NUXEntityPersistable> *)entityWithId:(NSString *)entityId class:(Class)entityClass;
-(BOOL)removeEntityWithId:(NSString *)entityId class:(Class)entityClass;

-(BOOL)saveEntity:(NUXEntity<NUXEntityPersistable> *)entity;

@end
