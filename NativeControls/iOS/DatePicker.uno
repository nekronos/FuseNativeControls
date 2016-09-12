using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	[Require("Source.Include", "UIKit/UIKit.h")]
	extern(iOS) class DatePicker : 
		Fuse.Controls.Native.iOS.LeafView,
		IDatePickerView
	{

		IDatePickerHost _host;
		IDisposable _valueChangedEvent;

		public DatePicker(IDatePickerHost host) : base(Create())
		{
			_host = host;
			_valueChangedEvent = UIControlEvent.AddValueChangedCallback(Handle, OnDateChanged);
		}

		public override void Dispose()
		{
			base.Dispose();
			_valueChangedEvent.Dispose();
			_valueChangedEvent = null;
			_host = null;
		}

		void OnDateChanged(ObjC.Object sender, ObjC.Object args)
		{
			int year = 0;
			int month = 0;
			int day = 0;
			GetDate(Handle, out year, out month, out day);
			_host.OnDateChanged(new LocalDate(year, month, day));
		}

		LocalDate IDatePickerView.CurrentDate
		{
			get
			{
				int year = 0;
				int month = 0;
				int day = 0;
				GetDate(Handle, out year, out month, out day);
				return new LocalDate(year, month, day);
			}
		}
		
		void IDatePickerView.SetDate(LocalDate date)
		{
			SetDate(Handle, MakeNSDate(date.Year, date.Month, date.Day));
		}

		void IDatePickerView.SetMinDate(LocalDate date)
		{
			SetMinDate(Handle, MakeNSDate(date.Year, date.Month, date.Day));
		}

		void IDatePickerView.SetMaxDate(LocalDate date)
		{
			SetMaxDate(Handle, MakeNSDate(date.Year, date.Month, date.Day));
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