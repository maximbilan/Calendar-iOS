ios_calendar
============

Calendar component based on iOS7 design.<br>
![alt tag](https://raw.github.com/maximbilan/ios_calendar/master/img/img4.png)
<br>
<b>How to use:</b>
<br>
Add to your project source files: <br>
<pre>
  CalendarView.h
  CalendarView.m
  NSDate+CalendarView.h
  NSDate+CalendarView.m
</pre>
You can add view in the Interface builder and set class to CalendarView or create in the code: <br>
<pre>
  CalendarView* cv = [[CalendarView alloc] initWithPosition:10.0 y:10.0];
  [self.view addSubview:cv];
</pre>
So, it's all, you should see the calendar view. <br>
This component was created for iphone/ipod resolution, for ipad it's works, but it looks really small, if it's necessary, you can playing with static constants in the CalendarView.m, and maybe in future, will be done the scaling.
<br>
This calendar has some modes: <br>
<pre>
typedef NS_ENUM(NSInteger, CalendarMode)
{
    CM_Default,
    CM_MonthsAndYears,
    CM_Years
};
</pre>
<i>Default</i> - there're days, months and years, the user can change monthes with help swipe gesture or pinch gesture for transitions in the calendar <br>
<i>MonthsAndYears</i> - available months and years <br>
<i>Years</i> - only years <br>
<br>
<b>How to handle changing date event: </b><br>
For this you should use CalendarViewDelegate protocol:
<pre>
@interface ViewController : UIViewController &#60;CalendarViewDelegate&#62;

@end
</pre>
And setup delegate: <br>
<pre>
self.calendarView.calendarDelegate = self;
</pre>

After that you should implement required method didChangeCalendarDate:
<pre>
- (void)didChangeCalendarDate:(NSDate *)date
{
    NSLog(@"didChangeCalendarDate:%@", date);
}
</pre>

For more details there're optional methods for other things: <br>
<pre>
@optional
- (void)didChangeCalendarDate:(NSDate *)date withType:(NSInteger)type withEvent:(NSInteger)event;
- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type;
</pre>
<br>
Also you can see more screenshots in the img folder from repository.
<br>

