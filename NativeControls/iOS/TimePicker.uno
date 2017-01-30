using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.iOS
{
	extern(!iOS) class TimePickerView
	{
		[UXConstructor]
		public TimePickerView([UXParameter("Host")]ITimePickerHost host) { }
	}

	[Require("Source.Include", "UIKit/UIKit.h")]
	extern(iOS) class TimePickerView : Fuse.Controls.Native.iOS.LeafView, ITimePickerView
	{
		public LocalTime CurrentTime
		{
			get { return DateExtensions.GetLocalTime(Handle); }
			set { DateExtensions.SetTime(Handle, value); }
		}

		ITimePickerHost _host;
		IDisposable _valueChangedEvent;

		[UXConstructor]
		public TimePickerView([UXParameter("Host")]ITimePickerHost host) : base(Create())
		{
			_host = host;
			_valueChangedEvent = UIControlEvent.AddValueChangedCallback(Handle, OnTimeChanged);
		}

		public override void Dispose()
		{
			base.Dispose();
			_valueChangedEvent.Dispose();
			_host = null;
		}

		void OnTimeChanged(ObjC.Object sender, ObjC.Object args)
		{
			_host.OnTimeChanged();
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