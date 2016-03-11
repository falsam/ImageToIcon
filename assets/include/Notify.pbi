DeclareModule Notify  
  Declare Notify(Window, Title.s, Text.s, Message = #NIM_MODIFY)
EndDeclareModule

Module Notify
  ;// Private
    CompilerSelect #PB_Compiler_Processor
      
    CompilerCase #PB_Processor_x86
      Structure NOTIFYICONDATA_
        cbSize.l
        hwnd.i
        uId.l
        uFlags.l
        uCallbackMessage.l
        hIcon.i
        szTip.s{128}
        dwState.l
        dwStateMask.l
        szInfo.s{256}
        StructureUnion
          uTimeout.l
          uVersion.l
        EndStructureUnion
        szInfoTitle.s{64}
        dwInfoFlags.i
        guidItem.GUID
        hBalloonIcon.i
      EndStructure
      
    CompilerCase #PB_Processor_x64
      Structure NOTIFYICONDATA_
        cbSize.l
        PB_Alignment1.b[4]
        hWnd.i
        uID.l
        uFlags.l
        uCallbackMessage.l
        PB_Alignment2.b[4]
        hIcon.i
        szTip.s{128}
        dwState.l
        dwStateMark.l
        szInfo.s{256}
        StructureUnion
          uTimeout.l
          uVersion.l
        EndStructureUnion
        szInfoTitle.s{64}
        dwInfoFlags.l
        guidItem.GUID
        hBalloonIcon.i
      EndStructure
      
  CompilerEndSelect
  
  Global SysTrayInfo.NOTIFYICONDATA_
  
  ;// Public
  Procedure Notify(Window, Title.s, Message.s, Flags = #NIM_MODIFY)
    If OSVersion() >=#PB_OS_Windows_Vista
      SysTrayInfo\cbSize=SizeOf(NOTIFYICONDATA_)
    ElseIf OSVersion() >=#PB_OS_Windows_XP
      SysTrayInfo\cbSize=OffsetOf(NOTIFYICONDATA_\hBalloonIcon)
    ElseIf OSVersion() >=#PB_OS_Windows_2000
      SysTrayInfo\cbSize=OffsetOf(NOTIFYICONDATA_\guidItem)
    Else
      SysTrayInfo\cbSize=OffsetOf(NOTIFYICONDATA_\szTip) + SizeOf(NOTIFYICONDATA_\szTip)
    EndIf
    
    If SysTrayInfo\cbSize      
      SysTrayInfo\hwnd = WindowID(Window)
      SysTrayInfo\uFlags = #NIF_INFO
      SysTrayInfo\dwInfoFlags=#NIIF_NONE|#NIIF_INFO
      SysTrayInfo\dwState=#NIS_SHAREDICON      
    EndIf
    
    SysTrayInfo\szInfoTitle=Left(Title, 63)
    SysTrayInfo\szInfo=Left(Message, 255)
    
    ProcedureReturn Shell_NotifyIcon_(Flags, @SysTrayInfo)
  EndProcedure
EndModule
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 78
; FirstLine = 30
; Folding = -
; EnableUnicode
; EnableXP