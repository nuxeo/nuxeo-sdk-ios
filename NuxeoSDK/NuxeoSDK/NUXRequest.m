//
//  NUXRequest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXRequest.h"

@interface NUXRequest ()
@property NSURL *url;
@property NUXSession *session;
@property NSMutableDictionary *mutableHeaders;
@end

@implementation NUXRequest

-(id)initWithSession:(NUXSession *)session {
    self = [NUXRequest new];
    if (self) {
        self.session = session;
        self.method = @"GET";
        self.url = [session.url copy];
        
        _adaptors = [NSArray new];
        _categories = [NSArray new];
        _schemas = [NSArray new];
        self.mutableHeaders = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc {
    _adaptors = Nil;
    _categories = Nil;
    _schemas = Nil;
    self.url = Nil;
    self.method = Nil;
    self.repository = Nil;
}

-(NUXRequest *)addURLSegment:(NSString *)aSegment {
    self.url = [self.url URLByAppendingPathComponent:aSegment];
    return self;
}

-(NUXRequest *)addAdaptor:(NSString *)adaptor {
    [self addURLSegment:[NSString stringWithFormat:@"@%@", adaptor]];
    _adaptors = [_adaptors arrayByAddingObject:adaptor];
    return self;
}

-(NUXRequest *)addAdaptor:(NSString *)adaptor withValue:(NSString *)value {
    [self addAdaptor:adaptor];
    [self addURLSegment:value];
    return self;
}

-(NUXRequest *)addCategory:(NSString *)category {
    _categories = [_categories arrayByAddingObject:category];
    return self;
}

-(NUXRequest *)addCategories:(NSArray *)categories {
    _categories = [_categories arrayByAddingObjectsFromArray:categories];
    return self;
}

-(NUXRequest *)addSchema:(NSString *)schema {
    _schemas = [_schemas arrayByAddingObject:schema];
    return self;
}

-(NUXRequest *)addSchemas:(NSArray *)schemas {
    _schemas = [_schemas arrayByAddingObjectsFromArray:schemas];
    return self;
}


-(NUXRequest *)addHeaderWithKey:(NSString *)key value:(NSString *)value {
    [self.mutableHeaders setObject:value forKey:key];
    return self;
}

-(NSString *)absoluteURLString {
    return [self.url absoluteString];
}

-(NSDictionary *)headers {
    return [NSDictionary dictionaryWithDictionary:self.mutableHeaders];
}

@end
