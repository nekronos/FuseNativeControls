using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	extern(iOS) static class DateExtensions
	{

		public static ObjC.Object ToNSDate(this LocalTime time)
		{
			return MakeNSDate(time.Hour, time.Minute, 0, 0, 0);
		}

		public static ObjC.Object ToNSDate(this LocalDate date)
		{
			return MakeNSDate(0, 0, date.Year, date.Month, date.Day);
		}

		[Foreign(Language.ObjC)]
		static ObjC.Object MakeNSDate(int hour, int minute, int year, int month, int day)
		@{
			NSDateComponents* components = [[NSDateComponents alloc] init];

			[components setHour:hour];
			[components setMinute:minute];
			[components setYear:year];
			[components setMonth:month];
			[components setDay:day];

            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDate* date = [calendar dateFromComponents:components];

			return date;
		@}

		public static LocalTime GetLocalTime(ObjC.Object datePicker)
		{
			int hour = 0, minute = 0, year = 0, month = 0, day = 0;
			GetDate(datePicker, out hour, out minute, out year, out month, out day);
			return new LocalTime(hour, minute);
		}

		public static LocalDate GetLocalDate(ObjC.Object datePicker)
		{
			int hour = 0, minute = 0, year = 0, month = 0, day = 0;
			GetDate(datePicker, out hour, out minute, out year, out month, out day);
			return new LocalDate(year, month, day);
		}

		[Foreign(Language.ObjC)]
		static void GetDate(ObjC.Object handle, out int hour, out int minute, out int year, out int month, out int day)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = [dp date];
			NSCalendar* calendar = [NSCalendar currentCalendar];
			NSDateComponents* components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; 

			*hour = (int)[components hour];
			*minute = (int)[components minute];
			*year = (int)[components year];
			*month = (int)[components month];
			*day = (int)[components day];
		@}

		public static void SetDate(ObjC.Object datePicker, LocalDate date)
		{
			SetDate(datePicker, date.ToNSDate());
		}

		public static void SetTime(ObjC.Object datePicker, LocalTime time)
		{
			SetDate(datePicker, time.ToNSDate());
		}

		public static void SetMinDate(ObjC.Object datePicker, LocalDate date)
		{
			SetMinDate(datePicker, date.ToNSDate());
		}

		public static void SetMaxDate(ObjC.Object datePicker, LocalDate date)
		{
			SetMaxDate(datePicker, date.ToNSDate());
		}

		[Foreign(Language.ObjC)]
		static void SetDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setDate:date animated:true];
		@}

		[Foreign(Language.ObjC)]
		static void SetMinDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setMinimumDate:date];
		@}

		[Foreign(Language.ObjC)]
		static void SetMaxDate(ObjC.Object handle, ObjC.Object nsDateHandle)
		@{
			UIDatePicker* dp = (UIDatePicker*)handle;
			NSDate* date = (NSDate*)nsDateHandle;
			[dp setMaximumDate:date];
		@}

	}

}
