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
    return [self getLastDayOfMonthForCalendar:[NSCalendar currentCalendar]];
}

- (NSUInteger)getLastDayOfMonthForCalendarIdentifier:(NSCalendarIdentifier) calendarIdentifier
{
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIdentifier];
    NSRange daysRange = [currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return daysRange.length;
}

- (NSUInteger)getLastDayOfMonthForCalendar:(NSCalendar *) calendar
{
    NSCalendar *currentCalendar = calendar;
    NSRange daysRange = [currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return daysRange.length;
}

- (NSInteger)getWeekdayOfFirstDayOfMonth
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [self getWeekdayOfFirstDayOfMonthForCalendar:calendar];
}

- (NSInteger)getWeekdayOfFirstDayOfMonthForCalendarIdentifier:(NSCalendarIdentifier) calendarIdentifier
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIdentifier];
    return [self getWeekdayOfFirstDayOfMonthForCalendar:calendar];
}

- (NSInteger)getWeekdayOfFirstDayOfMonthForCalendar:(NSCalendar *) calendar
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [calendar setTimeZone:timeZone];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:self];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setTimeZone:timeZone];
    
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday)
                                                      fromDate:[calendar dateFromComponents:components]];
    NSInteger weekday = [weekdayComponents weekday];
    if (calendar.calendarIdentifier == NSCalendarIdentifierPersian) {
        return (weekday == 7) ? 0 : weekday + 1;
    }
    return (weekday == 1) ? 7 : weekday - 1;
}

@end
