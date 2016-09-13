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
	public partial class TimePicker
	{

		class CurrentTimeProperty : Property<string>
		{
			readonly TimePicker _tp;
			public override PropertyObject Object { get { return _tp; } }
			public override bool SupportsOriginSetter { get { return false; } }
			public override string Get()
			{
				LocalTime time = ZonedDateTime.Now.TimeOfDay;
				lock (_tp)
					time = _tp._out;
				return ToJSON(time);
			}
			public override void Set(string value, IPropertyListener origin)
			{
				var newTime = FromJSON(JsonReader.Parse(value));
				lock (_tp)
					_tp._in = newTime;
				UpdateManager.PostAction(_tp.UpdateCurrentTime);
			}
			public CurrentTimeProperty(TimePicker timePicker) : base(TimePicker._currentTimeName) { _tp = timePicker; }
		}

		static TimePicker()
		{
			ScriptClass.Register(typeof(TimePicker),
				new ScriptProperty<TimePicker, string>("CurrentTime", getCurrentTimeProperty, ".notNull().parseJson()"),
				new ScriptMethod<TimePicker>("setTime", setTime, ExecutionThread.MainThread));
		}
		
		CurrentTimeProperty _currentTimeProperty;
		static Property<string> getCurrentTimeProperty(TimePicker timePicker)
		{
			if (timePicker._currentTimeProperty == null)
				timePicker._currentTimeProperty = new CurrentTimeProperty(timePicker);

			return timePicker._currentTimeProperty;
		}

		static void setTime(Context context, TimePicker timePicker, object[] args)
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
			var hour = json["hour"].AsInteger();
			var minute = json["minute"].AsInteger();
			return new LocalTime(hour, minute);
		}
	}
}