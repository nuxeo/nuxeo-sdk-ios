//
//  NUXSQLIteDatabase
//  NuxeoSDK
//  Created by Arnaud Kervern on 2013-11-26.
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

#import "NUXSQLiteDatabase.h"

@implementation NUXSQLiteDatabase {
    NSString *_name;
    NSInteger _ret;
}

-(id)initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

-(void)deleteDatabase {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager isWritableFileAtPath:[self databasePath]]) {
        [manager removeItemAtPath:[self databasePath] error:nil];
        NUXDebug(@"Database dropped.");
    }
}

+ (NUXSQLiteDatabase *)shared {
    static dispatch_once_t pred = 0;
    static NUXSQLiteDatabase *__strong _shared = nil;
    
    dispatch_once(&pred, ^{
        _shared = [[NUXSQLiteDatabase alloc] initWithName:@"sharedOne"];
    });
    
    return _shared;
}

-(void)createTableIfNotExists:(NSString *)tableName withField:(NSString *)fields {
    [self executeQuery:[NSString stringWithFormat:@"create table if not exists '%@' (%@);", tableName, fields]];
}

-(void)dropTableIfExists:(NSString *)tableName {
    [self executeQuery:[NSString stringWithFormat:@"drop table if exists '%@';", tableName]];
}

