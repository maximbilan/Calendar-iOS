//
//  CalendarView.h
//  wymg
//
//  Created by Maxim on 10/7/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewDayRect : NSObject 

@property int day;
@property CGRect frame;

@end

@protocol CalendarViewDelegate <NSObject>

@required
- (void)didChangeCalendarDate:(NSDate *)date;

@end

@interface CalendarView : UIView
{
	NSInteger currentDay;
	NSInteger currentMonth;
	NSInteger currentYear;
	
	NSMutableArray *dayRects;
}

- (id)initWithPosition:(CGFloat)x y:(CGFloat)y;

@property (nonatomic, weak) id<CalendarViewDelegate> calendarDelegate;

@end