// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Level.m instead.

#import "_Level.h"

const struct LevelAttributes LevelAttributes = {
	.identifier = @"identifier",
};

const struct LevelRelationships LevelRelationships = {
	.questions = @"questions",
};

const struct LevelFetchedProperties LevelFetchedProperties = {
};

@implementation LevelID
@end

@implementation _Level

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Level" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Level";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Level" inManagedObjectContext:moc_];
}

- (LevelID*)objectID {
	return (LevelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic identifier;



- (int16_t)identifierValue {
	NSNumber *result = [self identifier];
	return [result shortValue];
}

- (void)setIdentifierValue:(int16_t)value_ {
	[self setIdentifier:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIdentifierValue {
	NSNumber *result = [self primitiveIdentifier];
	return [result shortValue];
}

- (void)setPrimitiveIdentifierValue:(int16_t)value_ {
	[self setPrimitiveIdentifier:[NSNumber numberWithShort:value_]];
}





@dynamic questions;

	
- (NSMutableOrderedSet*)questionsSet {
	[self willAccessValueForKey:@"questions"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"questions"];
  
	[self didAccessValueForKey:@"questions"];
	return result;
}
	






@end
