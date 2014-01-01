//
//  CalendarView.m
//  ios_calendar
//
//  Created by Maxim on 10/7/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import "CalendarView.h"
#import "NSDate+CalendarView.h"

#import <CoreText/CoreText.h>

static const NSTimeInterval CalendarViewSwipeMonthFadeInTime  = 0.2;
static const NSTimeInterval CalendarViewSwipeMonthFadeOutTime = 0.6;

static const CGFloat CalendarViewDayCellWidth   = 35;
static const CGFloat CalendarViewDayCellHeight  = 35;
static const CGFloat CalendarViewDayCellOffset  = 5;

static const CGFloat CalendarViewMonthLabelWidth  = 100;
static const CGFloat CalendarViewMonthLabelHeight = 20;

static const CGFloat CalendarViewYearLabelWidth  = 40;
static const CGFloat CalendarViewYearLabelHeight = 20;

static const CGFloat CalendarViewWeekDaysYOffset = 30;
static const CGFloat CalendarViewDaysYOffset     = 60;

static NSString * const CalendarViewDefaultFont = @"TrebuchetMS";
static const CGFloat CalendarViewDayFontSize    = 16;
static const CGFloat CalendarViewHeaderFontSize = 18;

static const int CalendarViewDaysInWeek     = 7;
static const int CalendarViewMonthInYear    = 12;
static const int CalendarViewMaxLinesCount  = 6;

@implementation CalendarViewDayRect

@synthesize day;
@synthesize frame;

@end

@interface CalendarView ()

- (void)setup;

- (void)generateDayRects;
- (NSDictionary *)generateAttributes:(NSString *)fontName withFontSize:(CGFloat)fontSize withColor:(UIColor *)color withAlignment:(NSTextAlignment)textAlignment;

- (void)drawDay:(const int)day inRect:(CGRect)rect withAttributes:(NSDictionary *)attrs;
- (void)drawWeekDays;

- (void)leftSwipe;
- (void)rightSwipe;
- (void)swipeMonth;

- (void)changeDateEvent;

@end

@implementation CalendarView

@synthesize calendarDelegate = _calendarDelegate;

- (id)init
{
	self = [self initWithPosition:0 y:0];
	return self;
}

- (id)initWithPosition:(CGFloat)x y:(CGFloat)y
{
	const CGFloat width = ( CalendarViewDayCellWidth + CalendarViewDayCellOffset ) * CalendarViewDaysInWeek;
	const CGFloat height = ( CalendarViewDayCellHeight + CalendarViewDayCellOffset ) * CalendarViewMaxLinesCount + CalendarViewDaysYOffset;
	
    self = [self initWithFrame:CGRectMake( x, y, width, height )];
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
	{
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    dayRects = [[NSMutableArray alloc] init];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    
    currentDay = [components day];
    currentMonth = [components month];
    currentYear = [components year];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:right];
    
    [self generateDayRects];
}

- (void)generateDayRects
{
	[dayRects removeAllObjects];
	
	NSDate *now = [NSDate date];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
	
	[components setYear:currentYear];
	[components setMonth:currentMonth];
	[components setDay:currentDay];
	
	NSDate *currentDate = [calendar dateFromComponents:components];
	NSUInteger lastDayOfMonth = [currentDate getLastDayOfMonth];
	NSInteger weekday = [currentDate getWeekdayOfFirstDayOfMonth];
	
	const CGFloat yOffSet = CalendarViewDaysYOffset;
	const CGFloat w = CalendarViewDayCellWidth;
	const CGFloat h = CalendarViewDayCellHeight;
	
	CGFloat x = 0;
	CGFloat y = yOffSet;
	
	int xi = (int)weekday - 1;
	int yi = 0;
	
	for( int i = 1; i <= lastDayOfMonth; ++i )
	{
		x = xi * ( CalendarViewDayCellWidth + CalendarViewDayCellOffset );
		++xi;
		
		CalendarViewDayRect *dayRect = [[CalendarViewDayRect alloc] init];
		dayRect.day = i;
		dayRect.frame = CGRectMake(x, y, w, h);
		[dayRects addObject:dayRect];
		
		if( xi >= CalendarViewDaysInWeek )
		{
			xi = 0;
			++yi;
			y = yOffSet + yi * ( CalendarViewDayCellHeight + CalendarViewDayCellOffset );
		}
	}
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect( context, rect );
	
	CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
	CGContextFillRect( context, rect );
		
	NSDictionary *attributesBlack = [self generateAttributes:CalendarViewDefaultFont
												withFontSize:CalendarViewDayFontSize
												   withColor:[UIColor blackColor]
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	NSDictionary *attributesWhite = [self generateAttributes:CalendarViewDefaultFont
												withFontSize:CalendarViewDayFontSize
												   withColor:[UIColor whiteColor]
											   withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];

	NSDictionary *attributesRedRight = [self generateAttributes:CalendarViewDefaultFont
												   withFontSize:CalendarViewHeaderFontSize
													  withColor:[UIColor redColor]
												  withAlignment:NSTextAlignmentFromCTTextAlignment(kCTRightTextAlignment)];
	
	NSDictionary *attributesRedLeft = [self generateAttributes:CalendarViewDefaultFont
												  withFontSize:CalendarViewHeaderFontSize
													 withColor:[UIColor redColor]
												 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTLeftTextAlignment)];

	CTFontRef dayFont = CTFontCreateWithName( (CFStringRef)CalendarViewDefaultFont, CalendarViewDayFontSize, NULL );
	CGRect dayFontBoundingBox = CTFontGetBoundingBox( dayFont );
	
	NSString *year = [NSString stringWithFormat:@"%ld",(long)currentYear];
	const CGFloat yearNameX = ( CalendarViewDayCellWidth - CGRectGetHeight( dayFontBoundingBox ) ) * 0.5f;
	[year drawInRect:CGRectMake( yearNameX, 0, CalendarViewYearLabelWidth, CalendarViewYearLabelHeight ) withAttributes:attributesRedLeft];
	
	NSDateFormatter *formate = [NSDateFormatter new];
    NSArray *monthNames = [formate standaloneMonthSymbols];
    NSString *monthName = [monthNames objectAtIndex:( currentMonth - 1 )];
	const CGFloat monthNameX = ( CalendarViewDayCellWidth + CalendarViewDayCellOffset ) * CalendarViewDaysInWeek - CalendarViewMonthLabelWidth - ( CalendarViewDayCellWidth - CGRectGetHeight( dayFontBoundingBox ) );
	[monthName drawInRect:CGRectMake( monthNameX, 0, CalendarViewMonthLabelWidth, CalendarViewMonthLabelHeight ) withAttributes:attributesRedRight];
	
	[self drawWeekDays];
	
	for( CalendarViewDayRect *dayRect in dayRects )
	{
		NSDictionary *attrs = nil;
		
		if( dayRect.day == currentDay )
		{
			CGContextSetFillColorWithColor( context, [UIColor redColor].CGColor );
			CGContextFillEllipseInRect( context, dayRect.frame );
			
			attrs = attributesWhite;
		}
		else
		{
			attrs = attributesBlack;
		}
		
		const CGFloat h = CGRectGetHeight( dayRect.frame );
		const CGFloat w = CGRectGetWidth( dayRect.frame );
		const CGFloat x = dayRect.frame.origin.x;
		const CGFloat y = dayRect.frame.origin.y + ( ( h - CGRectGetHeight( dayFontBoundingBox ) ) * 0.5 );
		[self drawDay:dayRect.day inRect:CGRectMake( x, y, w, h ) withAttributes:attrs];
	}
}

