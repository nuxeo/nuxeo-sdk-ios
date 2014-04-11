//
//  NUXSession+tokenAuthentication.h
//  NuxeoSDK
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Nuxeo. All rights reserved.
//

#import "NUXSession.h"

#pragma mark - NUXSession protocol to add token generation request

@interface NUXSession (tokenAuthentication)

- (NUXRequest *)requestTokenAuthentication;

@end