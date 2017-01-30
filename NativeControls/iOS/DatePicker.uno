using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	extern(!iOS) class DatePickerView
	{
		[UXConstructor]
		public DatePickerView([UXParameter("Host")]IDatePickerHost host) { }
	}

	[Require("Source.Include", "UIKit/UIKit.h")]
	extern(iOS) class DatePickerView : Fuse.Controls.Native.iOS.LeafView, IDatePickerView
	{

		IDatePickerHost _host;
		IDisposable _valueChangedEvent;

		[UXConstructor]
		public DatePickerView([UXParameter("Host")]IDatePickerHost host) : base(Create())
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
			_host.OnDateChanged();
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