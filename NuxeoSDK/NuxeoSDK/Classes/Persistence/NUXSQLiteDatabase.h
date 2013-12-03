//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NUXSQLiteDatabase : NSObject

-(id)initWithName:(NSString *)name;

-(BOOL)executeQuery:(NSString *)query;

-(NSString*)sqlInformatiomFromCode:(NSInteger)iErrorCode;

-(NSInteger)lastReturnCode;

@end