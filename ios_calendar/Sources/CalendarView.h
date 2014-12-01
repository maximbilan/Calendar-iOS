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

typedef NS_ENUM(NSInteger, CalendarEvent)
{
    CE_None,
    CE_Tap,
    CE_DoubleTap,
    CE_SwipeLeft,
    CE_SwipeRight,
    CE_PinchIn,
    CE_PinchOut
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
{
    NSInteger type;
    NSInteger minType;
    NSInteger mode;
    NSInteger event;
    
	NSInteger currentDay;
	NSInteger currentMonth;
	NSInteger currentYear;
	
	NSMutableArray *dayRects;
    NSMutableArray *monthRects;
    NSMutableArray *yearRects;
    
    CGRect yearTitleRect;
    CGRect monthTitleRect;
}

- (instancetype)initWithPosition:(CGFloat)x y:(CGFloat)y;
- (void)setMode:(NSInteger)m;
- (void)refresh;

@property (nonatomic, weak) id<CalendarViewDelegate> calendarDelegate;
@property (nonatomic, strong) NSDate *currentDate;

// Colors
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *fontHeaderColor;
@property (nonatomic, strong) UIColor *fontSelectedColor;
@property (nonatomic, strong) UIColor *selectionColor;

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

@end
