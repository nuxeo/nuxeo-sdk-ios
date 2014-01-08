//
//  NUXException.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-16-12.
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

#import <Foundation/Foundation.h>

@interface NUXException : NSException

+ (void)raise:(NSString *)name format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end