- (void)drawDay:(const int)day inRect:(CGRect)rect withAttributes:(NSDictionary *)attrs
{
	NSString *str = [NSString stringWithFormat:@"%i",day];
	[str drawInRect:rect withAttributes:attrs];
}

- (void)drawWeekDays
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSArray *weekdayNames = [dateFormatter shortWeekdaySymbols];
	
	NSDictionary *attrs = [self generateAttributes:CalendarViewDefaultFont
									  withFontSize:CalendarViewDayFontSize
										 withColor:[UIColor blackColor]
									 withAlignment:NSTextAlignmentFromCTTextAlignment(kCTCenterTextAlignment)];
	
	CGFloat x = 0;
	CGFloat y = CalendarViewWeekDaysYOffset;
	const CGFloat w = CalendarViewDayCellWidth;
	const CGFloat h = CalendarViewDayCellHeight;
	
	for( int i = 1; i < CalendarViewDaysInWeek; ++i )
	{
		x = ( i - 1 ) * ( CalendarViewDayCellWidth + CalendarViewDayCellOffset );
		
		NSString *str = [NSString stringWithFormat:@"%@",[weekdayNames objectAtIndex:i]];
		[str drawInRect:CGRectMake(x, y, w, h) withAttributes:attrs];
	}
	
	NSString *strSunday = [NSString stringWithFormat:@"%@",[weekdayNames objectAtIndex:0]];
	x = ( CalendarViewDaysInWeek - 1 ) * ( CalendarViewDayCellWidth + CalendarViewDayCellOffset );
	[strSunday drawInRect:CGRectMake(x, y, w, h) withAttributes:attrs];
}

- (void)changeDateEvent
{
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setTimeZone:timeZone];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	[components setYear:currentYear];
	[components setMonth:currentMonth];
	[components setDay:currentDay];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setTimeZone:timeZone];
	
	NSDate *finalDate = [calendar dateFromComponents:components];
	if( _calendarDelegate && [_calendarDelegate respondsToSelector:@selector( didChangeCalendarDate: )] )
	{
		[_calendarDelegate didChangeCalendarDate:finalDate];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	
	for( CalendarViewDayRect *dayRect in dayRects )
	{
		if( CGRectContainsPoint( dayRect.frame, touchPoint ) )
		{
			currentDay = dayRect.day;
			[self changeDateEvent];
			[self generateDayRects];
			[self setNeedsDisplay];
			break;
		}
	}
}

- (void)leftSwipe
{
	if( currentMonth == CalendarViewMonthInYear )
	{
		currentMonth = 1;
		++currentYear;
	}
	else
	{
		++currentMonth;
	}
	
	[self changeDateEvent];
	[self swipeMonth];
}

- (void)rightSwipe
{
	if( currentMonth == 1 )
	{
		currentMonth = CalendarViewMonthInYear;
		--currentYear;
	}
	else
	{
		--currentMonth;
	}
	
	[self changeDateEvent];
	[self swipeMonth];
}

- (void)swipeMonth
{
	[UIView animateWithDuration:CalendarViewSwipeMonthFadeInTime
						  delay:0
						options:0
					 animations:^{
						 self.alpha = 0.0f;
					 }
					 completion:^( BOOL finished ) {
						 [self generateDayRects];
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

@end
