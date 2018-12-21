GWFontSize={}
GWFontSize.Tiny=16
GWFontSize.Small=32
GWFontSize.Medium=64
GWFontSize.Large=128
GWFontSize.Huge=256
surface.CreateFont("GWIcon" .. GWFontSize.Tiny,{font = "dripicons-v2",size = GWFontSize.Tiny,extended = true});
surface.CreateFont("GWIcon" .. GWFontSize.Small,{font = "dripicons-v2",size = GWFontSize.Small,extended = true});
surface.CreateFont("GWIcon" .. GWFontSize.Medium,{font = "dripicons-v2",size = GWFontSize.Medium,extended = true});
surface.CreateFont("GWIcon" .. GWFontSize.Large,{font = "dripicons-v2",size = GWFontSize.Large,extended = true});
surface.CreateFont("GWIcon" .. GWFontSize.Huge,{font = "dripicons-v2",size = GWFontSize.Huge,extended = true});
surface.CreateFont("GWDefault" .. GWFontSize.Tiny,{font = "Roboto",size = GWFontSize.Tiny});
surface.CreateFont("GWDefault" .. GWFontSize.Small,{font = "Roboto",size = GWFontSize.Small});
surface.CreateFont("GWDefault" .. GWFontSize.Medium,{font = "Roboto",size = GWFontSize.Medium});
surface.CreateFont("GWDefault" .. GWFontSize.Large,{font = "Roboto",size = GWFontSize.Large});
surface.CreateFont("GWDefault" .. GWFontSize.Huge,{font = "Roboto",size = GWFontSize.Huge});
include("vgui/cl_include.lua");
include("sh_init.lua");
include("cl_gamemode.lua");
