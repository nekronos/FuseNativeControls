using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	[Require("Source.Include", "UIKit/UIKit.h")]
	extern(iOS) class TimePickerView : Fuse.Controls.Native.iOS.LeafView
	{
		public LocalTime CurrentTime
		{
			get { return DateExtensions.GetLocalTime(Handle); }
			set { DateExtensions.SetTime(Handle, value); }
		}

		Action _onTimeChangedHandler;
		IDisposable _valueChangedEvent;

		public TimePickerView(Action onTimeChangedHandler) : base(Create())
		{
			_onTimeChangedHandler = onTimeChangedHandler;
			_valueChangedEvent = UIControlEvent.AddValueChangedCallback(Handle, OnTimeChanged);
		}

		public override void Dispose()
		{
			base.Dispose();
			_valueChangedEvent.Dispose();
			_onTimeChangedHandler = null;
		}

		void OnTimeChanged(ObjC.Object sender, ObjC.Object args)
		{
			_onTimeChangedHandler();
		}

		[Foreign(Language.ObjC)]
		static ObjC.Object Create()
		@{
			UIDatePicker* dp = [[UIDatePicker alloc] init];
			[dp setDatePickerMode:UIDatePickerModeTime];
			return dp;
		@}

	}
}