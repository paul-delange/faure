// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Joke.m instead.

#import "_Joke.h"

const struct JokeAttributes JokeAttributes = {
	.free = @"free",
	.text = @"text",
};

const struct JokeRelationships JokeRelationships = {
};

const struct JokeFetchedProperties JokeFetchedProperties = {
};

@implementation JokeID
@end

@implementation _Joke

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Joke" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Joke";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Joke" inManagedObjectContext:moc_];
}

- (JokeID*)objectID {
	return (JokeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic free;



- (BOOL)freeValue {
	NSNumber *result = [self free];
	return [result boolValue];
}

- (void)setFreeValue:(BOOL)value_ {
	[self setFree:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFreeValue {
	NSNumber *result = [self primitiveFree];
	return [result boolValue];
}

- (void)setPrimitiveFreeValue:(BOOL)value_ {
	[self setPrimitiveFree:[NSNumber numberWithBool:value_]];
}





@dynamic text;











@end
