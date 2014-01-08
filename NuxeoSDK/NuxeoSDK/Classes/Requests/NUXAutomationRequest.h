//
//  NUXAutomationRequest.h
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-20.
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
#import "NUXRequest.h"

@interface NUXAutomationRequest : NUXRequest

- (void)addContextValue:(id)value forKey:(NSString *)key;

- (void)setInputFile:(NSString *)filePath;
- (void)setInput:(id)input;

- (NSDictionary *)context;
- (id)fileInput;
- (id)input;

@end