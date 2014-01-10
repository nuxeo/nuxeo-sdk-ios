//
//  NUXBlobStore.m
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-12-04.
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

#import "NUXBlobStore.h"
#import "NUXConstants.h"

#define kStoreFolderName @"org.nuxeo.cache.blob"
#define kErrorDomain @"org.nuxeo.error.blobstore"

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
        
        self.filenameProperty = @"name";
        self.digestProperty = @"digest";
        
        [self deleteOld];
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
    _filenameProperty = Nil;
    _digestProperty = Nil;
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
    NSString *blobPath = [self blobPathWithDigest:digest];
    if (blobPath != nil) {
        [self updateAccessForDigest:digest file:blobPath];
    }
    return blobPath;
}

-(BOOL)hasBlob:(NSString *)digest
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self digestDirectoryPath:digest]];
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


-(NSString *)saveBlobFromPath:(NSString *)path withDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath error:(NSError **)error
{
    return [self saveBlobFromPath:path withDigest:[self digestFromDocument:document metadataXPath:xpath] filename:[self filenameFromDocument:document metadataXPath:xpath] error:error];
}

#pragma mark -
#pragma mark Internal methods

-(NSString *)saveBlobFromPath:(NSString *)path withDigest:(NSString *)digest filename:(NSString *)filename error:(NSError **)error
{
    if (digest == nil || filename == nil) {
        *error = [NSError errorWithDomain:kErrorDomain code:2 userInfo:nil];
        return NULL;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:path]) {
        *error = [NSError errorWithDomain:kErrorDomain code:1 userInfo:nil];
        return NULL;
    }
    
    [self removeBlob:digest];
    NSString *digestDirectory = [self digestDirectoryPath:digest];
    if (![fileManager createDirectoryAtPath:digestDirectory withIntermediateDirectories:YES attributes:nil error:error]) {
        return NULL;
    }
    
    NSString *blobPath = [digestDirectory stringByAppendingPathComponent:filename];
    BOOL ret = [fileManager copyItemAtPath:path toPath:blobPath error:error];
    
    if (!ret) {
        return NULL;
    }
    
    [_blobsAccess insertObject:digest atIndex:0];
    [self adjustFileSize:blobPath factor:1];
    [self cleanStore];
    return blobPath;
}

-(void)cleanStore {
    BOOL countOverLimit = [self.countLimit intValue] > 0 && [self.countLimit compare:@([self count])] == NSOrderedAscending;
    BOOL sizeOverLimit = [self.sizeLimit longLongValue] > 0 && [self.sizeLimit compare:_currentSize] == NSOrderedAscending;
    
    NUXDebug(@"count: %ld/%@, size: %lld/%@", [self count], self.countLimit, [_currentSize longLongValue], self.sizeLimit);
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

-(void)updateAccessForDigest:(NSString *)digest file:(NSString *)filePath {
    [_blobsAccess removeObject:digest];
    [_blobsAccess insertObject:digest atIndex:0];
    
    // Update manually NSURLContentModificationDateKey while accessing a blob to ensure to delete oldest file first
    [[NSURL fileURLWithPath:filePath] setResourceValue:[NSDate new] forKey:NSURLContentModificationDateKey error:nil];
}

-(void)deleteOld {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *blobs = [fileManager contentsOfDirectoryAtPath:[self blobStorePath] error:&error];
    [blobs enumerateObjectsUsingBlock:^(NSString *blob, NSUInteger idx, BOOL *stop) {
        NSString *blobPath = [[self blobStorePath] stringByAppendingPathComponent:blob];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:blobPath isDirectory:&isDirectory] && !isDirectory) {
            [fileManager removeItemAtPath:blobPath error:nil];
        }
    }];
}

-(void)recomputeBlobAccess {
    [_blobsAccess removeAllObjects];
    NSError *error;
    NSArray *blobs = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self blobStorePath] error:&error];
    if (!blobs) {
        [NUXException raise:@"Can't read dir content" format:@"Unable to read blob store files content. %@", error];
    }
    [blobs enumerateObjectsUsingBlock:^(NSString *blob, NSUInteger idx, BOOL *stop) {
        NSString *blobPath = [[self blobStorePath] stringByAppendingPathComponent:blob];
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:blobPath isDirectory:&isDirectory] && isDirectory) {
            // Ignore folder
            return;
        }
        
        [self adjustFileSize:blobPath factor:1];
        blob = [blob stringByDeletingLastPathComponent];
        [_blobsAccess addObject:[blob lastPathComponent]];
    }];
    
    // After testing; NSURLContentAccess is never updated. To ensure to delete oldest file first,
    // we sort using modificationDate (updated while accessing the blob)
    NSMutableDictionary *blobDates = [NSMutableDictionary new];
    [_blobsAccess sortUsingComparator:^NSComparisonResult(NSString *blob1, NSString *blob2) {
        NSDate *blobDate1 = [blobDates objectForKey:blob1];
        if (blobDate1 == nil) {
            blobDate1 = [self contentModificationDateForDigest:blob1];
            [blobDates setObject:blobDate1 forKey:blob1];
        }
        
        NSDate *blobDate2 = [blobDates objectForKey:blob2];
        if (blobDate2 == nil) {
            blobDate2 = [self contentModificationDateForDigest:blob2];
            [blobDates setObject:blobDate2 forKey:blob2];
        }
        
        return [blobDate2 compare:blobDate1];
    }];
    
    NUXDebug(@"Initiate blob store: %lld", [_currentSize longLongValue]);
}

-(NSDate *)contentModificationDateForDigest:(NSString *)digest {
    NSString *blobPath = [self blobPathWithDigest:digest];
    NSDate *blobDate;
    [[NSURL fileURLWithPath:blobPath] getResourceValue:&blobDate forKey:NSURLContentModificationDateKey error:nil];
    return blobDate;
}

-(void)adjustFileSize:(NSString *)filePath factor:(int)factor {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    _currentSize = [NSNumber numberWithLongLong:[_currentSize longLongValue] + ([attributes fileSize] * factor)];
    NUXDebug(@"CurrentSize: %@", _currentSize);
}

-(NSString *)digestDirectoryPath:(NSString *)digest {
    return [[self blobStorePath] stringByAppendingPathComponent:digest];
}

-(NSString *)blobPathWithDigest:(NSString *)digest {
    NSString *digestDir = [self digestDirectoryPath:digest];
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:digestDir error:nil];
    
    return [content count] > 0 ? [digestDir stringByAppendingPathComponent:[content objectAtIndex:0]] : nil;
}

-(NSString *)blobPathWithDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath {
    NSString *digest = [self digestFromDocument:document metadataXPath:xpath];
    NSString *filename = [self filenameFromDocument:document metadataXPath:xpath];
    
    return [[self blobPathWithDigest:digest] stringByAppendingPathComponent:filename];
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

-(NSString *)filenameFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath {
    NSDictionary *property = [document.properties valueForKey:xpath];
    if (!property) {
        return NULL;
    }
    return [property valueForKey:self.filenameProperty];
}

-(NSString *)digestFromDocument:(NUXDocument *)document metadataXPath:(NSString *)xpath {
    NSDictionary *property = [document.properties valueForKey:xpath];
    if (!property) {
        return NULL;
    }
    return [property valueForKey:self.digestProperty];
}

-(void)removeBlobFileWithDigest:(NSString *)digest {
    if ([self hasBlob:digest]) {
        [self adjustFileSize:[self blobPathWithDigest:digest] factor:-1];
        [[NSFileManager defaultManager] removeItemAtPath:[self digestDirectoryPath:digest] error:nil];
    }
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