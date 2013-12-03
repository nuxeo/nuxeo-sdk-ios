//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUXConstants.h"
#import <sqlite3.h>

@interface NUXSQLiteDatabase : NSObject

-(id)initWithName:(NSString *)name;

-(void)createTableIfNotExists:(NSString *)tableName withField:(NSString *)fields;

-(void)deleteDatabase;

-(BOOL)executeQuery:(NSString *)query;

-(NSString*)sqlInformatiomFromCode:(NSInteger)iErrorCode;

-(NSInteger)lastReturnCode;

+(NUXSQLiteDatabase *)shared;

@end