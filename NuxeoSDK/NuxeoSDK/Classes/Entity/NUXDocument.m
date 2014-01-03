//
//  NUXDocument.m
//  NuxeoSDK
//
//  Created by Matthias ROUBEROL on 18/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXDocument.h"

@implementation NUXDocument

-(id)init
{
    self = [super initWithEntityType:@"document"];
    if (self) {
        // Initialize
    }
    return self;
}

- (void)dealloc
{
    _repository = nil;
    _uid = nil;
    _name = nil;
    _path = nil;
    _type = nil;
    _state = nil;
    _versionLabel = nil;
    _title = nil;
    _changeToken = nil;
    _lastModified = nil;
    
    _properties = nil;
    _facets = nil;
    _context = nil;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ path=%@ type=%@", [self class], _uid, _path, _type];
}

/*	isEqual
	This implementaion of isEqual only compares UUID and changeToken.
	Very useful when querying an NUXDocument in an NSArray of NUXDocument, like in:
		NUXDocuments *docs = ...
		. . .
		NUXDocument *oneDoc = ...
		. . .
		NSUInteger pos = [docs.entries indexOfObject:oneDoc];
		. . .

	*BUT*, this means the comparison is not strict. For example, you could
	have 2 different NUXDocument referencing the same document, but the user
	modified some values (dc:title, ...) in one of them => isEqual would still
	return YES.
*/
- (BOOL) isEqual:(id)object
{
	if(self == object){
		return YES;
	}
	
	if(object && [object isKindOfClass:[NUXDocument class]]) {
		return [self.uid isEqualToString:[(NUXDocument *)object uid]]
		&& [self.changeToken isEqualToString:[(NUXDocument *)object changeToken]];
	}
	
	return NO;
}



#pragma mark -
#pragma mark NUXEntityPersistable protocol

-(NSString *)entityId {
    return self.uid;
}

@end
