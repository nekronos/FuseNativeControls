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

	public partial class DatePicker
	{

		class CurrentDateProperty : Property<string>
		{
			readonly DatePicker _dp;
			public override PropertyObject Object { get { return _dp; } }
			public override bool SupportsOriginSetter { get { return false; } }
			public override string Get() { return _dp.CurrentDate.ToJSON(); }
			public override void Set(string value, IPropertyListener origin) { _dp.CurrentDate = JsonReader.Parse(value).FromJSON(); }
			public CurrentDateProperty(DatePicker datePicker) : base(DatePicker._currentDateName) { _dp = datePicker; }
		}

		static DatePicker()
		{
			ScriptClass.Register(typeof(DatePicker),
				new ScriptProperty<DatePicker, string>("CurrentDate", getCurrentDateProperty, ".notNull().parseJson()"),
				new ScriptMethod<DatePicker>("setDate", setDate, ExecutionThread.MainThread),
				new ScriptMethod<DatePicker>("setMinDate", setMinDate, ExecutionThread.MainThread),
				new ScriptMethod<DatePicker>("setMaxDate", setMaxDate, ExecutionThread.MainThread));
		}
		
		CurrentDateProperty _currentDateProperty;
		static Property<string> getCurrentDateProperty(DatePicker datePicker)
		{
			if (datePicker._currentDateProperty == null)
				datePicker._currentDateProperty = new CurrentDateProperty(datePicker);

			return datePicker._currentDateProperty;
		}

		static void setDate(Context context, DatePicker datePicker, object[] args)
		{
			datePicker.CurrentDate = ArgsToLocalDate(args);
		}

		static void setMinDate(Context context, DatePicker datePicker, object[] args)
		{
			datePicker.MinDate = ArgsToLocalDate(args);
		}

		static void setMaxDate(Context context, DatePicker datePicker, object[] args)
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
			var year = json["year"].AsInteger();
			var month = json["month"].AsInteger();
			var day = json["day"].AsInteger();
			return new LocalDate(year, month, day);
		}

	}

}