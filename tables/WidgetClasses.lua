WidgetClasses = {
    CBaseWidget = tonumber("780768", 16),
        CStaticWidget = tonumber("780F84", 16),
            CStaticTextWidget = tonumber("780EE4", 16),
            CProgressBarWidget = tonumber("780C20", 16),
        CButtonWidget = tonumber("780E5C", 16),
            CGfxButtonWidget = tonumber("780CD0", 16),
            CTextButtonWidget = tonumber("780DB0", 16),
        CContainerWidget = tonumber("78114C", 16),
            CProjectWidget = tonumber("780910", 16),
        CPureTooltipWidget = tonumber("780BB0", 16),
        CCustomWidget = tonumber("7810F8", 16),
}
WidgetClassChilds = {
	[WidgetClasses.CBaseWidget] = {
		WidgetClasses.CStaticWidget,
		WidgetClasses.CButtonWidget,
		WidgetClasses.CContainerWidget,
		WidgetClasses.CPureTooltipWidget,
		WidgetClasses.CCustomWidget,
	},
	[WidgetClasses.CStaticWidget] = {
		WidgetClasses.CStaticTextWidget,
		WidgetClasses.CProgressBarWidget,
	},
	[WidgetClasses.CButtonWidget] = {
		WidgetClasses.CGfxButtonWidget,
		WidgetClasses.CTextButtonWidget,
	},
	[WidgetClasses.CContainerWidget] = {
		WidgetClasses.CProjectWidget,
	},
}