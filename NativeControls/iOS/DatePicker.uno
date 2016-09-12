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
			_onDateChangedHandler(CurrentDate);
		}

		public LocalDate CurrentDate
		{
			get { return DateExtensions.GetLocalDate(Handle); }
			set { DateExtensions.SetDate(Handle, value); }
		}

		public LocalDate MinDate
		{
			set { DateExtensions.SetMinDate(Handle, value); }
		}
		
		public LocalDate MaxDate
		{
			set { DateExtensions.SetMaxDate(Handle, value); }
		}

		[Foreign(Language.ObjC)]
		static ObjC.Object Create()
		@{
			UIDatePicker* dp = [[UIDatePicker alloc] init];
			[dp setDatePickerMode:UIDatePickerModeDate];
			return dp;
		@}
	}
		
}