//
//  NUXDocument.h
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NUXEntity.h"
#import "NUXEntityCache.h"

@interface NUXDocument : NUXEntity <NUXEntityPersistable>

@property (nonatomic) NSString* repository;
@property (nonatomic) NSString* uid;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* path;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* state;
@property (nonatomic) NSString* versionLabel;
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* changeToken;
@property (nonatomic) NSDate* lastModified;
@property (nonatomic) BOOL isCheckedOut;

@property (nonatomic) NSMutableDictionary* properties;
@property (nonatomic) NSMutableArray* facets;
@property (nonatomic) NSMutableDictionary* context;

@end
