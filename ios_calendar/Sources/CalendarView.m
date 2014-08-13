//
//  CalendarView.m
//  ios_calendar
//
//  Created by Maxim on 10/7/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import "CalendarView.h"
#import "NSDate+CalendarView.h"
#import "NSString+CalendarView.h"

#import <CoreText/CoreText.h>

static const CGFloat CalendarViewDayCellWidth       = 35;
static const CGFloat CalendarViewDayCellHeight      = 35;
static const CGFloat CalendarViewDayCellOffset      = 5;

static const CGFloat CalendarViewMonthCellWidth     = 90;
static const CGFloat CalendarViewMonthCellHeight    = 30;
static const CGFloat CalendarViewMonthTitleOffsetY  = 50;
static const CGFloat CalendarViewMonthYStep         = 60;
static const NSInteger CalendarViewMonthInLine      = 3;

static const CGFloat CalendarViewYearCellWidth      = 54;
static const CGFloat CalendarViewYearCellHeight     = 30;
static const CGFloat CalendarViewYearTitleOffsetY   = 50;
static const CGFloat CalendarViewYearYStep          = 45;
static const NSInteger CalendarViewYearsAround      = 12;
static const NSInteger CalendarViewYearsInLine      = 5;

static const CGFloat CalendarViewMonthLabelWidth    = 100;
static const CGFloat CalendarViewMonthLabelHeight   = 20;

static const CGFloat CalendarViewYearLabelWidth     = 40;
static const CGFloat CalendarViewYearLabelHeight    = 20;

static const CGFloat CalendarViewWeekDaysYOffset    = 30;
static const CGFloat CalendarViewDaysYOffset        = 60;

static NSString * const CalendarViewDefaultFont     = @"TrebuchetMS";
static const CGFloat CalendarViewDayFontSize        = 16;
static const CGFloat CalendarViewHeaderFontSize     = 18;

static const NSInteger CalendarViewDaysInWeek       = 7;
static const NSInteger CalendarViewMonthInYear      = 12;
static const NSInteger CalendarViewMaxLinesCount    = 6;

static const CGFloat CalendarViewSelectionRound     = 3.0;

static const NSTimeInterval CalendarViewSwipeMonthFadeInTime  = 0.2;
static const NSTimeInterval CalendarViewSwipeMonthFadeOutTime = 0.6;

@implementation CalendarViewRect;

@end

@interface CalendarView ()
{
    UIColor *bgColor;
}

- (void)setup;

- (void)generateDayRects;
- (void)generateMonthRects;
- (void)generateYearRects;

- (void)drawCircle:(CGRect)rect toContext:(CGContextRef *)context;
- (void)drawRoundedRectangle:(CGRect)rect toContext:(CGContextRef *)context;
- (void)drawWeekDays;

- (void)leftSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)rightSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)pinch:(UIPinchGestureRecognizer *)recognizer;
- (void)tap:(UITapGestureRecognizer *)recognizer;
- (void)doubleTap:(UITapGestureRecognizer *)recognizer;

- (void)changeDateEvent;

- (NSDictionary *)generateAttributes:(NSString *)fontName withFontSize:(CGFloat)fontSize withColor:(UIColor *)color withAlignment:(NSTextAlignment)textAlignment;
- (BOOL)checkPoint:(CGPoint)point inArray:(NSMutableArray *)array andSetValue:(NSInteger *)value;
- (void)fade;

@end

@implementation CalendarView

@synthesize currentDate = _currentDate;

#pragma mark - Initialization

- (id)init
{
	self = [self initWithPosition:0.0 y:0.0];
	return self;
}

- (id)initWithPosition:(CGFloat)x y:(CGFloat)y
{
	const CGFloat width = (CalendarViewDayCellWidth + CalendarViewDayCellOffset) * CalendarViewDaysInWeek;
	const CGFloat height = (CalendarViewDayCellHeight + CalendarViewDayCellOffset) * CalendarViewMaxLinesCount + CalendarViewDaysYOffset;
	
    self = [self initWithFrame:CGRectMake(x, y, width, height)];
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)dealloc
{
    self.currentDate = nil;
    self.fontColor = nil;
    self.fontHeaderColor = nil;
    self.fontSelectedColor = nil;
    self.selectionColor = nil;
}

