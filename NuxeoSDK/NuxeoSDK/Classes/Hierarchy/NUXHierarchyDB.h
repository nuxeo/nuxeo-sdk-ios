//
//  NUXHierarchyDB.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-03.
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

#define kRootKey @"0"

@interface NUXHierarchyDB : NSObject
+(NUXHierarchyDB *)shared;

-(BOOL)isHierarchyLoaded:(NSString *)hierarchyName;
-(void)saveHierarchyLoaded:(NSString *)hierarchyName;

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
