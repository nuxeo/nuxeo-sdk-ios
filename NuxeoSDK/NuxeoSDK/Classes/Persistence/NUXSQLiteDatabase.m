//
// Created by Arnaud Kervern on 26/11/13.
// Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXSQLiteDatabase.h"

@implementation NUXSQLiteDatabase {
    NSString *_name;
}

-(id)initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

-(BOOL)executeQuery:(NSString *)query {
    sqlite3 *db;
    NSString *dbPath = [self databasePath];
    
    NSInteger ret = sqlite3_open_v2([dbPath UTF8String], &db, SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
	if (ret == SQLITE_OK)
	{
        sqlite3_stmt *statement = NULL;
		const char* utf8query = [query cStringUsingEncoding:NSUTF8StringEncoding];
		const char* pzTail = NULL;
		while (utf8query != NULL && strlen(utf8query) > 0)
		{
			// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
			// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
			BOOL preparation = sqlite3_prepare_v2(db, utf8query, -1, &statement, &pzTail);
			
			// Step through the statement even if failed to retrieve the error code
			ret = sqlite3_step(statement);
			
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			
			if (preparation == SQLITE_OK)
			{
				// If pzTail is not NULL then *pzTail is made to point to the first byte past the end of the first SQL statement
				// in zSql. These routines only compile the first statement in zSql, so *pzTail is left pointing to what remains uncompiled.
				utf8query = pzTail;
			}
			// Error code on preparation ? stop right there
			else
            {
				utf8query = NULL;
            }
		}
	}
	
	// Safely close database even if the connection was not done.
	sqlite3_close(db);
	
	return (ret == SQLITE_OK || ret == SQLITE_DONE || ret == SQLITE_ROW);
}

#pragma mark -
#pragma mark Internal

-(NSString *)databasePath {
    // Find a file in user's cache directory based on database name
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[directories objectAtIndex:0] stringByAppendingPathComponent:_name];
}

@end