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

static const CGFloat kCalendarViewDayCellWidth       = 35;
static const CGFloat kCalendarViewDayCellHeight      = 35;
static const CGFloat kCalendarViewDayCellOffset      = 5;

static const CGFloat kCalendarViewMonthCellWidth     = 90;
static const CGFloat kCalendarViewMonthCellHeight    = 30;
static const CGFloat kCalendarViewMonthTitleOffsetY  = 50;
static const CGFloat kCalendarViewMonthYStep         = 60;
static const NSInteger kCalendarViewMonthInLine      = 3;

static const CGFloat kCalendarViewYearCellWidth      = 54;
static const CGFloat kCalendarViewYearCellHeight     = 30;
static const CGFloat kCalendarViewYearTitleOffsetY   = 50;
static const CGFloat kCalendarViewYearYStep          = 45;
static const NSInteger kCalendarViewYearsAround      = 12;
static const NSInteger kCalendarViewYearsInLine      = 5;

static const CGFloat kCalendarViewMonthLabelWidth    = 100;
static const CGFloat kCalendarViewMonthLabelHeight   = 20;

static const CGFloat kCalendarViewYearLabelWidth     = 60;
static const CGFloat kCalendarViewYearLabelHeight    = 20;

static const CGFloat kCalendarViewWeekDaysYOffset    = 30;
static const CGFloat kCalendarViewDaysYOffset        = 60;

static NSString * const kCalendarViewDefaultFont     = @"TrebuchetMS";
static const CGFloat kCalendarViewDayFontSize        = 16;
static const CGFloat kCalendarViewHeaderFontSize     = 18;

static const NSInteger kCalendarViewDaysInWeek       = 7;
static const NSInteger kCalendarViewMonthInYear      = 12;
static const NSInteger kCalendarViewMaxLinesCount    = 6;

static const CGFloat kCalendarViewSelectionRound     = 3.0;

static const NSTimeInterval kCalendarViewSwipeMonthFadeInTime  = 0.2;
static const NSTimeInterval kCalendarViewSwipeMonthFadeOutTime = 0.6;

@implementation CalendarViewRect;

@end

@interface CalendarView ()
{
    NSInteger type;
    NSInteger minType;
    NSInteger mode;
    NSInteger event;
    
    NSInteger currentDay;
    NSInteger currentMonth;
    NSInteger currentYear;
        
    NSInteger todayDay;
    NSInteger todayMonth;
    NSInteger todayYear;
    
    NSMutableArray *dayRects;
    NSMutableArray *monthRects;
    NSMutableArray *yearRects;
    
    CGRect yearTitleRect;
    CGRect monthTitleRect;
    
    // Range selection properties
    NSInteger startRangeDay;
    NSInteger startRangeMonth;
    NSInteger startRangeYear;
    CalendarViewRect *startRangeDayRect;
    NSDate *startDate;
    
    NSInteger endRangeDay;
    NSInteger endRangeMonth;
    NSInteger endRangeYear;
    CalendarViewRect *endRangeDayRect;
    NSDate *endDate;
}

@property (nonatomic, strong) NSCalendarIdentifier calendarId;
@property (nonatomic, strong) NSLocale *calenderLocale;

- (void)setup;

- (void)generateDayRects;
- (void)generateMonthRects;
- (void)generateYearRects;
- (CGFloat)getEffectiveWeekDaysYOffset;
- (CGFloat)getEffectiveDaysYOffset;
- (CGFloat)getEffectiveMonthsYOffset;
- (CGFloat)getEffectiveYearsYOffset;

- (void)drawCircle:(CGRect)rect toContext:(CGContextRef *)context withColor:(UIColor *)color;
- (void)drawRoundedRectangle:(CGRect)rect toContext:(CGContextRef *)context;
- (void)drawWeekDays;

- (void)leftSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)rightSwipe:(UISwipeGestureRecognizer *)recognizer;
- (void)pinch:(UIPinchGestureRecognizer *)recognizer;
- (void)tap:(UITapGestureRecognizer *)recognizer;
- (void)doubleTap:(UITapGestureRecognizer *)recognizer;

- (void)changeDateEvent;

- (void)advanceCalendarContentsWithEvent:(CalendarEvent)eventType;
- (void)rewindCalendarContentsWithEvent:(CalendarEvent)eventType;

- (NSDictionary *)generateAttributes:(NSString *)fontName withFontSize:(CGFloat)fontSize withColor:(UIColor *)color withAlignment:(NSTextAlignment)textAlignment;
- (BOOL)checkPoint:(CGPoint)point inArray:(NSMutableArray *)array andSetValue:(NSInteger *)value;
- (void)fade;

