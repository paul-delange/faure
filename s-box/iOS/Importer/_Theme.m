// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Theme.m instead.

#import "_Theme.h"

const struct ThemeAttributes ThemeAttributes = {
	.name = @"name",
};

const struct ThemeRelationships ThemeRelationships = {
	.advices = @"advices",
};

const struct ThemeFetchedProperties ThemeFetchedProperties = {
};

@implementation ThemeID
@end

@implementation _Theme

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Theme";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Theme" inManagedObjectContext:moc_];
}

- (ThemeID*)objectID {
	return (ThemeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic advices;

	
- (NSMutableSet*)advicesSet {
	[self willAccessValueForKey:@"advices"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"advices"];
  
	[self didAccessValueForKey:@"advices"];
	return result;
}
	






@end
