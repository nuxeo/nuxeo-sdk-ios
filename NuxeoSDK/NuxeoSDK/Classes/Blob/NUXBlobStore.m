//
//  NUXBlobStore.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 04/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXBlobStore.h"
#import "NUXConstants.h"

#define kStoreFolderName @"_blobStore"

@implementation NUXBlobStore {
    NSMutableArray *_blobsAccess;
}

-(id)init
{
    self = [super init];
    if (self) {
        _blobsAccess = [NSMutableArray new];
        self.countLimit = @(100);
        self.sizeLimit = @(-1);
        
        [self recomputeBlobAccess];
    }
    return self;
}

-(void)reset
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSString *blobStorePath = [self blobStorePath];
    if (![manager removeItemAtPath:blobStorePath error:&error]) {
        [NSException raise:@"Unable to reset blob store" format:@"Can't delete blob store folder at path %@. %@", blobStorePath, error];
    }
    [_blobsAccess removeAllObjects];
}

-(NSInteger)count
{
    return [_blobsAccess count];
}

#pragma mark -

-(NSString *)blob:(NSString *)digest
{
    if (!(digest && [self hasBlob:digest])) {
        return NULL;
    }
    [self updateAccessForDigest:digest];
    return [self blobPath:digest];
}

-(BOOL)hasBlob:(NSString *)digest
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self blobPath:digest]];
}

-(BOOL)removeBlob:(NSString *)digest
{
    if (!(digest && [self hasBlob:digest])) {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[self blobPath:digest] error:nil];
    [_blobsAccess removeObject:digest];
    return YES;
}

-(NSString *)saveBlobFromPath:(NSString *)path withDigest:(NSString *)digest
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:path]) {
        return NULL;
    }
    
    NSError *error;
    [self removeBlob:digest];
    BOOL ret = [fileManager copyItemAtPath:path toPath:[self blobPath:digest] error:&error];
    if (!ret) {
        NUXDebug(@"Can't save file localy. %@", error);
        return NULL;
    }
    
    [_blobsAccess insertObject:digest atIndex:0];
    [self cleanStore];
    return [self blobPath:digest];
}

#pragma mark -

-(NSString *)blobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath
{
    return [self blob:[self digestFromDocument:document metadataXPath:xpath]];
}


-(BOOL)hasBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath
{
    return [self hasBlob:[self digestFromDocument:document metadataXPath:xpath]];
}

-(BOOL)removeBlobFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath
{
    return [self removeBlob:[self digestFromDocument:document metadataXPath:xpath]];
}


-(NSString *)saveBlobFromPath:(NSString *)path withDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath
{
    return [self saveBlobFromPath:path withDigest:[self digestFromDocument:document metadataXPath:xpath]];
}

#pragma mark -
#pragma mark Internal methods

-(void)cleanStore {
    // TODO
}

-(void)updateAccessForDigest:(NSString *)digest {
    [_blobsAccess removeObject:digest];
    [_blobsAccess insertObject:digest atIndex:0];
}

-(void)recomputeBlobAccess {
    [_blobsAccess removeAllObjects];
    NSError *error;
    NSArray *blobs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self blobStorePath] error:&error];
    if (!blobs) {
        [NSException raise:@"Can't read dir content" format:@"Unable to read blob store files content. %@", error];
    }
    [_blobsAccess addObjectsFromArray:blobs];
}

-(NSString *)blobPath:(NSString *)digest {
    return [[self blobStorePath] stringByAppendingPathComponent:digest];
}

-(NSString *)blobStorePath {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[directories objectAtIndex:0] stringByAppendingPathComponent:kStoreFolderName];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager isReadableFileAtPath:path]) {
        NSError *error;
        if (![manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
            [NSException raise:@"Can't create blob store folder" format:@"Unable to create blob store folder at path: %@. %@", path, error];
        }
        NUXDebug(@"Blob store folder create at path %@", path);
    }
    return path;
}

-(NSString *)digestFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath {
    NSDictionary *property = [document.properties valueForKey:xpath];
    if (!property) {
        return NULL;
    }
    return [property valueForKey:@"digest"];
}

#pragma mark -

+(id)instance {
    static dispatch_once_t pred = 0;
    static NUXBlobStore *__strong _shared = nil;
    
    dispatch_once(&pred, ^{
        _shared = [NUXBlobStore new];
    });
    
    return _shared;
}

@end
