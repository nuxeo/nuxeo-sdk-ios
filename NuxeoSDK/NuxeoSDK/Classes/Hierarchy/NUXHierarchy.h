//
//  NUXHierarchy.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-26.
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
#import "NUXRequest.h"
#import "NUXDocument.h"
#import "NUXDocuments.h"

@interface NUXHierarchy : NSObject

@property (strong) NUXHierarchyBlock nodeBlock;
@property (strong) NUXInvalidationBlock nodeInvalidationBlock;
@property (strong) NUXBasicBlock completionBlock;
@property (strong) NUXBasicBlock failureBlock;
@property (readonly) NUXRequest *request;

@property BOOL automaticContentRefresh;
@property BOOL fetchContentWhileLoading;

-(NUXDocument *)nodeWithRef:(NSString *)nodeRef;
// Returns an array of NUXEntity corresponding to the document children.
-(NSArray *)childrenOfDocument:(NSString *)documentRef;
// Returns an array of NUXEntity corresponding to content of the document node.
-(NSArray *)contentOfDocument:(NUXDocument *)document;
// Returns an array of NUXEntity corresponding to the whole hierarchy nodes content
-(NSArray *)contentOfAllDocuments;
// Returns a lightweight NUXDocuments object form the root entry point.
-(NSArray *)childrenOfRoot;
-(BOOL)hasContentUnderNode:(NSString *)nodeRef;

-(void)loadWithRequest:(NUXRequest *)request;
-(void)resetCache;
-(bool)isLoaded;
-(void)waitUntilLoadingIsDone;

+(NUXHierarchy *)hierarchyWithName:(NSString *)name;

@end