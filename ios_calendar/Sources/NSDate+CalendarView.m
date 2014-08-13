//
//  NSDate+CalendarView.m
//  ios_calendar
//
//  Created by Maxim on 10/9/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import "NSDate+CalendarView.h"

@implementation NSDate (CalendarView)

- (NSUInteger)getLastDayOfMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	NSRange daysRange = [currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
	
	return daysRange.length;
}

- (NSInteger)getWeekdayOfFirstDayOfMonth
{
	NSTimeZone *timeZone = [NSTimeZone localTimeZone];

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timeZone];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	[components setDay:1];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setTimeZone:timeZone];
	
	NSDateComponents *weekdayComponents = [calendar components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:[calendar dateFromComponents:components]];
	NSInteger weekday = [weekdayComponents weekday];
	
	return (weekday == 1) ? 7 : weekday - 1;
}

@end