- (void) setCalendarIdentifier:(NSCalendarIdentifier)calendarIdentifier;
- (NSCalendarIdentifier) calendarIdentifier;

@end

IB_DESIGNABLE
@implementation CalendarView

@synthesize currentDate = _currentDate;

#pragma mark - Initialization

- (instancetype)init
{
	self = [self initWithPosition:0.0 y:0.0];
	return self;
}

- (instancetype)initWithPosition:(CGFloat)x y:(CGFloat)y
{
	const CGFloat width = (kCalendarViewDayCellWidth + kCalendarViewDayCellOffset) * kCalendarViewDaysInWeek;
	const CGFloat height = (kCalendarViewDayCellHeight + kCalendarViewDayCellOffset) * kCalendarViewMaxLinesCount + kCalendarViewDaysYOffset;
	
    self = [self initWithFrame:CGRectMake(x, y, width, height)];
	
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initProperties];
    [self setup];
}

- (void)dealloc
{
    self.currentDate = nil;
    self.fontColor = nil;
    self.fontHeaderColor = nil;
    self.fontSelectedColor = nil;
    self.selectionColor = nil;
    self.fontName = nil;
}

#pragma mark - Setup

- (void) initProperties{
    self.dayCellWidth = kCalendarViewDayCellWidth;
    self.dayCellHeight = kCalendarViewDayCellHeight;
    self.monthCellWidth = kCalendarViewMonthCellWidth;
    self.monthCellHeight = kCalendarViewMonthCellHeight;
    self.yearCellWidth = kCalendarViewYearCellWidth;
    self.yearCellHeight = kCalendarViewYearCellHeight;
    
    self.preferredWeekStartIndex = 1; // This is Monday, from [dateFormatter shortWeekdaySymbols]
    if (!_fontName) {
        self.fontName = kCalendarViewDefaultFont;
    }
    if (!_dayFontSize) {
        self.dayFontSize = kCalendarViewDayFontSize;
    }
    if (!_headerFontSize) {
        self.headerFontSize = kCalendarViewHeaderFontSize;
    }
    
    [self setMode:CalendarModeDefault];
    self.fontColor = [UIColor blackColor];
    self.fontHeaderColor = [UIColor redColor];
    self.fontSelectedColor = [UIColor whiteColor];
    self.selectionColor = [UIColor redColor];
    self.todayColor = [UIColor redColor];
    self.bgColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.shouldMarkSelectedDate = YES;
    self.shouldMarkToday = NO;
    self.shouldShowHeaders = NO;
    
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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPress:)];
//    longPress.numberOfTapsRequired = 1;
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 0.2f;
    [self addGestureRecognizer:longPress];
}

- (void)setup
{
    dayRects = [[NSMutableArray alloc] init];
    monthRects = [[NSMutableArray alloc] init];
    yearRects = [[NSMutableArray alloc] init];
    
    yearTitleRect = CGRectMake(0, 0, 0, 0);
    monthTitleRect = CGRectMake(0, 0, 0, 0);
    
    event = CalendarEventNone;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    
    todayDay = [components day];
    todayMonth = [components month];
    todayYear = [components year];
    
    [self refresh];
}

