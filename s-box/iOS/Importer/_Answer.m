// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Answer.m instead.

#import "_Answer.h"

const struct AnswerAttributes AnswerAttributes = {
	.isCorrect = @"isCorrect",
	.text = @"text",
};

const struct AnswerRelationships AnswerRelationships = {
	.question = @"question",
};

const struct AnswerFetchedProperties AnswerFetchedProperties = {
};

@implementation AnswerID
@end

@implementation _Answer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Answer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Answer" inManagedObjectContext:moc_];
}

- (AnswerID*)objectID {
	return (AnswerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isCorrectValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isCorrect"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isCorrect;



- (BOOL)isCorrectValue {
	NSNumber *result = [self isCorrect];
	return [result boolValue];
}

- (void)setIsCorrectValue:(BOOL)value_ {
	[self setIsCorrect:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsCorrectValue {
	NSNumber *result = [self primitiveIsCorrect];
	return [result boolValue];
}

- (void)setPrimitiveIsCorrectValue:(BOOL)value_ {
	[self setPrimitiveIsCorrect:[NSNumber numberWithBool:value_]];
}





@dynamic text;






@dynamic question;

	






@end
