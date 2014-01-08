//
//  NUXDocuments.h
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

@interface NUXDocuments : NUXEntity

@property (nonatomic) BOOL isPaginable;
@property (nonatomic) NSInteger resultsCount;
@property (nonatomic) NSInteger pageSize;
@property (nonatomic) NSInteger maxPageSize;
@property (nonatomic) NSInteger currentPageSize;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) BOOL isPreviousPageAvailable;
@property (nonatomic) BOOL isNextPageAvailable;
@property (nonatomic) BOOL isLastPageAvailable;
@property (nonatomic) BOOL isSortable;
@property (nonatomic) BOOL hasError;
@property (nonatomic) NSString *errorMessage;
@property (nonatomic) NSInteger totalSize;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger pageCount;

@property (nonatomic) NSArray *entries;

@end
