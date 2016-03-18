//
//  NUXAuthenticator.h
//  NuxeoSDK
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

#import <ASIHTTPRequest.h>
#import "NUXConstants.h"

/**
 *  NUXAuthenticator is the base protocol to handle each Nuxeo Authentication Challenge.
 */
@protocol NUXAuthenticator <NSObject>
@required

/**
 *  This method should return a boolean to know if the current session needs to be authenticate or if everyhting is ok to make authenticated request to the server.
 *  There is no mecanism to automatically made the first challenge; you need to handle it on your own depending of what you need from the current session.
 *
 *  @return return TRUE in case the Authencator is able to call the server, FALSE if he needs to do something.
 */
-(BOOL)softAuthentication;

/**
 *  This method must add his own HTTP Header that need to be pass to the server to authenticate the current user.
 *
 *  @param request The request that need to be prepared with new headers or anyhting needed.
 */
-(void)prepareRequest:(ASIHTTPRequest *)request;
@end
