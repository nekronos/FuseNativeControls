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

	extern(!iOS && !Android) class DatePickerView
	{
		public LocalDate CurrentDate
		{
			get { return ZonedDateTime.Now.Date; }
			set { }
		}
		public LocalDate MinDate { set { } }
		public LocalDate MaxDate { set { } }
		public DatePickerView(Action<LocalDate> handler) { }
	}

	public partial class DatePicker : Panel
	{
		static Selector _currentDateName = "CurrentDate";

		public LocalDate CurrentDate
		{
			get { return DatePickerView.CurrentDate; }
			set { DatePickerView.CurrentDate = value; }
		}

		public LocalDate MinDate
		{
			set { DatePickerView.MinDate = value; }
		}

		public LocalDate MaxDate
		{
			set { DatePickerView.MaxDate = value; }
		}	

		DatePickerView _datePickerView;
		DatePickerView DatePickerView
		{
			get
			{
				if (_datePickerView == null)
					_datePickerView = new DatePickerView(OnDateChanged);
					
				return _datePickerView;
			}
		}

		internal void OnDateChanged(LocalDate date)
		{
			OnPropertyChanged(_currentDateName, null);
		}

		protected override void OnUnrooted()
		{
			base.OnUnrooted();
			_datePickerView = null;
		}

		protected override IView CreateNativeView()
		{
			if defined(Android || iOS)
			{
				return (IView)DatePickerView;
			}
			else
			{
				return base.CreateNativeView();
			}
		}
	}
}