#pragma mark - Setup

- (void)setup
{
    dayRects = [[NSMutableArray alloc] init];
    monthRects = [[NSMutableArray alloc] init];
    yearRects = [[NSMutableArray alloc] init];
    
    yearTitleRect = CGRectMake(0, 0, 0, 0);
    monthTitleRect = CGRectMake(0, 0, 0, 0);
    
    self.fontColor = [UIColor blackColor];
    self.fontHeaderColor = [UIColor redColor];
    self.fontSelectedColor = [UIColor whiteColor];
    self.selectionColor = [UIColor redColor];
    bgColor = [UIColor whiteColor];
    
    event = CE_None;
    
    [self setMode:CM_Default];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    
    currentDay = [components day];
    currentMonth = [components month];
    currentYear = [components year];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:right];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [self generateDayRects];
    [self generateMonthRects];
    [self generateYearRects];
}

- (void)setMode:(NSInteger)m
{
    mode = m;
    switch (mode) {
        case CM_Default:
        {
            type = CTDay;
            minType = CTDay;
        }
        break;
        case CM_MonthsAndYears:
        {
            type = CTMonth;
            minType = CTMonth;
        }
        break;
        case CM_Years:
        {
            type = CTYear;
            minType = CTYear;
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - Getting, setting current date

- (void)setCurrentDate:(NSDate *)date
{
    if (date) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
        currentDay = [components day];
        currentMonth = [components month];
        currentYear = [components year];
        
        switch (type) {
            case CTDay:
                [self generateDayRects];
                break;
            case CTYear:
                [self generateYearRects];
                break;
            default:
                break;
        }
        
        [self fade];
        
        _currentDate = date;
    }
}

- (NSDate *)currentDate
{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timeZone];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
	[components setYear:currentYear];
	[components setMonth:currentMonth];
	[components setDay:currentDay];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setTimeZone:timeZone];
	
	return [calendar dateFromComponents:components];
}

#pragma mark - Generating of rects

- (void)generateDayRects
{
	[dayRects removeAllObjects];
	
	NSDate *now = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
	[components setYear:currentYear];
	[components setMonth:currentMonth];
	[components setDay:1];  // set first day of month
	
    NSDate *currentDate = [calendar dateFromComponents:components];
	NSUInteger lastDayOfMonth = [currentDate getLastDayOfMonth];
    if (currentDay > lastDayOfMonth) {
        currentDay = lastDayOfMonth;
    }
    
    [components setDay:currentDay];
    currentDate = [calendar dateFromComponents:components];
    NSInteger weekday = [currentDate getWeekdayOfFirstDayOfMonth];
	
	const CGFloat yOffSet = CalendarViewDaysYOffset;
	const CGFloat w = CalendarViewDayCellWidth;
	const CGFloat h = CalendarViewDayCellHeight;
	
	CGFloat x = 0;
	CGFloat y = yOffSet;
	
	NSInteger xi = weekday - 1;
	NSInteger yi = 0;
	
	for (NSInteger i = 1; i <= lastDayOfMonth; ++i) {
		x = xi * (CalendarViewDayCellWidth + CalendarViewDayCellOffset);
		++xi;
		
        CalendarViewRect *dayRect = [[CalendarViewRect alloc] init];
        dayRect.value = i;
        dayRect.str = [NSString stringWithFormat:@"%ld", (long)i];
        dayRect.frame = CGRectMake(x, y, w, h);
        [dayRects addObject:dayRect];
        
		if (xi >= CalendarViewDaysInWeek) {
			xi = 0;
			++yi;
			y = yOffSet + yi * (CalendarViewDayCellHeight + CalendarViewDayCellOffset);
		}
	}
}

