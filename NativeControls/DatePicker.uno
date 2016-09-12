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
	internal interface IDatePickerHost
	{
		void OnDateChanged(LocalDate date);
	}

	internal interface IDatePickerView
	{
		LocalDate CurrentDate { get; set; }
		LocalDate MinDate { set; }
		LocalDate MaxDate { set; }
	}
	
	internal class DummyDatePickerView : IDatePickerView
	{
		static DummyDatePickerView _instance;
		public static IDatePickerView Instance
		{
			get { return _instance ?? (_instance = new DummyDatePickerView()); }
		}

		LocalDate IDatePickerView.CurrentDate
		{
			get { return ZonedDateTime.Now.Date; }
			set { }
		}
		LocalDate IDatePickerView.MinDate { set { } }
		LocalDate IDatePickerView.MaxDate { set { } }
	}

	public partial class DatePicker : Panel, IDatePickerHost
	{
		static Selector _currentDateName = "CurrentDate";

		LocalDate CurrentDate
		{
			get { return DatePickerView.CurrentDate; }
			set { DatePickerView.CurrentDate = value; }
		}

		IDatePickerView DatePickerView
		{
			get { return (NativeView as IDatePickerView) ?? DummyDatePickerView.Instance; }
		}

		void IDatePickerHost.OnDateChanged(LocalDate date)
		{
			OnPropertyChanged(_currentDateName, null);
		}

		protected override IView CreateNativeView()
		{
			if defined(Android)
			{
				return new Native.Android.DatePicker(this);
			}
			else if defined(iOS)
			{
				return new Native.iOS.DatePicker(this);
			}
			else
			{
				return base.CreateNativeView();
			}
		}
	}
}