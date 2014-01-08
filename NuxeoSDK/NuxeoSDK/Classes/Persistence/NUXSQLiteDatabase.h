//
//  NUXSQLIteDatabase
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-26.
//
// Highly inspired from SnSSqliteAccessor originally written by Smart&Soft
// https://github.com/smartnsoft/ios4me/blob/master/SnSFramework/SnSFramework/ios4me/Classes/Accessors/SnSSQLiteAccessor.h
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
#import "NUXConstants.h"
#import <sqlite3.h>

@interface NUXSQLiteDatabase : NSObject

-(id)initWithName:(NSString *)name;

-(void)dropTableIfExists:(NSString *)tableName;

-(void)createTableIfNotExists:(NSString *)tableName withField:(NSString *)fields;

-(void)deleteDatabase;

-(BOOL)executeQuery:(NSString *)query;

-(NSArray*)arrayOfObjectsFromQuery:(NSString*)query block:(id (^)(sqlite3_stmt *))aBlock;

-(NSString*)sqlInformatiomFromCode:(NSInteger)iErrorCode;

-(NSInteger)lastReturnCode;

+(NUXSQLiteDatabase *)shared;

@end