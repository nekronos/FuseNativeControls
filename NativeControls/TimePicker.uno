using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Scripting;

namespace Native
{
	using iOS;
	using Android;

	extern(!iOS && !Android) class TimePickerView
	{
		public LocalTime CurrentTime
		{
			get { return ZonedDateTime.Now.TimeOfDay; }
			set { }
		}

		public TimePickerView(Action<LocalTime> handler) { }
	}

	public partial class TimePicker : Panel
	{

		static Selector _currentTimeName = "CurrentTime";

		public LocalTime CurrentTime
		{
			get { return TimePickerView.CurrentTime; }
			set
			{
				if (TimePickerView.CurrentTime != value)
				{
					TimePickerView.CurrentTime = value;
					OnTimeChanged();
				}
			}
		}

		TimePickerView _timePickerView;
		TimePickerView TimePickerView
		{
			get
			{
				if (_timePickerView == null)
				{
					_timePickerView = new TimePickerView(OnTimeChanged);
					_out = CurrentTime;
					_in = CurrentTime;
				}

				return _timePickerView;
			}
		}

		LocalTime _out;
		LocalTime _in;

		void OnTimeChanged()
		{
			lock(this)
				_out = CurrentTime;
			OnPropertyChanged(_currentTimeName, null);
		}

		void UpdateCurrentTime()
		{
			lock(this)
				CurrentTime = _in;
		}

		protected override void OnUnrooted()
		{
			base.OnUnrooted();
			_timePickerView = null;
		}

		protected override IView CreateNativeView()
		{
			if defined(Android || iOS)
			{
				return TimePickerView;	
			}
			else
			{
				return base.CreateNativeView();
			}
		}
	}

}