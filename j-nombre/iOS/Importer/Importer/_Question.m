// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Question.m instead.

#import "_Question.h"

const struct QuestionAttributes QuestionAttributes = {
	.answer = @"answer",
	.text = @"text",
	.unit = @"unit",
};

const struct QuestionRelationships QuestionRelationships = {
	.level = @"level",
};

const struct QuestionFetchedProperties QuestionFetchedProperties = {
};

@implementation QuestionID
@end

@implementation _Question

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Question";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Question" inManagedObjectContext:moc_];
}

- (QuestionID*)objectID {
	return (QuestionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"answerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"answer"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic answer;



- (int64_t)answerValue {
	NSNumber *result = [self answer];
	return [result longLongValue];
}

- (void)setAnswerValue:(int64_t)value_ {
	[self setAnswer:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveAnswerValue {
	NSNumber *result = [self primitiveAnswer];
	return [result longLongValue];
}

- (void)setPrimitiveAnswerValue:(int64_t)value_ {
	[self setPrimitiveAnswer:[NSNumber numberWithLongLong:value_]];
}





@dynamic text;






@dynamic unit;






@dynamic level;

	






@end