- (void)generateMonthRects
{
    [monthRects removeAllObjects];
    
    NSDateFormatter *formater = [NSDateFormatter new];
    NSArray *monthNames = [formater standaloneMonthSymbols];
    NSInteger index = 0;
    CGFloat x, y = CalendarViewMonthTitleOffsetY;
    NSInteger xi = 0;
    for (NSString *monthName in monthNames) {
        x = xi * CalendarViewMonthCellWidth;
        ++xi;
        ++index;
        
        CalendarViewRect *monthRect = [[CalendarViewRect alloc] init];
        monthRect.value = index;
        monthRect.str = monthName;
        monthRect.frame = CGRectMake(x, y, CalendarViewMonthCellWidth, CalendarViewMonthCellHeight);
        [monthRects addObject:monthRect];
        
        if (xi >= CalendarViewMonthInLine) {
            xi = 0;
            y += CalendarViewMonthYStep;
        }
    }
}

- (void)generateYearRects
{
    [yearRects removeAllObjects];
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for (NSInteger year = currentYear - CalendarViewYearsAround; year <= currentYear + CalendarViewYearsAround; ++year) {
        [years addObject:@(year)];
    }
    
    CGFloat x, y = CalendarViewYearTitleOffsetY;
    NSInteger xi = 0;
    for (NSNumber *obj in years) {
        x = xi * CalendarViewYearCellWidth;
        ++xi;
        
        CalendarViewRect *yearRect = [[CalendarViewRect alloc] init];
        yearRect.value = [obj integerValue];
        yearRect.str = [NSString stringWithFormat:@"%ld", (long)[obj integerValue]];
        yearRect.frame = CGRectMake(x, y, CalendarViewYearCellWidth, CalendarViewYearCellHeight);
        [yearRects addObject:yearRect];
        
        if (xi >= CalendarViewYearsInLine) {
            xi = 0;
            y += CalendarViewYearYStep;
        }
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGContextSetFillColorWithColor(context, bgColor.CGColor);
	CGContextFillRect(context, rect);
    
	NSDictionary *attributesBlack = [self generateAttributes:CalendarViewDefaultFont
												withFontSize:CalendarViewDayFontSize
												   withColor:self.fontColor
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	NSDictionary *attributesWhite = [self generateAttributes:CalendarViewDefaultFont
												withFontSize:CalendarViewDayFontSize
												   withColor:self.fontSelectedColor
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
    
	NSDictionary *attributesRedRight = [self generateAttributes:CalendarViewDefaultFont
												   withFontSize:CalendarViewHeaderFontSize
													  withColor:self.fontHeaderColor
												  withAlignment:NSTextAlignmentFromCTTextAlignment(kCTRightTextAlignment)];
	
	NSDictionary *attributesRedLeft = [self generateAttributes:CalendarViewDefaultFont
												  withFontSize:CalendarViewHeaderFontSize
													 withColor:self.fontHeaderColor
												 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTLeftTextAlignment)];
    
	CTFontRef cellFont = CTFontCreateWithName((CFStringRef)CalendarViewDefaultFont, CalendarViewDayFontSize, NULL);
	CGRect cellFontBoundingBox = CTFontGetBoundingBox(cellFont);
	CFRelease(cellFont);
    
	NSString *year = [NSString stringWithFormat:@"%ld", (long)currentYear];
	const CGFloat yearNameX = (CalendarViewDayCellWidth - CGRectGetHeight(cellFontBoundingBox)) * 0.5;
    yearTitleRect = CGRectMake(yearNameX, 0, CalendarViewYearLabelWidth, CalendarViewYearLabelHeight);
	[year drawUsingRect:yearTitleRect withAttributes:attributesRedLeft];
	
    if (mode != CM_Years) {
        NSDateFormatter *formater = [NSDateFormatter new];
        NSArray *monthNames = [formater standaloneMonthSymbols];
        NSString *monthName = monthNames[(currentMonth - 1)];
        const CGFloat monthNameX = (CalendarViewDayCellWidth + CalendarViewDayCellOffset) * CalendarViewDaysInWeek - CalendarViewMonthLabelWidth - (CalendarViewDayCellWidth - CGRectGetHeight(cellFontBoundingBox));
        monthTitleRect = CGRectMake(monthNameX, 0, CalendarViewMonthLabelWidth, CalendarViewMonthLabelHeight);
        [monthName drawUsingRect:monthTitleRect withAttributes:attributesRedRight];
    }
	
    NSMutableArray *rects = nil;
    NSInteger currentValue = 0;
    
    switch (type) {
        case CTDay:
        {
            [self drawWeekDays];
            
            rects = dayRects;
            currentValue = currentDay;
        }
        break;
        case CTMonth:
        {
            rects = monthRects;
            currentValue = currentMonth;
        }
        break;
        case CTYear:
        {
            rects = yearRects;
            currentValue = currentYear;
        }
        break;
            
        default:
            break;
    }
    
    if (rects) {
        for (CalendarViewRect *rect in rects) {
            NSDictionary *attrs = nil;
            CGRect rectText = rect.frame;
            rectText.origin.y = rectText.origin.y + ((CGRectGetHeight(rectText) - CGRectGetHeight(cellFontBoundingBox)) * 0.5);
            
            if (rect.value == currentValue) {
                if (type == CTDay) {
                    [self drawCircle:rect.frame toContext:&context];
                }
                else {
                    [self drawRoundedRectangle:rect.frame toContext:&context];
                }
                
                attrs = attributesWhite;
            }
            else {
                attrs = attributesBlack;
            }
            
            [rect.str drawUsingRect:rectText withAttributes:attrs];
        }
    }
}

- (void)drawCircle:(CGRect)rect toContext:(CGContextRef *)context
{
    CGContextSetFillColorWithColor(*context, self.selectionColor.CGColor);
    CGContextFillEllipseInRect(*context, rect);
}

- (void)drawRoundedRectangle:(CGRect)rect toContext:(CGContextRef *)context
{
    CGContextSetFillColorWithColor(*context, self.selectionColor.CGColor);
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(*context, minx, midy);
    CGContextAddArcToPoint(*context, minx, miny, midx, miny, CalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, maxx, miny, maxx, midy, CalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, maxx, maxy, midx, maxy, CalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, minx, maxy, minx, midy, CalendarViewSelectionRound);
    CGContextClosePath(*context);
    
    CGContextSetStrokeColorWithColor(*context, self.selectionColor.CGColor);
    CGContextDrawPath(*context, kCGPathFillStroke);
}

- (void)drawWeekDays
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *weekdayNames = [dateFormatter shortWeekdaySymbols];
	
	NSDictionary *attrs = [self generateAttributes:CalendarViewDefaultFont
									  withFontSize:CalendarViewDayFontSize
										 withColor:self.fontColor
									 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	CGFloat x = 0;
	CGFloat y = CalendarViewWeekDaysYOffset;
	const CGFloat w = CalendarViewDayCellWidth;
	const CGFloat h = CalendarViewDayCellHeight;
	for (int i = 1; i < CalendarViewDaysInWeek; ++i) {
		x = (i - 1) * (CalendarViewDayCellWidth + CalendarViewDayCellOffset);
		NSString *str = [NSString stringWithFormat:@"%@", weekdayNames[i]];
		[str drawUsingRect:CGRectMake(x, y, w, h) withAttributes:attrs];
	}
	
	NSString *strSunday = [NSString stringWithFormat:@"%@",weekdayNames[0]];
	x = (CalendarViewDaysInWeek - 1) * (CalendarViewDayCellWidth + CalendarViewDayCellOffset);
	[strSunday drawUsingRect:CGRectMake(x, y, w, h) withAttributes:attrs];
}

#pragma mark - Change date event

- (void)changeDateEvent
{
	NSDate *currentDate = [self currentDate];
	if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(didChangeCalendarDate:)]) {
		[_calendarDelegate didChangeCalendarDate:currentDate];
	}
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(didChangeCalendarDate:withType:withEvent:)]) {
        [_calendarDelegate didChangeCalendarDate:currentDate withType:type withEvent:event];
    }
}

