//
//  NUXJSONSerializer.h
//  NuxeoSDK
//  Created by Matthias ROUBEROL on 2013-11-15.
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/),
 *     SmartNSoft (http://www.smartnsoft.com), and contributors.
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
 *     Matthias ROUBEROL
 */

#import <Foundation/Foundation.h>
#import "NUXEntity.h"

@interface NUXJSONSerializer : NSObject



/* Create a business object from JSON data. 
 If an error occurs during the parse, then the error parameter will be set and the result will be nil.
 The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE.
 The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 */
+ (id)entityWithData:(NSData *)data error:(NSError **)error;

/* Generate JSON data from a business object. 
 If the object will not produce valid JSON then an exception will be thrown. 
 If an error occurs, the error parameter will be set and the return value will be nil. 
 The resulting data is a encoded in UTF-8.
 */
+ (NSData *) dataWithEntity:(id)bObject error:(NSError **)error;


@end
