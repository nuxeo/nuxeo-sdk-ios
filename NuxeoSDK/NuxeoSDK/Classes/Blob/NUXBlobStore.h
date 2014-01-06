//
//  NUXBlobStore.h
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 04/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXDocument.h"

@interface NUXBlobStore : NSObject

@property NSNumber *countLimit;
@property NSNumber *sizeLimit;

@property NSString *filenameProperty;
@property NSString *digestProperty;

-(NSString *)blob:(NSString *)digest;
-(NSString *)blobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(BOOL)hasBlob:(NSString *)digest;
-(BOOL)hasBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(BOOL)removeBlob:(NSString *)digest;
-(BOOL)removeBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath;

-(NSString *)saveBlobFromPath:(NSString *)path withDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath error:(NSError **)error;

-(void)reset;
-(NSInteger)count;

+(id)instance;
@end
