# FuseNativeControls

[![Build Status](https://travis-ci.org/nekronos/FuseNativeControls.svg?branch=master)](https://travis-ci.org/nekronos/FuseNativeControls)

This library provides cross-platform abstractions of native Android and iOS controls for [fuse](http://www.fusetools.com).

Implemented so far:
- DatePicker
- TimePicker

Example:

	<NativeViewHost>
		<Native.DatePicker ux:Name="datePicker">
			<JavaScript>
				var date = { year: 2018, month: 1, day: 13 };
				var minDate = { year: 2016, month: 1, day: 1 };
				var maxDate = { year: 2020, month: 1, day: 31 };

				datePicker.setDate(date);
				datePicker.setMaxDate(maxDate);
				datePicker.setMinDate(minDate);
				
				datePicker.CurrentDate.addSubscriber(function () {
					var d = datePicker.CurrentDate.value;
					console.log("Date changed: " + d["year"] + "-" + d["month"] + "-" + d["day"]);
				});

			</JavaScript>
		</Native.DatePicker>
	</NativeViewHost>