- (void)setMode:(NSInteger)m
{
    mode = m;
    switch (mode) {
        case CalendarModeDefault:
        {
            type = CalendarViewTypeDay;
            minType = CalendarViewTypeDay;
        }
        break;
        case CalendarModeMonthsAndYears:
        {
            type = CalendarViewTypeMonth;
            minType = CalendarViewTypeMonth;
        }
        break;
        case CalendarModeYears:
        {
            type = CalendarViewTypeYear;
            minType = CalendarViewTypeYear;
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - calendarIdentifier getter/setter methods
- (void) setCalendarIdentifier:(NSCalendarIdentifier)calendarIdentifier{
    _calendarId = calendarIdentifier;
    if (calendarIdentifier == NSCalendarIdentifierPersian) {
        self.preferredWeekStartIndex = 0;
    }
}
- (NSCalendarIdentifier) calendarIdentifier{
    if (_calendarId) {
        return _calendarId;
    }
    return NSCalendarIdentifierGregorian;
}

#pragma mark - locale getter/setter methods
- (void) setLocale:(NSLocale *)locale{
    _calenderLocale = locale;
}
- (NSLocale *) locale{
    if (_calenderLocale) {
        return _calenderLocale;
    }
    return [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
}

#pragma mark - reload

- (void) goToToday{
    [self setup];
}
#pragma mark - Refresh

- (void)refresh
{
    NSDate *now = [NSDate date];
    [self setCurrentDate:now];
    
    if (self.calendarIdentifier == NSCalendarIdentifierPersian) {
        [self generatePersianDayRects];
    } else {
        [self generateDayRects];
    }
    [self generateMonthRects];
    [self generateYearRects];
}

#pragma mark - Getting, setting current date

- (void)setCurrentDate:(NSDate *)date
{
    if (date) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        currentDay = [components day];
        currentMonth = [components month];
        currentYear = [components year];
        
        switch (type) {
            case CalendarViewTypeDay:
                if (self.calendarIdentifier == NSCalendarIdentifierPersian) {
                    [self generatePersianDayRects];
                } else {
                    [self generateDayRects];
                }
                break;
            case CalendarViewTypeYear:
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
	return [self generateDateWithDay:currentDay month:currentMonth year:currentYear];
}

/*
    generateDateComponents
 Discussion :
    generate date component for current date and UTC time zone
 
 */
- (NSDateComponents *) generateDateComponents{
    NSDate *now = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
    [calendar setTimeZone:timeZone];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    
    [components setCalendar:calendar];
    [components setTimeZone:timeZone];
    
    return components;
}

- (NSDate *) generateDateWithDay:(NSInteger) day month:(NSInteger) month year:(NSInteger) year{
    NSDateComponents *components = [self generateDateComponents];
    
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [components.calendar dateFromComponents:components];
}

-(NSInteger) getLastDayOfMonth:(NSInteger) month year:(NSInteger) year{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
    
    NSDate *currentDate = [self generateDateWithDay:1 month:month year:year];
    return [currentDate getLastDayOfMonthForCalendar:calendar];
}

#pragma mark - Generating of rects

- (void)generateDayRects
{
	[dayRects removeAllObjects];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
	NSUInteger lastDayOfMonth = [self getLastDayOfMonth:currentMonth year:currentYear];
    
    if (currentDay > lastDayOfMonth) {
        currentDay = lastDayOfMonth;
    }
    
    NSDate *currentDate = [self generateDateWithDay:currentDay month:currentMonth year:currentYear];
    NSInteger weekday = [currentDate getWeekdayOfFirstDayOfMonthForCalendar:calendar];
	
	const CGFloat yOffSet = [self getEffectiveDaysYOffset];
	const CGFloat w = self.dayCellWidth;
	const CGFloat h = self.dayCellHeight;
	
	CGFloat x = 0;
	CGFloat y = yOffSet;
	
	NSInteger xi = weekday - self.preferredWeekStartIndex;
	NSInteger yi = 0;
	
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = self.locale;
    
	for (NSInteger i = 1; i <= lastDayOfMonth; ++i) {
		x = xi * (self.dayCellWidth + kCalendarViewDayCellOffset);
		++xi;
		
        CalendarViewRect *dayRect = [[CalendarViewRect alloc] init];
        dayRect.value = i;
        dayRect.str = [formatter stringForObjectValue:@(i)];
        dayRect.frame = CGRectMake(x, y, w, h);
        [dayRects addObject:dayRect];
        
		if (xi >= kCalendarViewDaysInWeek) {
			xi = 0;
			++yi;
			y = yOffSet + yi * (self.dayCellHeight + kCalendarViewDayCellOffset);
		}
	}
}

- (void) generatePersianDayRects{
    [dayRects removeAllObjects];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.calendarIdentifier];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    [components setYear:currentYear];
    [components setMonth:currentMonth];
    [components setDay:1];  // set first day of month
    
    NSDate *currentDate = [calendar dateFromComponents:components];
    NSUInteger lastDayOfMonth = [currentDate getLastDayOfMonthForCalendar:calendar];

    NSInteger startDayOfMonth = [currentDate getWeekdayOfFirstDayOfMonthForCalendar:calendar];
    NSInteger plusRow = startDayOfMonth == 7?2:1;
    if (startDayOfMonth >= 6 && lastDayOfMonth == 31) {
        plusRow = 2;
    }
    NSInteger weeks = (lastDayOfMonth / 7)+plusRow;
    NSInteger minimumDayOfWeek = 1;
    if (startDayOfMonth > 0) {
        startDayOfMonth = kCalendarViewDaysInWeek - (startDayOfMonth-1);
    } else {
        startDayOfMonth = kCalendarViewDaysInWeek;
    }
    NSMutableArray *daysOfMonth = [[NSMutableArray alloc] init];
    for (int i = 1; i <= weeks; i++) {
        NSMutableArray *arrayOfEachWeek = [[NSMutableArray alloc] init];
        for (NSInteger j = startDayOfMonth; j >= minimumDayOfWeek ; j--) {
            if (j > lastDayOfMonth) {
                break;
            }
            [arrayOfEachWeek addObject:@(j)];
        }
        [daysOfMonth addObject:arrayOfEachWeek];
        startDayOfMonth = (startDayOfMonth + kCalendarViewDaysInWeek);
        minimumDayOfWeek = (startDayOfMonth - kCalendarViewDaysInWeek)+1;
        if (startDayOfMonth > lastDayOfMonth) {
            startDayOfMonth = startDayOfMonth - (startDayOfMonth - lastDayOfMonth);
        }
    }
    
    [components setDay:currentDay];
    currentDate = [calendar dateFromComponents:components];
    NSInteger weekday = [currentDate getWeekdayOfFirstDayOfMonthForCalendar:calendar];
    weekday = weekday == 0 ? 1:weekday;
    const CGFloat yOffSet = [self getEffectiveDaysYOffset];
    const CGFloat w = self.dayCellWidth;
    const CGFloat h = self.dayCellHeight;
    
    CGFloat x = 0;
    CGFloat y = yOffSet;
    
    NSInteger xi = kCalendarViewDaysInWeek - weekday;
    NSInteger yi = 0;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = self.locale;
    NSInteger day = 1;
    for (int i = 0; i < daysOfMonth.count; i++) {
        NSArray *week = (NSArray *)daysOfMonth[i];
        for (int j = 0; j < week.count; j++) {
            x = xi * (self.dayCellWidth + kCalendarViewDayCellOffset);
            --xi;
            
            CalendarViewRect *dayRect = [[CalendarViewRect alloc] init];
            dayRect.value = day;
            dayRect.str = [formatter stringForObjectValue:@(day)];
            dayRect.frame = CGRectMake(x, y, w, h);
            if (j == kCalendarViewDaysInWeek -1 ||
                (i < daysOfMonth.count -1 && j == week.count -1)) {
                dayRect.isVecation = YES;
            }
            [dayRects addObject:dayRect];
            
            day ++;
        }
        xi = kCalendarViewDaysInWeek-1;
        ++yi;
        y = yOffSet + yi * (self.dayCellHeight + kCalendarViewDayCellOffset);
    }
}

- (void)generateMonthRects
{
    [monthRects removeAllObjects];
    
    NSDateFormatter *formater = [NSDateFormatter new];
    formater.locale = self.locale;
    NSArray *monthNames = [formater standaloneMonthSymbols];
    NSInteger index = 0;
    CGFloat x, y = [self getEffectiveMonthsYOffset];
    NSInteger xi = 0;
    for (NSString *monthName in monthNames) {
        x = xi * self.monthCellWidth;
        ++xi;
        ++index;
        
        CalendarViewRect *monthRect = [[CalendarViewRect alloc] init];
        monthRect.value = index;
        monthRect.str = monthName;
        monthRect.frame = CGRectMake(x, y, self.monthCellWidth, self.monthCellHeight);
        [monthRects addObject:monthRect];
        
        if (xi >= kCalendarViewMonthInLine) {
            xi = 0;
            y += kCalendarViewMonthYStep;
        }
    }
}

- (void)generateYearRects
{
    [yearRects removeAllObjects];
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for (NSInteger year = currentYear - kCalendarViewYearsAround; year <= currentYear + kCalendarViewYearsAround; ++year) {
        [years addObject:@(year)];
    }
    
    CGFloat x, y = [self getEffectiveYearsYOffset];
    NSInteger xi = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = self.locale;

    for (NSNumber *obj in years) {
        x = xi * self.yearCellWidth;
        ++xi;
        
        CalendarViewRect *yearRect = [[CalendarViewRect alloc] init];
        yearRect.value = [obj integerValue];
        yearRect.str = [formatter stringForObjectValue:@([obj integerValue])];
        yearRect.frame = CGRectMake(x, y, self.yearCellWidth, self.yearCellHeight);
        [yearRects addObject:yearRect];
        
        if (xi >= kCalendarViewYearsInLine) {
            xi = 0;
            y += kCalendarViewYearYStep;
        }
    }
}

# pragma mark - Layout Calculations 

- (CGFloat)getEffectiveWeekDaysYOffset
{
    if (self.shouldShowHeaders) {
        return kCalendarViewWeekDaysYOffset;
    } else {
        return 0;
    }
}

- (CGFloat)getEffectiveDaysYOffset
{
    if (self.shouldShowHeaders) {
        return  kCalendarViewDaysYOffset;
    } else {
        return kCalendarViewDaysYOffset - kCalendarViewWeekDaysYOffset;
    }
}

- (CGFloat)getEffectiveMonthsYOffset
{
    if (self.shouldShowHeaders) {
        return kCalendarViewMonthTitleOffsetY;
    } else {
        return 0;
    }
}

- (CGFloat)getEffectiveYearsYOffset
{
    if (self.shouldShowHeaders) {
        return kCalendarViewYearTitleOffsetY;
    } else return 0;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
	CGContextFillRect(context, rect);
    
	NSDictionary *attributesBlack = [self generateAttributes:self.fontName
												withFontSize:self.dayFontSize
												   withColor:self.fontColor
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
    
    NSDictionary *attributesRed = [self generateAttributes:self.fontName
                                                withFontSize:self.dayFontSize
                                                   withColor:[UIColor redColor]
                                               withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	NSDictionary *attributesWhite = [self generateAttributes:self.fontName
												withFontSize:self.dayFontSize
												   withColor:self.fontSelectedColor
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
    
	NSDictionary *attributesRedRight = [self generateAttributes:self.fontName
												   withFontSize:self.headerFontSize
													  withColor:self.fontHeaderColor
												  withAlignment:NSTextAlignmentFromCTTextAlignment(kCTRightTextAlignment)];
	
	NSDictionary *attributesRedLeft = [self generateAttributes:self.fontName
												  withFontSize:self.headerFontSize
													 withColor:self.fontHeaderColor
												 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTLeftTextAlignment)];
    
	CTFontRef cellFont = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.dayFontSize, NULL);
	CGRect cellFontBoundingBox = CTFontGetBoundingBox(cellFont);
	CFRelease(cellFont);
    
    NSNumberFormatter *yearFormater = [[NSNumberFormatter alloc] init];
    yearFormater.locale = self.locale;
	NSString *year = [yearFormater stringForObjectValue:@(currentYear)];
	const CGFloat yearNameX = (self.dayCellWidth - CGRectGetHeight(cellFontBoundingBox)) * 0.5;
    if (self.shouldShowHeaders) {
        yearTitleRect = CGRectMake(yearNameX, 0, kCalendarViewYearLabelWidth, kCalendarViewYearLabelHeight);
    } else {
        yearTitleRect = CGRectZero;
    }
	[year drawUsingRect:yearTitleRect withAttributes:attributesRedLeft];
	
    if (mode != CalendarModeYears) {
        NSDateFormatter *formater = [NSDateFormatter new];
        formater.locale = self.locale;
        NSArray *monthNames = [formater standaloneMonthSymbols];
        NSString *monthName = monthNames[(currentMonth - 1)];
        const CGFloat monthNameX = (self.dayCellWidth + kCalendarViewDayCellOffset) * kCalendarViewDaysInWeek - kCalendarViewMonthLabelWidth - (self.dayCellWidth - CGRectGetHeight(cellFontBoundingBox));
        if (self.shouldShowHeaders) {
            monthTitleRect = CGRectMake(monthNameX, 0, kCalendarViewMonthLabelWidth, kCalendarViewMonthLabelHeight);
        } else {
            monthTitleRect = CGRectZero;
        }
        [monthName drawUsingRect:monthTitleRect withAttributes:attributesRedRight];
    }
	
    NSMutableArray *rects = nil;
    NSInteger currentValue = 0;
    
    switch (type) {
        case CalendarViewTypeDay:
        {
            [self drawWeekDays];
            
            rects = dayRects;
            currentValue = currentDay;
        }
        break;
        case CalendarViewTypeMonth:
        {
            rects = monthRects;
            currentValue = currentMonth;
        }
        break;
        case CalendarViewTypeYear:
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
            NSDictionary *attrs = attributesBlack;
            CGRect rectText = rect.frame;
            rectText.origin.y = rectText.origin.y + ((CGRectGetHeight(rectText) - CGRectGetHeight(cellFontBoundingBox)) * 0.5);
            
            if (type == CalendarViewTypeDay && (((rect.value >= startRangeDay && rect.value <= endRangeDay) && currentMonth >= startRangeMonth && currentYear >= startRangeYear) || ((rect.value >= startRangeDay && rect.value <= endRangeDay) && currentMonth <= endRangeMonth && currentYear <= endRangeYear))) {
                if (type == CalendarViewTypeDay) {
                    [self drawCircle:rect.frame toContext:&context withColor:self.selectionColor];
                }
                
                attrs = attributesWhite;
            } else if ((type == CalendarViewTypeYear && (rect.value >= startRangeYear && rect.value <= endRangeYear)) || (endRangeYear == 0 && (type == CalendarViewTypeYear && rect.value == startRangeYear))) {
                [self drawRoundedRectangle:rect.frame toContext:&context];
                attrs = attributesWhite;
            } else if ((type == CalendarViewTypeMonth && (rect.value >= startRangeMonth && rect.value <= endRangeMonth)) || (endRangeMonth == 0 && (type == CalendarViewTypeMonth && rect.value == startRangeMonth))) {
                [self drawRoundedRectangle:rect.frame toContext:&context];
                attrs = attributesWhite;
             } else if ((startRangeDay == 0 && rect.value == currentValue && self.shouldMarkSelectedDate) ||
                        (rect.value == startRangeDay && currentMonth == startRangeMonth && currentYear == startRangeYear && type == CalendarViewTypeDay)) {
                 if (type == CalendarViewTypeDay) {
                     [self drawCircle:rect.frame toContext:&context withColor:self.selectionColor];
                 }
                 else {
                     [self drawRoundedRectangle:rect.frame toContext:&context];
                 }
                 
                 attrs = attributesWhite;
             } else if (type == CalendarViewTypeDay &&
                       rect.value == todayDay &&
                       currentMonth == todayMonth &&
                       currentYear == todayYear &&
                       self.shouldMarkToday) {
                [self drawCircle:rect.frame toContext:&context withColor:self.todayColor];
                attrs = attributesWhite;
             } else if (type == CalendarViewTypeMonth) {
                 attrs = attributesBlack;
             } else {
                attrs = attributesBlack;
            }
            
            if (rect.isVecation && attrs != attributesWhite) {
                attrs = attributesRed;
            }
            [rect.str drawUsingRect:rectText withAttributes:attrs];
        }
    }
    if ((startRangeDay > 0 && startRangeMonth > 0 && startRangeYear > 0) &&
        (endRangeDay > 0 && endRangeMonth > 0 && endRangeYear > 0)) {
        startRangeDay = 0;
        startRangeMonth = 0;
        startRangeYear = 0;
        
        endRangeDay = 0;
        endRangeMonth = 0;
        endRangeYear = 0;
    }
}

- (void)drawCircle:(CGRect)rect toContext:(CGContextRef *)context withColor:(UIColor *)color
{
    CGContextSetFillColorWithColor(*context, color.CGColor);
    CGContextFillEllipseInRect(*context, rect);
}

- (void)drawRoundedRectangle:(CGRect)rect toContext:(CGContextRef *)context
{
    CGContextSetFillColorWithColor(*context, self.selectionColor.CGColor);
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(*context, minx, midy);
    CGContextAddArcToPoint(*context, minx, miny, midx, miny, kCalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, maxx, miny, maxx, midy, kCalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, maxx, maxy, midx, maxy, kCalendarViewSelectionRound);
    CGContextAddArcToPoint(*context, minx, maxy, minx, midy, kCalendarViewSelectionRound);
    CGContextClosePath(*context);
    
    CGContextSetStrokeColorWithColor(*context, self.selectionColor.CGColor);
    CGContextDrawPath(*context, kCGPathFillStroke);
}

- (void)drawWeekDays
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = self.locale;
	NSArray *weekdayNames = [dateFormatter shortWeekdaySymbols];
    if (_useVeryShortWeekdaySymbols) {
        weekdayNames = [dateFormatter veryShortWeekdaySymbols];
    }
    
    if (self.calendarIdentifier == NSCalendarIdentifierPersian){
        NSMutableArray *arrayWeeks = [weekdayNames mutableCopy];
        [arrayWeeks insertObject:arrayWeeks.lastObject atIndex:0];
        [arrayWeeks removeObjectAtIndex:arrayWeeks.count-1];
        weekdayNames = [[arrayWeeks reverseObjectEnumerator] allObjects];
    }
    
	NSDictionary *attrs = [self generateAttributes:self.fontName
									  withFontSize:self.dayFontSize
										 withColor:self.fontColor
									 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
    
    NSDictionary *attrsForVecation = [self generateAttributes:self.fontName
                                      withFontSize:self.dayFontSize
                                         withColor:[UIColor redColor]
                                     withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	CGFloat x = 0;
	CGFloat y = [self getEffectiveWeekDaysYOffset];
	const CGFloat w = self.dayCellWidth;
	const CGFloat h = self.dayCellHeight;
    
	for (NSInteger i = self.preferredWeekStartIndex; i < kCalendarViewDaysInWeek; ++i) {
        NSInteger adjustedIndex = i - self.preferredWeekStartIndex;
		x = adjustedIndex * (self.dayCellWidth + kCalendarViewDayCellOffset);
		NSString *str = [NSString stringWithFormat:@"%@", weekdayNames[i]];
        if (self.calendarIdentifier == NSCalendarIdentifierPersian && i == 0) {
            [str drawUsingRect:CGRectMake(x, y, w, h) withAttributes:attrsForVecation];
        } else {
            [str drawUsingRect:CGRectMake(x, y, w, h) withAttributes:attrs];
        }
	}
    
    for (NSInteger i = 0; i < self.preferredWeekStartIndex; ++i) {
        NSInteger adjustedIndex = kCalendarViewDaysInWeek - (self.preferredWeekStartIndex - i);
        x = adjustedIndex * (self.dayCellWidth + kCalendarViewDayCellOffset);
        NSString *str = [NSString stringWithFormat:@"%@", weekdayNames[i]];
        [str drawUsingRect:CGRectMake(x, y, w, h) withAttributes:attrs];
    }

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

#pragma mark - Select range of calendar

- (void) selectRangeOfCalendar{
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(didSelectRangeForStartDate:andEndDate:)]) {
        [_calendarDelegate didSelectRangeForStartDate:startDate andEndDate:endDate];
    }
}

#pragma mark - Advance/Rewind Calendar Contents

- (void)advanceCalendarContents
{
    [self advanceCalendarContentsWithEvent:CalendarEventNone];
}

- (void)rewindCalendarContents
{
    [self rewindCalendarContentsWithEvent:CalendarEventNone];
}

- (void)advanceCalendarContentsWithEvent:(CalendarEvent)eventType
{
    event = eventType;
    
    switch (type) {
        case CalendarViewTypeDay:
        {
            if (currentMonth == kCalendarViewMonthInYear) {
                currentMonth = 1;
                ++currentYear;
            }
            else {
                ++currentMonth;
            }
            
            if (self.calendarIdentifier == NSCalendarIdentifierPersian) {
                [self generatePersianDayRects];
            } else {
                [self generateDayRects];
            }
        }
            break;
        case CalendarViewTypeMonth:
        {
            ++currentYear;
        }
            break;
        case CalendarViewTypeYear:
        {
            currentYear += kCalendarViewYearsAround;
            [self generateYearRects];
        }
            break;
            
        default:
            break;
    }
    
    [self changeDateEvent];
    [self fade];
}

- (void)rewindCalendarContentsWithEvent:(CalendarEvent)eventType
{
    event = eventType;
    
    switch (type) {
        case CalendarViewTypeDay:
        {
            if (currentMonth == 1) {
                currentMonth = kCalendarViewMonthInYear;
                --currentYear;
            }
            else {
                --currentMonth;
            }
            
            if (self.calendarIdentifier == NSCalendarIdentifierPersian) {
                [self generatePersianDayRects];
            } else {
                [self generateDayRects];
            }
        }
            break;
        case CalendarViewTypeMonth:
        {
            --currentYear;
        }
            break;
        case CalendarViewTypeYear:
        {
            currentYear -= kCalendarViewYearsAround;
            [self generateYearRects];
        }
            break;
            
        default:
            break;
    }
    
    [self changeDateEvent];
    [self fade];
}

#pragma mark - Gestures

- (void)leftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self advanceCalendarContentsWithEvent:CalendarEventSwipeLeft];
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self rewindCalendarContentsWithEvent:CalendarEventSwipeRight];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSInteger t = type;
        if (recognizer.velocity < 0) {
            event = CalendarEventPinchIn;
            if (t - 1 >= minType) {
                --t;
            }
        }
        else {
            event = CalendarEventPinchOut;
            if (t + 1 < CalendarViewTypeCount) {
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
    event = CalendarEventTap;
    CGPoint touchPoint = [recognizer locationInView:self];
    
    if (CGRectContainsPoint(yearTitleRect, touchPoint)) {
        if (type != CalendarViewTypeYear) {
            type = CalendarViewTypeYear;
            [self fade];
        }
        return;
    }
    
    if (CGRectContainsPoint(monthTitleRect, touchPoint)) {
        if (type != CalendarViewTypeMonth) {
            type = CalendarViewTypeMonth;
            [self fade];
        }
        return;
    }
    
    BOOL hasEvent = NO;
    switch (type) {
        case CalendarViewTypeDay:
        {
            hasEvent = [self checkPoint:touchPoint inArray:dayRects andSetValue:&currentDay];
        }
        break;
        case CalendarViewTypeMonth:
        {
            hasEvent = [self checkPoint:touchPoint inArray:monthRects andSetValue:&currentMonth];
        }
        break;
        case CalendarViewTypeYear:
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
    event = CalendarEventDoubleTap;
    if (type != CalendarViewTypeDay && type > minType) {
        --type;
        [self fade];
    }
    
    if (type == CalendarViewTypeDay) {
        if (self.calendarIdentifier == NSCalendarIdentifierPersian) {
            [self generatePersianDayRects];
        } else {
            [self generateDayRects];
        }
    }
    
    NSDate *currentDate = [self currentDate];
    if (event == CalendarEventDoubleTap && _calendarDelegate && [_calendarDelegate respondsToSelector:@selector(didDoubleTapCalendar:withType:)]) {
        [_calendarDelegate didDoubleTapCalendar:currentDate withType:type];
    }
}

- (void) longPress:(UILongPressGestureRecognizer *) press{
    //TODO: create start rect and with another tap select the end section
    NSSet *key = [press valueForKey:@"activeTouches"];
    if (key.count == 0) {
        return;
    }

    NSInteger day = 0;
    CGPoint touchPoint = [press locationInView:self];

    CalendarViewRect *rectWasTapped = nil;

    if (type == CalendarViewTypeYear){
        rectWasTapped = [self checkPoint:touchPoint inArray:yearRects];
        if (startRangeYear == 0) {
            startRangeDay = 1;
            startRangeMonth = 1;
            startRangeYear = rectWasTapped.value;
        } else {
            endRangeMonth = 12;
            if (startRangeYear > rectWasTapped.value) {
                endRangeYear = startRangeDay;
                startRangeYear = rectWasTapped.value;
            } else {
                endRangeYear = rectWasTapped.value;
            }
            endRangeDay = [self getLastDayOfMonth:endRangeMonth year:endRangeYear];
        }
    } else if (type == CalendarViewTypeMonth) {
        rectWasTapped = [self checkPoint:touchPoint inArray:monthRects];

        if (startRangeMonth == 0) {
            startRangeDay = 1;
            startRangeMonth = rectWasTapped.value;
            startRangeYear = currentYear;
        } else {
            endRangeYear = currentYear;
            if (startRangeMonth > rectWasTapped.value) {
                endRangeMonth = startRangeMonth;
                startRangeMonth = rectWasTapped.value;
            } else {
                endRangeMonth = rectWasTapped.value;
            }
            endRangeDay = [self getLastDayOfMonth:endRangeMonth year:endRangeYear];
        }
    } else if (type == CalendarViewTypeDay) {
        rectWasTapped = [self checkPoint:touchPoint inArray:dayRects];
        if (rectWasTapped) {
            day = rectWasTapped.value;
            if (startRangeDay == 0 && startRangeMonth == 0 && startRangeYear == 0) {
                startRangeDay = day;
                startRangeMonth = currentMonth;
                startRangeYear = currentYear;
            } else {
                if (day > startRangeDay && currentMonth >= startRangeMonth && currentYear >= startRangeYear) {
                    endRangeDay = day;
                    endRangeMonth = currentMonth;
                    endRangeYear = currentYear;
                } else {
                    endRangeDay = startRangeDay;
                    endRangeMonth = startRangeMonth;
                    endRangeYear = startRangeYear;
                    
                    startRangeDay = day;
                    startRangeMonth = currentMonth;
                    startRangeYear = currentYear;
                }
            }
        }
    }
    
    startDate = [self generateDateWithDay:startRangeDay month:startRangeMonth year:startRangeYear];
    if (endRangeYear > 0) {
        endDate = [self generateDateWithDay:endRangeDay month:endRangeMonth year:endRangeYear];
    }
    
    [self selectRangeOfCalendar];
    [self setNeedsDisplay];
}
#pragma mark - Additional functions

- (BOOL)checkPoint:(CGPoint)point inArray:(NSMutableArray *)array andSetValue:(NSInteger *)value{
    CalendarViewRect *rect = [self checkPoint:point inArray:array];
    if (!rect) {
        return NO;
    }
    *value = rect.value;
    return YES;
}

- (CalendarViewRect *)checkPoint:(CGPoint)point inArray:(NSMutableArray *)array{
    for (CalendarViewRect *rect in array) {
        if (CGRectContainsPoint(rect.frame, point)) {
            return rect;
        }
    }
    return nil;
}

- (NSDictionary *)generateAttributes:(NSString *)fontName withFontSize:(CGFloat)fontSize withColor:(UIColor *)color withAlignment:(NSTextAlignment)textAlignment
{
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:textAlignment];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    UIFont *font = nil;
    if ([self.fontName isEqualToString:@"TrebuchetMS"] && self.calendarIdentifier == NSCalendarIdentifierPersian) {
        font = [UIFont systemFontOfSize:fontSize];
    } else {
        font = [UIFont fontWithName:self.fontName size:fontSize];
    }
	NSDictionary * attrs = @{
							 NSFontAttributeName : font,
							 NSForegroundColorAttributeName : color,
							 NSParagraphStyleAttributeName : paragraphStyle
							 };
	
	return attrs;
}

- (void)fade
{
	[UIView animateWithDuration:kCalendarViewSwipeMonthFadeInTime
						  delay:0
						options:0
					 animations:^{
						 self.alpha = 0.0f;
					 }
					 completion:^(BOOL finished) {
						 [self setNeedsDisplay];
						 [UIView animateWithDuration:kCalendarViewSwipeMonthFadeOutTime
											   delay:0
											 options:0
										  animations:^{
											  self.alpha = 1.0f;
										  }
										  completion:nil];
					 }];
}

@end
