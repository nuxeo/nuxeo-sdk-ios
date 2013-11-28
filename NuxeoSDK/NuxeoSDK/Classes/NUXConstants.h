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
typedef void (^NUXResponseBlock)(NUXRequest *);
typedef NSArray * (^NUXHierarchyBlock)(NUXEntity *);
#endif