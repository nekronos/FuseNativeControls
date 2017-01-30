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

	interface ITimePickerView
	{
		LocalTime CurrentTime { get; set; }
	}

	interface ITimePickerHost
	{
		void OnTimeChanged();
	}

	public abstract partial class TimePickerBase : Panel, ITimePickerHost
	{

		static Selector _currentTimeName = "CurrentTime";

		public LocalTime CurrentTime
		{
			get
			{
				var tpv = TimePickerView;
				return tpv != null
					? tpv.CurrentTime
					: ZonedDateTime.Now.TimeOfDay;
			}
			set
			{
				var tpv = TimePickerView;
				if (tpv != null && tpv.CurrentTime != value)
				{
					tpv.CurrentTime = value;
					OnTimeChanged();
				}
			}
		}

		ITimePickerView TimePickerView
		{
			get { return NativeView as ITimePickerView; }
		}

		LocalTime _out = ZonedDateTime.Now.TimeOfDay;
		LocalTime _in = ZonedDateTime.Now.TimeOfDay;

		void ITimePickerHost.OnTimeChanged()
		{
			OnTimeChanged();
		}

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

		protected override void OnRooted()
		{
			base.OnRooted();
			_out = CurrentTime;
			_in = CurrentTime;
		}
	}
}
