EnableExplicit

IncludePath "assets"

XIncludeFile "include\icone.pbi"
XIncludeFile "include\notify.pbi"

Enumeration Font
  #FontGlobal  
EndEnumeration

Enumeration Window
  #MainForm
EndEnumeration

Enumeration Gadget  
  #ImageOpen
  #IconeSave
  #ZoomIn
  #ZoomOut
  
  #Size16
  #Size20
  #Size24
  #Size32
  #Size40
  
  #Size48
  #Size64
  #Size96
  #Size128
  #Size256
    
  #Icone
  
  #FileName
  
EndEnumeration

Global FileName.s, ImageSelect.i, ImageEdit.i, IconeHandle, Zoom.i = 0

Declare Start()
Declare ImageSelect()
Declare ImageZoom()
Declare IconeCreate()
Declare IconeUpdate()
Declare IconeSave()
Declare Exit()

Start()

Procedure Start()
  Protected Image, Gadget
  
  UseModule Notify
  
  LoadFont(#FontGlobal, "", 9)
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  OpenWindow(#MainForm, 0, 0, 470, 500, "Image2Icone", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ;Toolbar
  Image = CatchImage(#PB_Any, ?ImageSelect)
  ButtonImageGadgetNoSkin(#ImageOpen, 10, 20, 32, 32, ImageID(Image))
  GadgetToolTip(#ImageOpen, "Load image")
  
  Image = CatchImage(#PB_Any, ?IconeSave)
  ButtonImageGadgetNoSkin(#IconeSave, 50, 20, 32, 32, ImageID(Image))
  GadgetToolTip(#IconeSave, "Create icone (ICO)")  
  DisableGadget(#IconeSave, #True)
  
  ;Size
  FrameGadget(#PB_Any, 10, 60, 450, 100, "Size in Pixel")
  OptionGadget(#Size16,  20, 80, 70, 20, "16 x 16")
  OptionGadget(#Size20, 110, 80, 70, 20, "20 x 20")
  OptionGadget(#Size24, 200, 80, 70, 20, "24 x 24")
  OptionGadget(#Size32, 290, 80, 70, 20, "32 x 32")
  OptionGadget(#Size40, 380, 80, 70, 20, "40 x 40")
  
  OptionGadget(#Size48,  20, 105, 70, 20, "48 x 48")
  OptionGadget(#Size64, 110, 105, 70, 20, "64 x 64")
  OptionGadget(#Size96, 200, 105, 70, 20, "96 x 96")
  OptionGadget(#Size128, 290, 105, 70, 20, "128 x 128")
  OptionGadget(#Size256, 380, 105, 70, 20, "256 x 256")
  
  SetGadgetState(#Size48, #True) ;Default : Size 48
  
  ;Left SideBar
  Image = CatchImage(#PB_Any, ?IconeZoomIn)
  ButtonImageGadgetNoSkin(#ZoomIn, 10, 175, 32, 32, ImageID(Image))
  GadgetToolTip(#ZoomIn, "Zomm +")
  
  Image = CatchImage(#PB_Any, ?IconeZoomOut)
  ButtonImageGadgetNoSkin(#ZoomOut, 10, 215, 32, 32, ImageID(Image))
  GadgetToolTip(#ZoomOut, "Zomm -")
    
  ;Preview
  FrameGadget(#PB_Any, 45, 170, 415, 300, "Preview")
  
  ;FileName
  TextGadget(#FileName, 45, 475, 300, 22, "")
  
  ;Trigger
  BindEvent(#PB_Event_CloseWindow, @Exit())
  
  For Gadget = #Size16 To #Size256
    BindGadgetEvent(Gadget, @IconeCreate(), #PB_EventType_LeftClick)
  Next
  
  BindGadgetEvent(#ImageOpen, @ImageSelect(), #PB_EventType_LeftClick)
  BindGadgetEvent(#IconeSave, @IconeSave(), #PB_EventType_LeftClick)
  
  BindGadgetEvent(#ZoomIn, @ImageZoom(), #PB_EventType_LeftClick)
  BindGadgetEvent(#ZoomOut, @ImageZoom(), #PB_EventType_LeftClick)
    
  PostEvent(#PB_Event_Gadget, #MainForm, #Size48, #PB_EventType_LeftClick)
  
  Notify(#MainForm, "Information", "Chargez une image pour commencer.", #NIM_ADD)
  
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

Procedure ImageSelect()
  Protected Pattern.s  = "Image (*.png)|*.png|Image (*.jpg)|*.jpg"

  FileName.s = OpenFileRequester("Load Image ...", "", Pattern, 0)
  
  If FileName
    Zoom = 0
    ImageSelect = LoadImage(#PB_Any, FileName)
    ImageEdit = CopyImage(ImageSelect, #PB_Any)
    IconeUpdate()   
    SetGadgetText(#FileName, FileName)
    DisableGadget(#IconeSave, #False)
  EndIf 
EndProcedure

Procedure ImageZoom()
  Select EventGadget()
    Case #ZoomIn  : Zoom + 1
    Case #ZoomOut : Zoom - 1       
  EndSelect
  ImageEdit = CopyImage(ImageSelect, #PB_Any)
  ResizeImage(ImageEdit, ImageWidth(ImageEdit) + Zoom, ImageHeight(ImageEdit) + Zoom, #PB_Image_Smooth)
  IconeUpdate()
EndProcedure

Procedure IconeCreate()  
  Protected Size.i
  
  Select EventGadget()
    Case #Size16  : Size = 16
    Case #Size20  : Size = 20
    Case #Size24  : Size = 24
    Case #Size32  : Size = 32
    Case #Size40  : Size = 40  
    Case #Size48  : Size = 48  
    Case #Size64  : Size = 64  
    Case #Size96  : Size = 96  
    Case #Size128 : Size = 128  
    Case #Size256 : Size = 256  
  EndSelect
  
  CanvasGadget(#Icone, 55, 195, Size, Size)
  IconeUpdate()  
EndProcedure

Procedure IconeUpdate()
  If ImageEdit
    StartDrawing(CanvasOutput(#Icone))
    DrawingMode(#PB_2DDrawing_AllChannels)
    Box(0, 0, GadgetWidth(#Icone), GadgetHeight(#Icone), RGBA(255, 255, 255, 0))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    
    DrawImage(ImageID(ImageEdit), (GadgetWidth(#Icone) - ImageWidth(ImageEdit))/2, (GadgetHeight(#Icone) - ImageHeight(ImageEdit))/2)
    StopDrawing()
  EndIf
EndProcedure

Procedure IconeSave()
  Protected ImgId  = GetGadgetAttribute(#Icone, #PB_Canvas_Image)
  Protected Width  = GadgetWidth(#Icone)
  Protected Height = GadgetHeight(#Icone)
  Protected Image = CreateImage(#PB_Any, Width, Height)
  
  Protected ImageFolder.s = GetPathPart(FileName)
  Protected ImageName.s = StringField(GetFilePart(FileName), 1, ".") + ".ico"
  
  StartDrawing(ImageOutput(Image))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, GadgetWidth(#Icone), GadgetHeight(#Icone), RGBA(255, 255, 255, 0))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImgId, 0, 0, Width, Height)
  StopDrawing()
  
  IconeHandle = PngToIco(Image) 
  SetWindowIcon(#MainForm, IconeHandle)
  SaveIcon(IconeHandle, ImageFolder + ImageName )
  Notify(#MainForm, "Information", "Icone sauvegardée : " + ImageName + #CRLF$, #NIM_MODIFY)
EndProcedure

Procedure Exit()
  If IconeHandle
    DestroyIcon_(IconeHandle)
  EndIf
  
  End
EndProcedure

DataSection
  ImageSelect:
  IncludeBinary "image\imageselect.png"
    
  IconeSave: 
  IncludeBinary "image\iconesave.png"
  
  IconeZoomIn:
  IncludeBinary "image\zoom-in.png"
  
  IconeZoomOut:
  IncludeBinary "image\zoom-Out.png"
    
EndDataSection
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 183
; FirstLine = 170
; Folding = --
; EnableUnicode
; EnableXP
; UseIcon = assets\image\icone.ico
; Executable = C:\Users\Eric\Desktop\ImageToIcone.exe