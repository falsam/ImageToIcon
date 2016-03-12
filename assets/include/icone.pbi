;By Srod, RASHAD & Bisonte

Procedure ImageToIco(Image) ; Convert an image to an ico. Returns the icon handle. To free it use : DestroyIcon_(icoHnd)
  
  If Not IsImage(Image) : ProcedureReturn #False : EndIf
  
  Protected iinf.ICONINFO
  Protected icoHnd
  
  ; Fill the ICONINFO structure
  iinf\fIcon = 1
  iinf\hbmMask = ImageID(Image)
  iinf\hbmColor = ImageID(Image)
  
  ; Create the icon in memory
  icoHnd = CreateIconIndirect_(iinf)
  
  ProcedureReturn icoHnd
  
EndProcedure

Procedure ChangeIconSize(icoHnd, Size) ; Change size of icon To Size x Size
  If icoHnd
    icoHnd = CopyImage_(icoHnd, #IMAGE_ICON, Size, Size, #LR_COPYDELETEORG)
  EndIf
  ProcedureReturn icoHnd 
  
EndProcedure

Procedure SetWindowIcon(Window.i, IconHandle.i)
  SendMessage_(WindowID(Window), #WM_SETICON, #False, IconHandle)
EndProcedure

Procedure.i SaveIcon(hIcon, filename$)
  Protected result, iconinfo.ICONINFO, hbmMask, hbmColor
  Protected cbitmap.BITMAP, cwidth, cheight, cbitsperpixel, colorcount, colorplanes
  Protected mbitmap.BITMAP, mwidth, mheight, fIcon, xHotspot, yHotspot
  Protected file, imagebytecount, hdc, oldbitmap, mem, bytesinrow, temp
  Protected *bitmapinfo.BITMAPINFO
  ;Get information regarding the icon.
  If Not(GetIconInfo_(hIcon, iconinfo)) : ProcedureReturn 0 : EndIf ;Not a valid icon handle.
  fIcon=2-iconinfo\fIcon                                            ;icon = 1, cursor = 2,
  If fIcon=2                                                        ;Cursor.
    xHotspot=iconinfo\xHotspot
    yHotspot=iconinfo\yHotspot
  EndIf
  ;Allocate memory for a BITMAPINFO structure + a color table with 256 entries.
  *bitmapinfo = AllocateMemory(SizeOf(BITMAPINFO) + SizeOf(RGBQUAD)<<8)
  If *bitmapinfo = 0 : ProcedureReturn 0 :EndIf
  ;Get the mask (AND) bitmap, which, if the icon is B/W monochrome, contains the colour bitmap.
  hbmMask=iconinfo\hbmMask
  GetObject_(hbmMask, SizeOf(BITMAP),mbitmap)
  mwidth= mbitmap\bmWidth
  mheight= mbitmap\bmHeight
  ;Get the colour (XOR) bitmap.
  hbmColor=iconinfo\hbmColor
  
  If hbmColor
    GetObject_(hbmColor, SizeOf(BITMAP),cbitmap)
    cwidth= cbitmap\bmWidth
    cheight= cbitmap\bmHeight
    cbitsperpixel = cbitmap\bmBitsPixel
    If cbitsperpixel = 0 : cbitsperpixel = 1 : EndIf
    If cbitsperpixel < 8
      colorcount=Pow(2,cbitsperpixel) ;colorcount = 0 if 8 or more bpp.
    EndIf
    colorplanes=cbitmap\bmplanes
  Else ;Monochrome icon.
    cwidth= mwidth
    cheight= mheight/2
    cbitsperpixel = 1
    colorcount=2
    colorplanes=1
    mheight=cheight
  EndIf
  ;Ready to start creating the file.
  file=CreateFile(#PB_Any,filename$)
  If file
    ;Write the data.
    ;word = 0
    WriteWord(file,0)
    ;word = 1 for icon, 2 for cursor.
    WriteWord(file,ficon) ;1 for icon, 2 for cursor. 
                          ;word = number of icons in file.
    WriteWord(file,1)     ;***CHANGE IF EXTENDING CODE TO MORE THAN ONE ICON***
                          ;16 byte ICONDIRENTRY structure, one for each icon.
    WriteByte(file, cwidth)
    WriteByte(file, cheight)
    WriteByte(file, colorcount)
    WriteByte(file, 0) ;Reserved.
    If ficon=1         ;Icon.
      WriteWord(file, colorplanes) ;Should equal 1, -but just in case!
      WriteWord(file, cbitsperpixel) 
    Else ;Cursor.
      WriteWord(file, xhotspot) 
      WriteWord(file, yhotspot) 
    EndIf
    WriteLong(file,0) ;TEMPORARY! WE NEED TO RETURN WHEN WE KNOW THE EXACT QUANTITY.
                      ; Size of (InfoHeader + ANDbitmap + XORbitmap)  
    WriteLong(file,Loc(file)+4)  ;FilePos, where InfoHeader starts
                                 ;Now the image data in the form BITMAPINFOHEADER (40 bytes) + colour map for the colour bitmap
                                 ;+ bits of colour bitmap + bits of mask bitmap. Gulp! One for each icon.
                                 ;40 byte BITMAPINFOHEADER structure.
    imagebytecount=SizeOf(BITMAPINFOHEADER)
    WriteLong(file, imagebytecount) ;Should be 40.
    WriteLong(file, cwidth)
    WriteLong(file, cheight+mheight) ;Combined heights of colour + mask images.
    WriteWord(file, colorplanes)     ;Should equal 1, -but just in case!
    WriteWord(file, cbitsperpixel)
    WriteLong(file, 0) ;Compression.
    WriteLong(file, 0) ;Image size. Valid to set to zero if there's no compression.
    WriteLong(file, 0) ;Unused.
    WriteLong(file, 0) ;Unused.
    WriteLong(file, 0) ;Unused.
    WriteLong(file, 0) ;Unused.
                       ;Colour map. Only applies for <= 8 bpp.
    hdc=CreateCompatibleDC_(0) ;Needed in order to get the colour table.
    If hbmColor = 0            ;Monochrome icon.
      WriteLong(file, #Black)
      WriteLong(file, #White)
      imagebytecount+SizeOf(rgbquad)*2
    ElseIf cbitsperpixel<=8 ;Includes 1 bit non-monochrome icons.
                            ;Get colour table.
      temp=Pow(2,cbitsperpixel) 
      bytesinrow = SizeOf(rgbquad)*temp
      mem=AllocateMemory(bytesinrow)
      oldbitmap=SelectObject_(hdc, hbmColor)
      GetDIBColorTable_(hdc, 0, temp, mem)      
      WriteData(file, mem, bytesinrow) ;Write color table.
      FreeMemory(mem)
      SelectObject_(hdc, oldbitmap)
      imagebytecount+bytesinrow
    EndIf
    ;Now the colour image bits. We use GetDiBits_() for this.
    bytesinrow = (cwidth*cbitsperpixel+31)/32*4  ;Aligned to a 4-byte boundary.
    bytesinrow * cheight
    mem=AllocateMemory(bytesinrow)
    *bitmapinfo\bmiHeader\biSize=SizeOf(BITMAPINFOHEADER)
    *bitmapinfo\bmiHeader\biWidth=cwidth
    *bitmapinfo\bmiHeader\biPlanes=colorplanes
    *bitmapinfo\bmiHeader\biBitCount=cbitsperpixel
    If hbmColor
      *bitmapinfo\bmiHeader\biHeight=cheight
      GetDIBits_(hdc,hbmColor,0,cheight,mem,*bitmapinfo,#DIB_RGB_COLORS)
    Else ;Monochrome color image is the bottom half of the mask image.
      *bitmapinfo\bmiHeader\biHeight=2*cheight
      GetDIBits_(hdc,hbmMask,0,cheight,mem,*bitmapinfo,#DIB_RGB_COLORS)
    EndIf
    WriteData(file, mem, bytesinrow) 
    FreeMemory(mem)
    imagebytecount+bytesinrow
    ;Now the mask image bits. We use GetDiBits_() for this.
    bytesinrow = (mwidth+31)/32*4  ;Aligned to a 4-byte boundary.
    bytesinrow * mheight
    mem=AllocateMemory(bytesinrow)
    *bitmapinfo\bmiHeader\biWidth=mwidth
    *bitmapinfo\bmiHeader\biPlanes=1
    *bitmapinfo\bmiHeader\biBitCount=1
    If hbmColor
      *bitmapinfo\bmiHeader\biHeight=mheight
      GetDIBits_(hdc,hbmMask,0,mheight,mem,*bitmapinfo,#DIB_RGB_COLORS)
    Else
      *bitmapinfo\bmiHeader\biHeight=2*mheight
      GetDIBits_(hdc,hbmMask,mheight,mheight,mem,*bitmapinfo,#DIB_RGB_COLORS)
    EndIf
    WriteData(file, mem, bytesinrow) 
    FreeMemory(mem)
    imagebytecount+bytesinrow
    DeleteDC_(hdc)
    ;Finally, return to the field we missed out.
    FileSeek(file, 14)
    WriteLong(file, imagebytecount)
    CloseFile(file)
    result= 1 ;Signal everything is fine.
  Else
    result= 0
  EndIf
  DeleteObject_(hbmMask) ;These are copies created as a result of GetIconInfo_() and so require deleting.
  DeleteObject_(hbmColor)
  FreeMemory(*bitmapinfo)
  ProcedureReturn result
EndProcedure

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableUnicode
; EnableXP