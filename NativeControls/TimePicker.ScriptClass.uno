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
	public partial class TimePickerBase
	{

		class CurrentTimeProperty : Property<string>
		{
			readonly TimePickerBase _tp;
			public override PropertyObject Object { get { return _tp; } }
			public override bool SupportsOriginSetter { get { return false; } }
			public override string Get(PropertyObject obj)
			{
				LocalTime time = ZonedDateTime.Now.TimeOfDay;
				lock (_tp)
					time = _tp._out;
				return ToJSON(time);
			}
			public override void Set(PropertyObject obj, string value, IPropertyListener origin)
			{
				var newTime = FromJSON(JsonReader.Parse(value));
				lock (_tp)
					_tp._in = newTime;
				UpdateManager.PostAction(_tp.UpdateCurrentTime);
			}
			public CurrentTimeProperty(TimePickerBase timePicker) : base(TimePickerBase._currentTimeName) { _tp = timePicker; }
		}

		static TimePickerBase()
		{
			ScriptClass.Register(typeof(TimePickerBase),
				new ScriptProperty<TimePickerBase, string>("CurrentTime", getCurrentTimeProperty, ".notNull().parseJson()"),
				new ScriptMethod<TimePickerBase>("setTime", setTime, ExecutionThread.MainThread));
		}

		CurrentTimeProperty _currentTimeProperty;
		static Property<string> getCurrentTimeProperty(TimePickerBase timePicker)
		{
			if (timePicker._currentTimeProperty == null)
				timePicker._currentTimeProperty = new CurrentTimeProperty(timePicker);

			return timePicker._currentTimeProperty;
		}

		static void setTime(Context context, TimePickerBase timePicker, object[] args)
		{
			if (args.Length < 1)
				throw new Fuse.Scripting.Error("To few arguments");

			var obj = args[0] as Fuse.Scripting.Object;
			if (obj == null)
				throw new Fuse.Scripting.Error("Argument must be an object with hour and minute");

			if (!obj.ContainsKey("hour"))
				throw new Fuse.Scripting.Error("hour missing from argument");

			if (!obj.ContainsKey("minute"))
				throw new Fuse.Scripting.Error("minute missing from argument");

			timePicker.CurrentTime = new LocalTime(
				Marshal.ToInt(obj["hour"]),
				Marshal.ToInt(obj["minute"]));
		}

		static string ToJSON(LocalTime localTime)
		{
			var hour = "\"hour\":" + localTime.Hour.ToString() + ",";
			var minute = "\"minute\":" + localTime.Minute.ToString();
			return "{" + hour + minute + "}";
		}

		static LocalTime FromJSON(JsonReader json)
		{
			var hour = (int)json["hour"].AsNumber();
			var minute = (int)json["minute"].AsNumber();
			return new LocalTime(hour, minute);
		}
	}
}