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

typedef NS_ENUM(NSInteger, CalendarMode)
{
    CM_Default,
    CM_MonthsAndYears,
    CM_Years
};

@interface CalendarViewRect : NSObject

@property NSInteger value;
@property NSString  *str;
@property CGRect    frame;

@end

@protocol CalendarViewDelegate <NSObject>

@required
- (void)didChangeCalendarDate:(NSDate *)date;

@end

@interface CalendarView : UIView
{
    NSInteger type;
    NSInteger minType;
    NSInteger mode;
    
	NSInteger currentDay;
	NSInteger currentMonth;
	NSInteger currentYear;
	
	NSMutableArray *dayRects;
    NSMutableArray *monthRects;
    NSMutableArray *yearRects;
    
    CGRect yearTitleRect;
    CGRect monthTitleRect;
}

- (id)initWithPosition:(CGFloat)x y:(CGFloat)y;
- (void)setMode:(NSInteger)m;

@property (nonatomic, weak) id<CalendarViewDelegate> calendarDelegate;

@end