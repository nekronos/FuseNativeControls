using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.Android
{
	extern(Android) class TimePickerView : Fuse.Controls.Native.Android.LeafView
	{
		public LocalTime CurrentTime
		{
			get
			{
				var hm = new int[2];
				GetTime(Handle, hm);
				return new LocalTime(hm[0], hm[1]);
			}
			set { SetTime(Handle, value.Hour, value.Minute); }
		}

		Action _onTimeChangedHandler;

		public TimePickerView(Action onTimeChangedHandler) : base(Create())
		{
			_onTimeChangedHandler = onTimeChangedHandler;
			Init(Handle, OnTimeChanged);
		}

		void OnTimeChanged()
		{
			_onTimeChangedHandler();
		}

		[Foreign(Language.Java)]
		static void Init(Java.Object handle, Action<int, int> timeChangedCallback)
		@{
			((android.widget.TimePicker)handle).setOnTimeChangedListener(new android.widget.TimePicker.OnTimeChangedListener() {
				public void onTimeChanged(android.widget.TimePicker view, int hourOfDay, int minute) {
					timeChangedCallback.run();
				}
			});
		@}

		[Foreign(Language.Java)]
		static void SetTime(Java.Object handle, int hour, int minute)
		@{
			((android.widget.TimePicker)handle).setHour(hour);
			((android.widget.TimePicker)handle).setMinute(minute);
		@}

		[Foreign(Language.Java)]
		static void GetTime(Java.Object handle, int[] time)
		@{
			time.set(0, ((android.widget.TimePicker)handle).getHour());
			time.set(1, ((android.widget.TimePicker)handle).getMinute());
		@}

		[Foreign(Language.Java)]
		static Java.Object Create()
		@{
			android.widget.TimePicker timePicker = new android.widget.TimePicker(@(Activity.Package).@(Activity.Name).GetRootActivity());
			timePicker.setIs24HourView(true);
			return timePicker;
		@}

	}

}