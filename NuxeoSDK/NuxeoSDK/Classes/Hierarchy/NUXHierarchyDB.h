//
//  NUXHierarchyDB.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 03/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXDocument.h"

#define kRootKey @"0"

@interface NUXHierarchyDB : NSObject
+(NUXHierarchyDB *)shared;

-(bool)rootExistForHierarchy:(NSString *)hierarchyName;
-(void)createTableIfNeeded;
-(void)dropTable;
-(void)deleteNodesFromHierarchy:(NSString *)hierarchyName;
-(void)deleteContentForDocument:(NUXDocument *)document fromHierarchy:(NSString *)hierarchyName;

-(void)insertNodes:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName withParent:(NUXDocument *)parent andDepth:(NSInteger)depth;
-(void)insertcontent:(NSArray *)docs fromHierarchy:(NSString *)hierarchyName forNode:(NSString *)nodeId;

-(NUXDocument *)selectNode:(NSString *)nodeRef hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectNodesFromParent:(NSString *)parentRef hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectContentFromNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectAllContentFromHierarchy:(NSString *)hierarchyName;
-(NSInteger)selectDepthForDocument:(NSString *)documentId hierarchy:(NSString *)hierarchyName;

-(BOOL)hasContentForNode:(NSString *)nodeId hierarchy:(NSString *)hierarchyName;
-(NSArray *)selectIdsFromParent:(NSString *)parentRef hierarchy:(NSString *)hierarchyName;


@end
