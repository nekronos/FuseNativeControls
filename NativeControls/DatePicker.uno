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

	interface IDatePickerView
	{
		LocalDate CurrentDate { get; set; }
		LocalDate MinDate { set; }
		LocalDate MaxDate { set; }
	}

	interface IDatePickerHost
	{
		void OnDateChanged();
	}

	public abstract partial class DatePickerBase : Panel, IDatePickerHost
	{
		static Selector _currentDateName = "CurrentDate";

		public LocalDate CurrentDate
		{
			get
			{
				var dpv = DatePickerView;
				return dpv != null
					? dpv.CurrentDate
					: ZonedDateTime.Now.Date;
			}
			set
			{
				var dpv = DatePickerView;
				if (dpv != null && dpv.CurrentDate != value)
				{
					dpv.CurrentDate = value;
					OnDateChanged();
				}
			}
		}

		public LocalDate MinDate
		{
			set
			{
				var dpv = DatePickerView;
				if (dpv != null)
					dpv.MinDate = value;
			}
		}

		public LocalDate MaxDate
		{
			set
			{
				var dpv = DatePickerView;
				if (dpv != null)
					dpv.MaxDate = value;
			}
		}

		IDatePickerView DatePickerView
		{
			get { return NativeView as IDatePickerView; }
		}

		LocalDate _out = ZonedDateTime.Now.Date;
		LocalDate _in = ZonedDateTime.Now.Date;

		void IDatePickerHost.OnDateChanged()
		{
			OnDateChanged();
		}

		internal void OnDateChanged()
		{
			lock(this)
				_out = CurrentDate;
			OnPropertyChanged(_currentDateName, null);
		}

		void UpdateCurrentDate()
		{
			lock(this)
				CurrentDate = _in;
		}

		protected override void OnRooted()
		{
			base.OnRooted();
			_out = CurrentDate;
			_in	= CurrentDate;
		}
	}
}