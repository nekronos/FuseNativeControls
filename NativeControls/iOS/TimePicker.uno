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
			get
			{
				return new LocalTime(0,0);
			}
			set {  }
		}

		Action<LocalTime> _onTimeChangedHandler;

		public TimePickerView(Action<LocalTime> onTimeChangedHandler) : base(Create())
		{
			_onTimeChangedHandler = onTimeChangedHandler;
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