using Uno;
using Uno.Text;
using Uno.Data.Json;
using Uno.UX;
using Uno.Time;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Scripting;

namespace Native
{

	public partial class DatePickerBase
	{
		class CurrentDateProperty : Property<string>
		{
			readonly DatePickerBase _dp;
			public override PropertyObject Object { get { return _dp; } }
			public override bool SupportsOriginSetter { get { return false; } }
			public override string Get(PropertyObject obj)
			{
				LocalDate date = ZonedDateTime.Now.Date;
				lock(_dp)
					date = _dp._out;
				return date.ToJSON();
			}
			public override void Set(PropertyObject obj, string value, IPropertyListener origin)
			{
				var date = JsonReader.Parse(value).FromJSON();
				lock(_dp)
					_dp._in = date;
				UpdateManager.PostAction(_dp.UpdateCurrentDate);
			}
			public CurrentDateProperty(DatePickerBase datePicker) : base(DatePickerBase._currentDateName) { _dp = datePicker; }
		}

		static DatePickerBase()
		{
			ScriptClass.Register(typeof(DatePickerBase),
				new ScriptProperty<DatePickerBase, string>("CurrentDate", getCurrentDateProperty, ".notNull().parseJson()"),
				new ScriptMethod<DatePickerBase>("setDate", setDate, ExecutionThread.MainThread),
				new ScriptMethod<DatePickerBase>("setMinDate", setMinDate, ExecutionThread.MainThread),
				new ScriptMethod<DatePickerBase>("setMaxDate", setMaxDate, ExecutionThread.MainThread));
		}

		CurrentDateProperty _currentDateProperty;
		static Property<string> getCurrentDateProperty(DatePickerBase datePicker)
		{
			if (datePicker._currentDateProperty == null)
				datePicker._currentDateProperty = new CurrentDateProperty(datePicker);

			return datePicker._currentDateProperty;
		}

		static void setDate(Context context, DatePickerBase datePicker, object[] args)
		{
			datePicker.CurrentDate = ArgsToLocalDate(args);
		}

		static void setMinDate(Context context, DatePickerBase datePicker, object[] args)
		{
			datePicker.MinDate = ArgsToLocalDate(args);
		}

		static void setMaxDate(Context context, DatePickerBase datePicker, object[] args)
		{
			datePicker.MaxDate = ArgsToLocalDate(args);
		}

		static LocalDate ArgsToLocalDate(object[] args)
		{
			if (args.Length < 1)
				throw new Fuse.Scripting.Error("Missing argument");

			var obj = args[0] as Fuse.Scripting.Object;
			if (obj == null)
				throw new Fuse.Scripting.Error("Argument must be an object with year, month and date");

			if (!obj.ContainsKey("year"))
				throw new Fuse.Scripting.Error("year missing from argument");

			if (!obj.ContainsKey("month"))
				throw new Fuse.Scripting.Error("month missing from argument");

			if (!obj.ContainsKey("day"))
				throw new Fuse.Scripting.Error("day missing from argument");

			return new LocalDate(
				Marshal.ToInt(obj["year"]),
				Marshal.ToInt(obj["month"]),
				Marshal.ToInt(obj["day"]));
		}

	}

	internal static class DateExtensions
	{
		public static string ToJSON(this LocalDate localDate)
		{
			var year = "\"year\":" + localDate.Year.ToString() + ",";
			var month = "\"month\":" + localDate.Month.ToString() + ",";
			var day = "\"day\":" + localDate.Day.ToString();
			return "{" + year + month + day + "}";
		}

		public static LocalDate FromJSON(this JsonReader json)
		{
			var year = (int)json["year"].AsNumber();
			var month = (int)json["month"].AsNumber();
			var day = (int)json["day"].AsNumber();
			return new LocalDate(year, month, day);
		}

	}

}