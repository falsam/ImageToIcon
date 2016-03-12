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
  #IconePreview
  #IconeSave
  
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

Global FileName.s, ImageSelect.i, ImageEdit.i, ImageIcone.i, IconeHandle.i, Zoom.i = 0

Declare Start()
Declare.f AjustFontSize(lPolice.l)
Declare ImageSelect()
Declare IconeCreate()
Declare IconeUpdate()
Declare IconePreview()
Declare IconeSave()
Declare Exit()

Start()

Procedure Start()
  Protected Image, Gadget
  
  UseModule Notify
  
  LoadFont(#FontGlobal, "Arial", AjustFontSize(9))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  OpenWindow(#MainForm, 0, 0, 470, 500, "ImageToIcone", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ;-Toolbar
  Image = CatchImage(#PB_Any, ?ImageSelect)
  ButtonImageGadgetNoSkin(#ImageOpen, 10, 20, 32, 32, ImageID(Image))
  GadgetToolTip(#ImageOpen, "Load image (PNG or JPEG)")
  
  Image = CatchImage(#PB_Any, ?IconePreview)
  ButtonImageGadgetNoSkin(#IconePreview, 50, 20, 32, 32, ImageID(Image))
  GadgetToolTip(#IconePreview, "View the result in the title of this window.")  
  DisableGadget(#IconePreview, #True)
  
  Image = CatchImage(#PB_Any, ?IconeSave)
  ButtonImageGadgetNoSkin(#IconeSave, 90, 20, 32, 32, ImageID(Image))
  GadgetToolTip(#IconeSave, "Create icone (ICO)")  
  DisableGadget(#IconeSave, #True)
  
  ;-Icone Size
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
      
  ;Preview
  FrameGadget(#PB_Any, 10, 170, 450, 300, "Preview")
  
  ;FileName
  TextGadget(#FileName, 10, 475, 300, 22, "")
  
  ;-Trigger
  BindEvent(#PB_Event_CloseWindow, @Exit())
  
  For Gadget = #Size16 To #Size256
    BindGadgetEvent(Gadget, @IconeCreate(), #PB_EventType_LeftClick)
  Next
  
  BindGadgetEvent(#ImageOpen, @ImageSelect(), #PB_EventType_LeftClick)
  BindGadgetEvent(#IconePreview, @IconePreview(), #PB_EventType_LeftClick)  
  BindGadgetEvent(#IconeSave, @IconeSave(), #PB_EventType_LeftClick)
    
  PostEvent(#PB_Event_Gadget, #MainForm, #Size48, #PB_EventType_LeftClick)
  
  ;-Notify
  Notify(#MainForm, "Information", "Chargez une image pour commencer." + #CRLF$ + #CRLF$ +
                                   "L'image doit avoir une des tailles défini dans cet utilitaire." ,#NIM_ADD)
 
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

Procedure.f AjustFontSize(Size.l)
  Define lPpp.l = GetDeviceCaps_(GetDC_(#Null), #LOGPIXELSX)
  ProcedureReturn (Size * 96) / lPpp
EndProcedure

Procedure ImageSelect()
  Protected Pattern.s  = "Image (*.bmp)|*.bmp|Image (*.png)|*.png|Image (*.jpg)|*.jpg"

  FileName.s = OpenFileRequester("Load Image ...", "", Pattern, 0)
  
  If FileName
    Zoom = 0
    ImageSelect = LoadImage(#PB_Any, FileName)
    IconeUpdate()   
    SetGadgetText(#FileName, FileName)
    DisableGadget(#IconePreview, #False)
    DisableGadget(#IconeSave, #False)
  EndIf 
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
  
  CanvasGadget(#Icone, 25, 195, Size, Size)
  IconeUpdate()  
EndProcedure

Procedure IconeUpdate()
  Protected x, y
  Protected Width = GadgetWidth(#Icone)
  Protected Height = GadgetHeight(#icone)
  Protected n.b
  
  If ImageSelect
    StartDrawing(CanvasOutput(#Icone))
    
    ;Transparent background
    Box(0, 0, Width, Height, RGBA(255, 255, 255, 255))
    For x = 0 To Width Step 8
      n!1
      For y = 0 To Height Step 16
        If n 
          Box(x, y, 8, 8, RGBA(204, 204, 204, 255))
        Else
          Box(x, y + 8 , 8, 8, RGBA(204, 204, 204, 255))
        EndIf           
      Next
    Next
    
    ;Image
    If IsImage(ImageEdit)
      FreeImage(ImageEdit)
    EndIf
    ImageEdit = CopyImage(ImageSelect, #PB_Any)
    ResizeImage(ImageEdit, Width, Height)
    
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(ImageEdit), (GadgetWidth(#Icone) - ImageWidth(ImageEdit))/2, (GadgetHeight(#Icone) - ImageHeight(ImageEdit))/2)
    
    StopDrawing()
    
    ;Icone Image
    ImageIcone  = CreateImage(#PB_Any, Width, Height, 32, #PB_Image_Transparent )
    StartDrawing(ImageOutput(ImageIcone))
    DrawingMode(#PB_2DDrawing_AllChannels)
    Box(0, 0, GadgetWidth(#Icone), GadgetHeight(#Icone), RGBA(255, 255, 255 , 0))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(ImageSelect), 0, 0, Width, Height)
    StopDrawing()
    
  EndIf
EndProcedure

Procedure IconePreview()
  IconeHandle = ImageToIco(ImageIcone)
  SetWindowIcon(#MainForm, IconeHandle)
  If Not GetGadgetData(#IconePreview)
    SetGadgetData(#IconePreview, #True)
    Notify(#MainForm, "Information", "l'icone est générée dans le coin haut gauche de cette application.", #NIM_MODIFY)
  EndIf
EndProcedure

Procedure IconeSave()  
  Protected ImageFolder.s = GetPathPart(FileName)
  Protected ImageName.s = StringField(GetFilePart(FileName), 1, ".") + ".ico"
    
  IconeHandle = ImageToIco(ImageIcone) 
  SaveIcon(IconeHandle, ImageFolder + ImageName )
  Notify(#MainForm, "Information", "Icone sauvegardée : " + ImageName, #NIM_MODIFY)
EndProcedure

Procedure Exit()  
  ;Delete icone if exist
  If IconeHandle
    DestroyIcon_(IconeHandle)
  EndIf
  
  End
EndProcedure

DataSection
  ImageSelect:
  IncludeBinary "image\imageselect.png"
  
  IconePreview: 
  IncludeBinary "image\preview.png"
    
  IconeSave: 
  IncludeBinary "image\iconesave.png"
      
EndDataSection
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 127
; FirstLine = 126
; Folding = --
; EnableUnicode
; EnableXP
; UseIcon = assets\image\icone.ico
; Executable = C:\Users\Eric\Desktop\ImageToIcone.exe