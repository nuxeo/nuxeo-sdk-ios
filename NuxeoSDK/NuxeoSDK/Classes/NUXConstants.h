//
//  NUXConstants.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 21/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NUXRequest;
@class NUXEntity;

#if NS_BLOCKS_AVAILABLE
typedef void (^NUXBasicBlock)(void);
typedef void (^NUXResponseBlock)(NUXRequest *request);
typedef NSArray * (^NUXHierarchyBlock)(NUXEntity *entity, NSUInteger depth);
typedef BOOL (^NUXInvalidationBlock)(NUXEntity *entity);
#endif

#ifdef DEBUG
    #define NUXDebug(x, ...) NSLog(@"%s %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define NUXDebug(x, ...)
#endif