//
//  CalendarView.h
//  ios_calendar
//
//  Created by Maxim on 10/7/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CalendarViewType)
{
    CTDay,
    CTMonth,
    CTYear,
    
    CT_Count
};

@interface CalendarViewDayRect : NSObject 

@property int day;
@property CGRect frame;

@end

@interface CalendarViewMonthRect : NSObject

@property NSInteger month;
@property NSString *monthName;
@property CGRect frame;

@end

@interface CalendarViewYearRect : NSObject

@property NSInteger year;
@property CGRect frame;

@end

@protocol CalendarViewDelegate <NSObject>

@required
- (void)didChangeCalendarDate:(NSDate *)date;

@end

@interface CalendarView : UIView
{
    NSInteger type;
    
	NSInteger currentDay;
	NSInteger currentMonth;
	NSInteger currentYear;
	
	NSMutableArray *dayRects;
    NSMutableArray *monthRects;
    NSMutableArray *yearRects;
}

- (id)initWithPosition:(CGFloat)x y:(CGFloat)y;

@property (nonatomic, weak) id<CalendarViewDelegate> calendarDelegate;

@end