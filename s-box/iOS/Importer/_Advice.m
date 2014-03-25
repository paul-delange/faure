// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Advice.m instead.

#import "_Advice.h"

const struct AdviceAttributes AdviceAttributes = {
	.free = @"free",
	.targetGender = @"targetGender",
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
	
	if ([key isEqualToString:@"freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"targetGenderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"targetGender"];
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





@dynamic targetGender;



- (int16_t)targetGenderValue {
	NSNumber *result = [self targetGender];
	return [result shortValue];
}

- (void)setTargetGenderValue:(int16_t)value_ {
	[self setTargetGender:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTargetGenderValue {
	NSNumber *result = [self primitiveTargetGender];
	return [result shortValue];
}

- (void)setPrimitiveTargetGenderValue:(int16_t)value_ {
	[self setPrimitiveTargetGender:[NSNumber numberWithShort:value_]];
}





@dynamic text;






@dynamic title;






@dynamic theme;

	






@end
