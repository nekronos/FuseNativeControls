using Uno;
using Uno.Compiler.ExportTargetInterop;

namespace Native.iOS
{
	[Require("Source.Include", "UIKit/UIKit.h")]
	[Require("Source.Include", "iOS/UIControlEvent.h")]
	extern(iOS) class UIControlEvent : IDisposable
	{
		public static IDisposable AddValueChangedCallback(ObjC.Object uiControl, Action<ObjC.Object, ObjC.Object> handler)
		{
			return new UIControlEvent(uiControl, handler, extern<int>"(int)UIControlEventValueChanged");
		}

		ObjC.Object _handle;
		ObjC.Object _uiControl;
		readonly int _type;

		UIControlEvent(ObjC.Object uiControl, Action<ObjC.Object, ObjC.Object> handler, int type)
		{
			_handle = Create(uiControl, handler, type);
			_uiControl = uiControl;
			_type = type;
		}

		[Foreign(Language.ObjC)]
		static ObjC.Object Create(ObjC.Object uiControl, Action<ObjC.Object, ObjC.Object> handler, int type)
		@{
			UIControlEventProxy* h = [[UIControlEventProxy alloc] init];
			[h setCallback:handler];
			UIControl* control = (UIControl*)uiControl;
			[control addTarget:h action:@selector(action:forEvent:) forControlEvents:(UIControlEvents)type];
			return h;
		@}

		void IDisposable.Dispose()
		{
			RemoveHandler(_uiControl, _handle, _type);
			_handle = null;
			_uiControl = null;
		}

		[Foreign(Language.ObjC)]
		static void RemoveHandler(ObjC.Object uiControl, ObjC.Object eventHandler, int type)
		@{
			UIControlEventProxy* h = (UIControlEventProxy*)eventHandler;
			UIControl* control = (UIControl*)uiControl;
			[control removeTarget:h action:@selector(action:forEvent:) forControlEvents:(UIControlEvents)type];
		@}

	}
}
