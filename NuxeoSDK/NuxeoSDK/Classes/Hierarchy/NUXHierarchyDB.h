//
//  NUXHierarchyDB.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXDocument.h"

@interface NUXHierarchyDB : NSObject
+(NUXHierarchyDB *)shared;

-(void)createTableIfNeeded;
-(void)dropTable;
-(void)deleteNodesFromHierarchy:(NSString *)hierarchyName;
-(void)deleteContentForDocument:(NUXDocument *)document fromHierarchy:(NSString *)hierarchyName;

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NSString *)parentId andDepth:(NSInteger)depth;
-(void)insertcontent:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName forNode:(NSString *)nodeId;

-(NSArray *)selectNodesFromParent:(NSString *)parentId hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectContentFromNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectAllContentFromHierarchy:(NSString *)hierarchyName;
-(NSInteger)selectDepthForDocument:(NUXDocument *)document hierarchy:(NSString *)hierarchyName;

@end
