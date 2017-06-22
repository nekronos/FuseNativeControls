using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.Android
{

	extern(!Android) class TimePickerView
	{
		[UXConstructor]
		public TimePickerView([UXParameter("Host")]ITimePickerHost host) { }
	}

	extern(Android) class TimePickerView : Fuse.Controls.Native.Android.LeafView, ITimePickerView
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

		ITimePickerHost _host;

		[UXConstructor]
		public TimePickerView([UXParameter("Host")]ITimePickerHost host) : base(Create())
		{
			_host = host;
			Init(Handle, OnTimeChanged);
		}

		void OnTimeChanged()
		{
			_host.OnTimeChanged();
		}

		public override void Dispose()
		{
			base.Dispose();
			_host = null;
		}

		[Foreign(Language.Java)]
		static void Init(Java.Object handle, Action timeChangedCallback)
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
			android.widget.TimePicker tp = (android.widget.TimePicker)handle;
			if (android.os.Build.VERSION.SDK_INT >= 23) {
				tp.setHour(hour);
				tp.setMinute(minute);
			} else {
				tp.setCurrentHour(hour);
				tp.setCurrentMinute(minute);
			}
		@}

		[Foreign(Language.Java)]
		static void GetTime(Java.Object handle, int[] time)
		@{
			android.widget.TimePicker tp = (android.widget.TimePicker)handle;
			if (android.os.Build.VERSION.SDK_INT >= 23) {
				time.set(0, tp.getHour());
				time.set(1, tp.getMinute());
			} else {
				time.set(0, tp.getCurrentHour());
				time.set(1, tp.getCurrentMinute());
			}
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