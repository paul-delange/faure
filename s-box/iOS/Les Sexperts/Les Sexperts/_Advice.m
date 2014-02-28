// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Advice.m instead.

#import "_Advice.h"

const struct AdviceAttributes AdviceAttributes = {
	.text = @"text",
	.title = @"title",
};

const struct AdviceRelationships AdviceRelationships = {
	.theme = @"theme",
};

const struct AdviceFetchedProperties AdviceFetchedProperties = {
};

@implementation AdviceID
@end

@implementation _Advice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Advice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Advice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Advice" inManagedObjectContext:moc_];
}

- (AdviceID*)objectID {
	return (AdviceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic text;






@dynamic title;






@dynamic theme;

	






@end
