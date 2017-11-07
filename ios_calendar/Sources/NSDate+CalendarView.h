//
//  NSDate+CalendarView.h
//  ios_calendar
//
//  Created by Maxim on 10/9/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CalendarView)

@property (NS_NONATOMIC_IOSONLY, getter=getLastDayOfMonth, readonly) NSUInteger lastDayOfMonth;
@property (NS_NONATOMIC_IOSONLY, getter=getWeekdayOfFirstDayOfMonth, readonly) NSInteger weekdayOfFirstDayOfMonth;

- (NSUInteger)getLastDayOfMonthForCalendarIdentifier:(NSCalendarIdentifier)
calendarIdentifier;
- (NSUInteger)getLastDayOfMonthForCalendar:(NSCalendar *) calendar;
- (NSInteger)getWeekdayOfFirstDayOfMonthForCalendarIdentifier:(NSCalendarIdentifier) calendarIdentifier;
- (NSInteger)getWeekdayOfFirstDayOfMonthForCalendar:(NSCalendar *) calendar;

@end
