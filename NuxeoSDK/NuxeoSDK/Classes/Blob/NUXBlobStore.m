//
//  NUXBlobStore.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 04/12/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXBlobStore.h"
#import "NUXConstants.h"

#define kStoreFolderName @"org.nuxeo.cache.blob"

@implementation NUXBlobStore {
    NSMutableArray *_blobsAccess;
    NSNumber *_currentSize;
}

-(id)init
{
    self = [super init];
    if (self) {
        _blobsAccess = [NSMutableArray new];
        _currentSize = @(0);
        self.countLimit = @(100);
        self.sizeLimit = @(-1);
        
        
        [self recomputeBlobAccess];
    }
    return self;
}

- (void)dealloc
{
    _blobsAccess = Nil;
    _currentSize = Nil;
    _countLimit = Nil;
    _sizeLimit = Nil;
}

-(void)reset
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSString *blobStorePath = [self blobStorePath];
    if (![manager removeItemAtPath:blobStorePath error:&error]) {
        [NUXException raise:@"Unable to reset blob store" format:@"Can't delete blob store folder at path %@. %@", blobStorePath, error];
    }
    [_blobsAccess removeAllObjects];
    _currentSize = @(0);
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
    
    [self removeBlobFileWithDigest:digest];
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
    NSString *blobPath = [self blobPath:digest];

    BOOL ret = [fileManager copyItemAtPath:path toPath:blobPath error:&error];
    if (!ret) {
        NUXDebug(@"Can't save file localy. %@", error);
        return NULL;
    }
    
    [_blobsAccess insertObject:digest atIndex:0];
    [self adjustFileSize:blobPath factor:1];
    [self cleanStore];
    return blobPath;
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
    BOOL countOverLimit = [self.countLimit intValue] > 0 && [self.countLimit compare:@([self count])] == NSOrderedAscending;
    BOOL sizeOverLimit = [self.sizeLimit longLongValue] > 0 && [self.sizeLimit compare:_currentSize] == NSOrderedAscending;
    
    if (countOverLimit || sizeOverLimit) {
        while (countOverLimit || sizeOverLimit) {
            NSString *digest = [_blobsAccess lastObject];
            NUXDebug(@"Remove last blob (%@) - count:%d size:%d", digest, countOverLimit, sizeOverLimit);
            [_blobsAccess removeLastObject];
            [self removeBlobFileWithDigest:digest];
            
            countOverLimit = [self.countLimit intValue] > 0 && [self.countLimit compare:@([self count])] == NSOrderedAscending;
            sizeOverLimit = [self.sizeLimit longLongValue] > 0 && [self.sizeLimit compare:_currentSize] == NSOrderedAscending;
        }
    }
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
        [NUXException raise:@"Can't read dir content" format:@"Unable to read blob store files content. %@", error];
    }
    [blobs enumerateObjectsUsingBlock:^(NSString *blobPath, NSUInteger idx, BOOL *stop) {
        NUXDebug(@"Load file from existing folder: %@", blobPath);
        [self adjustFileSize:blobPath factor:1];
        [_blobsAccess addObject:[blobPath lastPathComponent]];
    }];
}

-(void)adjustFileSize:(NSString *)filePath factor:(int)factor {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    _currentSize = [NSNumber numberWithLongLong:[_currentSize longLongValue] + ([attributes fileSize] * factor)];
    NUXDebug(@"Blob store size: %lld", [_currentSize longLongValue]);
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
            [NUXException raise:@"Can't create blob store folder" format:@"Unable to create blob store folder at path: %@. %@", path, error];
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

-(void)removeBlobFileWithDigest:(NSString *)digest {
    [self adjustFileSize:[self blobPath:digest] factor:-1];
    [[NSFileManager defaultManager] removeItemAtPath:[self blobPath:digest] error:nil];
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
