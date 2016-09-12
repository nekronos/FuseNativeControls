using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	[Require("Source.Include", "UIKit/UIKit.h")]
	extern(iOS) class DatePickerView : Fuse.Controls.Native.iOS.LeafView
	{

		Action<LocalDate> _onDateChangedHandler;
		IDisposable _valueChangedEvent;

		public DatePickerView(Action<LocalDate> onDateChangedHandler) : base(Create())
		{
			_onDateChangedHandler = onDateChangedHandler;
			_valueChangedEvent = UIControlEvent.AddValueChangedCallback(Handle, OnDateChanged);
		}

		public override void Dispose()
		{
			base.Dispose();
			_valueChangedEvent.Dispose();
			_valueChangedEvent = null;
			_onDateChangedHandler = null;
		}

		void OnDateChanged(ObjC.Object sender, ObjC.Object args)
		{
			int year = 0;
			int month = 0;
			int day = 0;
			GetDate(Handle, out year, out month, out day);
			_onDateChangedHandler(new LocalDate(year, month, day));
		}

		public LocalDate CurrentDate
		{
			get
			{
				int year = 0;
				int month = 0;
				int day = 0;
				GetDate(Handle, out year, out month, out day);
				return new LocalDate(year, month, day);
			}
			set { SetDate(Handle, MakeNSDate(value.Year, value.Month, value.Day)); }
		}

		public LocalDate MinDate
		{
			set { SetMinDate(Handle, MakeNSDate(value.Year, value.Month, value.Day)); }
		}
		
		public LocalDate MaxDate
		{
			set { SetMaxDate(Handle, MakeNSDate(value.Year, value.Month, value.Day)); }
		}

		[Foreign(Language.ObjC)]
		static ObjC.Object Create()
		@{
			UIDatePicker* dp = [[UIDatePicker alloc] init];
			[dp setDatePickerMode:UIDatePickerModeDate];
			return dp;
		@}

		[Foreign(Language.ObjC)]
		void GetDate(ObjC.Object handle, out int year, out int month, out int day)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = [dp date];
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; 

			*year = (int)[components year];
			*month = (int)[components month];
			*day = (int)[components day];
		@}

		[Foreign(Language.ObjC)]
		ObjC.Object MakeNSDate(int year, int month, int day)
		@{
			NSDateComponents* components = [[NSDateComponents alloc] init];

			[components setYear:year];
			[components setMonth:month];
			[components setDay:day];

            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDate* date = [calendar dateFromComponents:components];
			[components release];

			return date;
		@}

		[Foreign(Language.ObjC)]
		void SetDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setDate:date animated:true];
		@}

		[Foreign(Language.ObjC)]
		void SetMinDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setMaximumDate:date];
		@}

		[Foreign(Language.ObjC)]
		void SetMaxDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setMinimumDate:date];
		@}

	}
		
}