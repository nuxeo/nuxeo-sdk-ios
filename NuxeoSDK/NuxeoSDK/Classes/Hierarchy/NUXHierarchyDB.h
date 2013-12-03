//
//  NUXHierarchyDB.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUXHierarchyDB : NSObject
+(NUXHierarchyDB *)shared;

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NSString *)parentId;
-(NSArray *)selectNodes:(NSString *)parentId fromHierarchy:(NSString *)hierarchyName;

@end
