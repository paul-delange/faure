// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Question.m instead.

#import "_Question.h"

const struct QuestionAttributes QuestionAttributes = {
	.answer = @"answer",
	.formats = @"formats",
	.identifier = @"identifier",
	.maxValue = @"maxValue",
	.minValue = @"minValue",
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
	if ([key isEqualToString:@"formatsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"formats"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"minValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minValue"];
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





@dynamic formats;



- (BOOL)formatsValue {
	NSNumber *result = [self formats];
	return [result boolValue];
}

- (void)setFormatsValue:(BOOL)value_ {
	[self setFormats:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFormatsValue {
	NSNumber *result = [self primitiveFormats];
	return [result boolValue];
}

- (void)setPrimitiveFormatsValue:(BOOL)value_ {
	[self setPrimitiveFormats:[NSNumber numberWithBool:value_]];
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





@dynamic maxValue;



- (int64_t)maxValueValue {
	NSNumber *result = [self maxValue];
	return [result longLongValue];
}

- (void)setMaxValueValue:(int64_t)value_ {
	[self setMaxValue:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMaxValueValue {
	NSNumber *result = [self primitiveMaxValue];
	return [result longLongValue];
}

- (void)setPrimitiveMaxValueValue:(int64_t)value_ {
	[self setPrimitiveMaxValue:[NSNumber numberWithLongLong:value_]];
}





@dynamic minValue;



- (int64_t)minValueValue {
	NSNumber *result = [self minValue];
	return [result longLongValue];
}

- (void)setMinValueValue:(int64_t)value_ {
	[self setMinValue:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMinValueValue {
	NSNumber *result = [self primitiveMinValue];
	return [result longLongValue];
}

- (void)setPrimitiveMinValueValue:(int64_t)value_ {
	[self setPrimitiveMinValue:[NSNumber numberWithLongLong:value_]];
}





@dynamic text;






@dynamic unit;






@dynamic level;

	






@end
