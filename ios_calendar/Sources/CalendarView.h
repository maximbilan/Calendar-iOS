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
    CalendarViewTypeDay,
    CalendarViewTypeMonth,
    CalendarViewTypeYear,
    
    CalendarViewTypeCount
};

typedef NS_ENUM(NSInteger, CalendarMode)
{
    CalendarModeDefault,
    CalendarModeMonthsAndYears,
    CalendarModeYears
};

typedef NS_ENUM(NSInteger, CalendarEvent)
{
    CalendarEventNone,
    CalendarEventTap,
    CalendarEventDoubleTap,
    CalendarEventSwipeLeft,
    CalendarEventSwipeRight,
    CalendarEventPinchIn,
    CalendarEventPinchOut
};

@interface CalendarViewRect : NSObject

@property NSInteger value;
@property NSString  *str;
@property CGRect    frame;

@end

@protocol CalendarViewDelegate <NSObject>

@required
- (void)didChangeCalendarDate:(NSDate *)date;

@optional
- (void)didChangeCalendarDate:(NSDate *)date withType:(NSInteger)type withEvent:(NSInteger)event;
- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type;

@end

@interface CalendarView : UIView

- (instancetype)initWithPosition:(CGFloat)x y:(CGFloat)y;
- (void)setMode:(NSInteger)m;
- (void)refresh;
- (void)advanceCalendarContents;
- (void)rewindCalendarContents;
// Weekday indices start with Sunday = 0
// to match the indices provided by the NSDateFormatter method shortWeekdaySymbols
- (void)setPreferredWeekStartIndex:(NSInteger)index;

@property (nonatomic, weak) id<CalendarViewDelegate> calendarDelegate;
@property (nonatomic, strong) NSDate *currentDate;

// Colors
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *fontHeaderColor;
@property (nonatomic, strong) UIColor *fontSelectedColor;
@property (nonatomic, strong) UIColor *selectionColor;
@property (nonatomic, strong) UIColor *todayColor;
@property (nonatomic, strong) UIColor *bgColor;

// Cell Size
@property (nonatomic) CGFloat dayCellWidth;
@property (nonatomic) CGFloat dayCellHeight;
@property (nonatomic) CGFloat monthCellWidth;
@property (nonatomic) CGFloat monthCellHeight;
@property (nonatomic) CGFloat yearCellWidth;
@property (nonatomic) CGFloat yearCellHeight;

// Font Size
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic) CGFloat dayFontSize;
@property (nonatomic) CGFloat headerFontSize;

// Display Options
@property (nonatomic, assign) BOOL shouldMarkSelectedDate;
@property (nonatomic, assign) BOOL shouldMarkToday;
@property (nonatomic, assign) BOOL shouldShowHeaders;

@end
