//
// Highly inspired from SnSSqliteAccessor originally written by Smart&Soft
// https://github.com/smartnsoft/ios4me/blob/master/SnSFramework/SnSFramework/ios4me/Classes/Accessors/SnSSQLiteAccessor.h
//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

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