-(BOOL)executeQuery:(NSString *)query {
    sqlite3 *db;
    NSString *dbPath = [self databasePath];
    
    _ret = sqlite3_open_v2([dbPath UTF8String], &db, SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
	if (_ret == SQLITE_OK)
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
			_ret = sqlite3_step(statement);
			
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
    
    NUXDebug(@"Query: '%@', Result: %@", query, [self sqlInformatiomFromCode:_ret]);
	return (_ret == SQLITE_OK || _ret == SQLITE_DONE || _ret == SQLITE_ROW);
}

- (NSArray*)arrayOfObjectsFromQuery:(NSString*)query block:(id (^)(sqlite3_stmt *))aBlock
{
    NSMutableArray* aArray = [NSMutableArray new];
	NSString* aDBpath = [self databasePath];
	
	// Holds the database connection
	sqlite3* aDatabase;
    
	if (sqlite3_open([aDBpath UTF8String], &aDatabase) == SQLITE_OK)
	{
		sqlite3_stmt *statement;
		
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
		_ret = sqlite3_prepare_v2(aDatabase, [query cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL);
		if (_ret == SQLITE_OK)
		{
			NSInteger aNbFetchedObject = 0;
			// We "step" through the results - once for each row.
            int step;
			while ((step = sqlite3_step(statement)) == SQLITE_ROW)
			{
                [aArray addObject:aBlock(statement)];
				
				// Increase number of fetched objects
				++aNbFetchedObject;
			}
            NUXDebug(@"pouet: %@", [self sqlInformatiomFromCode:step]);
		}
		else {
            // handle error
        }
		
		sqlite3_finalize(statement);
		
	}
	
	// Safely close database even if the connection was not done.
	sqlite3_close(aDatabase);
	
    NUXDebug(@"Query: '%@', Result: %@", query, [self sqlInformatiomFromCode:_ret]);
	return aArray;
	
}

-(NSInteger)lastReturnCode {
    return _ret;
}

- (NSString*) sqlInformatiomFromCode:(NSInteger)iErrorCode
{
	NSString* aErrorType = @"";
	switch (iErrorCode)
	{
		case SQLITE_ERROR:
			aErrorType = @" SQLITE_ERROR         (SQL error or missing database)";
			break;
			
		case SQLITE_INTERNAL:
			aErrorType = @" SQLITE_INTERNAL      (Internal logic error in SQLite)";
			break;
			
		case SQLITE_PERM:
			aErrorType = @" SQLITE_PERM          (Access permission denied)";
			break;
			
		case SQLITE_ABORT:
			aErrorType = @" SQLITE_ABORT         (Callback routine requested an abort)";
			break;
			
		case SQLITE_BUSY:
			aErrorType = @" SQLITE_BUSY          (The database file is locked)";
			break;
			
		case SQLITE_LOCKED:
			aErrorType = @" SQLITE_LOCKED        (A table in the database is locked)";
			break;
			
		case SQLITE_NOMEM:
			aErrorType = @" SQLITE_NOMEM         (A malloc() failed)";
			break;
			
		case SQLITE_READONLY:
			aErrorType = @" SQLITE_READONLY      (Attempt to write a readonly database)";
			break;
			
		case SQLITE_INTERRUPT:
			aErrorType = @" SQLITE_INTERRUPT     (Operation terminated by sqlite_interrupt())";
			break;
			
		case SQLITE_CORRUPT:
			aErrorType = @" SQLITE_CORRUPT       (The database disk image is malformed)";
			break;
			
		case SQLITE_NOTFOUND:
			aErrorType = @" SQLITE_NOTFOUND      (NOT USED. Table or record not found)";
			break;
			
		case SQLITE_FULL:
			aErrorType = @" SQLITE_FULL          (Insertion failed because database is full)";
			break;
			
		case SQLITE_CANTOPEN:
			aErrorType = @" SQLITE_CANTOPEN      (Unable to open the database file)";
			break;
			
		case SQLITE_PROTOCOL:
			aErrorType = @" SQLITE_PROTOCOL      (Database lock protocol error)";
			break;
			
		case SQLITE_EMPTY:
			aErrorType = @" SQLITE_EMPTY         (Database is empty)";
			break;
			
		case SQLITE_SCHEMA:
			aErrorType = @" SQLITE_SCHEMA        (The database schema changed)";
			break;
			
		case SQLITE_TOOBIG:
			aErrorType = @" SQLITE_TOOBIG        (String or BLOB exceeds size limit)";
			break;
			
		case SQLITE_CONSTRAINT:
			aErrorType = @" SQLITE_CONSTRAINT    (Abort due to constraint violation)";
			break;
			
		case SQLITE_MISMATCH:
			aErrorType = @" SQLITE_MISMATCH      (Data type mismatch)";
			break;
			
		case SQLITE_MISUSE:
			aErrorType = @" SQLITE_MISUSE        (Library used incorrectly)";
			break;
			
		case SQLITE_NOLFS:
			aErrorType = @" SQLITE_NOLFS         (Uses OS features not supported on host)";
			break;
			
		case SQLITE_AUTH:
			aErrorType = @" SQLITE_AUTH          (Authorization denied)";
			break;
			
		case SQLITE_FORMAT:
			aErrorType = @" SQLITE_FORMAT        (Auxiliary database format error)";
			break;
			
		case SQLITE_RANGE:
			aErrorType = @" SQLITE_RANGE         (2nd parameter to sqlite_bind out of range)";
			break;
			
		case SQLITE_NOTADB:
			aErrorType = @" SQLITE_NOTADB        (File opened that is not a database file)";
			break;
			
		case SQLITE_ROW:
			aErrorType = @" SQLITE_ROW           (sqlite_step() has another row ready)";
			break;
			
		case SQLITE_DONE:
			aErrorType = @" SQLITE_DONE          (sqlite_step() has finished executing)";
			break;
            
        case SQLITE_OK:
			aErrorType = @" SQLITE_OK            (Successful result)";
			break;
            
		default:
			aErrorType = @" unknown";
			break;
	}
	
	return aErrorType;
}

#pragma mark -
#pragma mark Helper methods

+(NSString *)sqlitize:(NSArray *)values {
    NSMutableString *ret = [NSMutableString new];
    [values enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            [ret appendString:@", "];
        }
        
        if (![value isKindOfClass:[NSNumber class]]) {
            [ret appendString:[NSString stringWithFormat:@"\"%@\"", value]];
        } else {
            [ret appendString:[NSString stringWithFormat:@"%@", value]];
        }
    }];
    
    return ret;
}

#pragma mark -
#pragma mark Internal

-(NSString *)databasePath {
    // Find a file in user's cache directory based on database name
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[directories objectAtIndex:0] stringByAppendingPathComponent:_name];
}

@end