#pragma mark - Gestures

- (void)leftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    event = CE_SwipeLeft;
    
    switch (type) {
        case CTDay:
        {
            if (currentMonth == CalendarViewMonthInYear) {
                currentMonth = 1;
                ++currentYear;
            }
            else {
                ++currentMonth;
            }
            
            [self generateDayRects];
        }
        break;
        case CTMonth:
        {
            ++currentYear;
        }
        break;
        case CTYear:
        {
            currentYear += CalendarViewYearsAround;
            [self generateYearRects];
        }
        break;
            
        default:
            break;
    }
	
	[self changeDateEvent];
	[self fade];
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    event = CE_SwipeRight;
    
    switch (type) {
        case CTDay:
        {
            if (currentMonth == 1) {
                currentMonth = CalendarViewMonthInYear;
                --currentYear;
            }
            else {
                --currentMonth;
            }
            
            [self generateDayRects];
        }
        break;
        case CTMonth:
        {
            --currentYear;
        }
        break;
        case CTYear:
        {
            currentYear -= CalendarViewYearsAround;
            [self generateYearRects];
        }
        break;
            
        default:
            break;
    }
    
	[self changeDateEvent];
	[self fade];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSInteger t = type;
        if (recognizer.velocity < 0) {
            event = CE_PinchIn;
            if (t - 1 >= minType) {
                --t;
            }
        }
        else {
            event = CE_PinchOut;
            if (t + 1 < CT_Count) {
                ++t;
            }
        }
        
        if (t != type) {
            type = t;
            [self fade];
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    event = CE_Tap;
    CGPoint touchPoint = [recognizer locationInView:self];
    
    if (CGRectContainsPoint(yearTitleRect, touchPoint)) {
        if (type != CTYear) {
            type = CTYear;
            [self fade];
        }
        return;
    }
    
    if (CGRectContainsPoint(monthTitleRect, touchPoint)) {
        if (type != CTMonth) {
            type = CTMonth;
            [self fade];
        }
        return;
    }
    
    BOOL hasEvent = NO;
    switch (type) {
        case CTDay:
        {
            hasEvent = [self checkPoint:touchPoint inArray:dayRects andSetValue:&currentDay];
        }
        break;
        case CTMonth:
        {
            hasEvent = [self checkPoint:touchPoint inArray:monthRects andSetValue:&currentMonth];
        }
        break;
        case CTYear:
        {
            hasEvent = [self checkPoint:touchPoint inArray:yearRects andSetValue:&currentYear];
        }
        break;
            
        default:
            break;
    }
    
    if (hasEvent) {
        [self changeDateEvent];
        [self setNeedsDisplay];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    event = CE_DoubleTap;
    if (type != CTDay && type > minType) {
        --type;
        [self fade];
    }
    
    if (type == CTDay) {
        [self generateDayRects];
    }
    
    NSDate *currentDate = [self currentDate];
    if (event == CE_DoubleTap && _calendarDelegate && [_calendarDelegate respondsToSelector:@selector(didDoubleTapCalendar:withType:)]) {
        [_calendarDelegate didDoubleTapCalendar:currentDate withType:type];
    }
}

#pragma mark - Additional functions

- (BOOL)checkPoint:(CGPoint)point inArray:(NSMutableArray *)array andSetValue:(NSInteger *)value
{
    for (CalendarViewRect *rect in array) {
        if (CGRectContainsPoint(rect.frame, point)) {
            *value = rect.value;
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)generateAttributes:(NSString *)fontName withFontSize:(CGFloat)fontSize withColor:(UIColor *)color withAlignment:(NSTextAlignment)textAlignment
{
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:textAlignment];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	NSDictionary * attrs = @{
							 NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize],
							 NSForegroundColorAttributeName : color,
							 NSParagraphStyleAttributeName : paragraphStyle
							 };
	
	return attrs;
}

- (void)fade
{
	[UIView animateWithDuration:CalendarViewSwipeMonthFadeInTime
						  delay:0
						options:0
					 animations:^{
						 self.alpha = 0.0f;
					 }
					 completion:^(BOOL finished) {
						 [self setNeedsDisplay];
						 [UIView animateWithDuration:CalendarViewSwipeMonthFadeOutTime
											   delay:0
											 options:0
										  animations:^{
											  self.alpha = 1.0f;
										  }
										  completion:nil];
					 }];
}

@end
