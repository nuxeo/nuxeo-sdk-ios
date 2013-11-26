//
//  NUXDocuments.h
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

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
