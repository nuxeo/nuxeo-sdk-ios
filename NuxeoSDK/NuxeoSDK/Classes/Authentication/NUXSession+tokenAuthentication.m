//
//  NUXSession+tokenAuthentication.m
//  NuxeoSDK
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXSession+tokenAuthentication.h"


@implementation NUXSession (tokenAuthentication)

-(NUXRequest *)requestTokenAuthentication {
    NUXRequest *request = [[NUXRequest alloc] initWithSession:self];
    
    request.url = [NSURL URLWithString:self.url.absoluteString];
    [[request addURLSegment:@"authentication"] addURLSegment:@"token"];
    
    return request;
}

@end