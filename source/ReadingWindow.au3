#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>

; get height of window title and width of window frame - may be different when XP theme is ON/OFF
Global $htit = _WinAPI_GetSystemMetrics($SM_CYCAPTION)
Global $frame = _WinAPI_GetSystemMetrics($SM_CXDLGFRAME)
Global $x, $y

; this defines the

Global $hole_width = IniRead ( "defaults.ini", "values", "hole_width", "700" )
Global $hole_height = IniRead ( "defaults.ini", "values", "hole_height", "25" )

Global $offset_horizontal = 50
Global $offset_vertical = 75

Global $hole_x_start = $offset_horizontal
Global $hole_y_start = $offset_vertical


Local $gui = GUICreate("OSR", $hole_width + 2*$offset_horizontal, $hole_height + 2*$offset_vertical, -1, -1, $WS_POPUP, $WS_EX_TOPMOST)

GUISetState(@SW_SHOW)

Local $pos = WinGetPos($gui) ; get whole window size (no client size defined in GUICreate)
Global $width = $pos[2]
Global $height = $pos[3]

Global $hotkeys = 0
Global $visible = 1
Global $version = 1

Local $msg, $rgn

	; end program
    HotKeySet("{Esc}", $GUI_EVENT_CLOSE)
	HotKeySet("+{Esc}", "Terminate")
	HotKeySet("!{r}", "toggleVisible")
	
	; hotkey control
	HotKeySet("+{BS}", "toggleHots")

	; GUISetBkColor(0xE0FF0F)
	
	toggleHots()
	
	; TODO: check for update
	; $iversion = InetRead ( "http://chrishammerschmidt.de/update.ini" )
	; if ($iversion > $version) Then
	; EndIf
	
	; main loop
	While 1
		GetPos()
		If GUIGetMsg() = $GUI_EVENT_CLOSE  Then
			Terminate()
	EndIf
 
WEnd

; quit program 
Func Terminate()
	IniWrite ( "defaults.ini", "values", "hole_width", $hole_width )
	IniWrite ( "defaults.ini", "values", "hole_height", $hole_height )
	Exit 0
EndFunc

; toggle visibility
Func toggleVisible()

	If $visible == 0 Then
		WinSetState("OSR", "",  @SW_SHOW)
		$visible = 1
	else
		WinSetState("OSR", "" , @SW_HIDE)
		$visible = 0
	EndIf

EndFunc

;; movement functions
; up
Func movu()
	$a = _WinAPI_GetCursorInfo()
	MouseMove($a[3], $a[4]-Round(0.5* $hole_height))
EndFunc

; down
Func movd()
	$a = _WinAPI_GetCursorInfo()
	MouseMove($a[3], $a[4]+Round(0.5* $hole_height))
EndFunc

; left
Func movl()
	$a = _WinAPI_GetCursorInfo()
	MouseMove($a[3]-Round(0.5* $hole_height), $a[4])
EndFunc

; right
Func movr()
	$a = _WinAPI_GetCursorInfo()
	MouseMove($a[3]+Round(0.5* $hole_height), $a[4])
EndFunc

;; size functions
; horizontal increase
Func inch()
	$hole_width += 10
	$width+=10
EndFunc

; horizonzal decrease
Func dech()
	$hole_width -= 10
	$width-=10
EndFunc

; vertical increase
Func incv()
	$hole_height += 10
	$height+=10
EndFunc

; vertical decrease
Func decv()
	$hole_height -= 10
	$height-=10
EndFunc

;; toggle hotkeys

Func toggleHots()
	
	If $hotkeys == 0 Then
		; resize hole
		HotKeySet("+{RIGHT}", "inch")
		HotKeySet("+{LEFT}", "dech")
		HotKeySet("+{UP}", "incv")
		HotKeySet("+{DOWN}", "decv")
		
		; move window
		HotKeySet("{UP}", "movu")
		HotKeySet("{DOWN}", "movd")	
		HotKeySet("{RIGHT}", "movr")
		HotKeySet("{LEFT}", "movl")
		
		; recolor
		
		; set hotkeytoggle
		$hotkeys = 1
	Else
		; resize hole
		HotKeySet("+{RIGHT}")
		HotKeySet("+{LEFT}")
		HotKeySet("+{UP}")
		HotKeySet("+{DOWN}")
		
		; move window
		HotKeySet("{UP}")
		HotKeySet("{DOWN}")	
		HotKeySet("{RIGHT}") 
		HotKeySet("{LEFT}")

		; unset hotkeytoggle
		$hotkeys = 0
	EndIf
EndFunc

; make inner transparent area but add controls
Func _GuiHole($h_win, $i_x, $i_y, $i_sizew, $i_sizeh)
    Local $outer_rgn, $inner_rgn, $combined_rgn

    $outer_rgn = _WinAPI_CreateRectRgn(0, 0, $width, $height)
    $inner_rgn = _WinAPI_CreateRectRgn($i_x, $i_y, $i_x + $i_sizew, $i_y + $i_sizeh)
    $combined_rgn = _WinAPI_CreateRectRgn(0, 0, 0, 0)
    _WinAPI_CombineRgn($combined_rgn, $outer_rgn, $inner_rgn, $RGN_DIFF)
    _WinAPI_DeleteObject($outer_rgn)
    _WinAPI_DeleteObject($inner_rgn)
    _WinAPI_SetWindowRgn($h_win, $combined_rgn)
EndFunc   ;==>_GuiHole

; add control's area to given region
; respecting also window title/frame sizes
Func _AddCtrlRegion($full_rgn, $ctrl_id)
    Local $ctrl_pos, $ctrl_rgn

    $ctrl_pos = ControlGetPos($gui, "", $ctrl_id)
    $ctrl_rgn = _WinAPI_CreateRectRgn($ctrl_pos[0] + $frame, $ctrl_pos[1] + $htit + $frame, _
            $ctrl_pos[0] + $ctrl_pos[2] + $frame, $ctrl_pos[1] + $ctrl_pos[3] + $htit + $frame)
    _WinAPI_CombineRgn($full_rgn, $full_rgn, $ctrl_rgn, $RGN_OR)
    _WinAPI_DeleteObject($ctrl_rgn)
EndFunc   ;==>_AddCtrlRegion

Func GetPos()
    Local $a

	$a = _WinAPI_GetCursorInfo()
	
	;If NOT($a[3]<>$x) Then
		WinMove("OSR", "", $a[3]+10, $a[4]-1, $width, $height)
	;EndIf
	
	$x = $a[3]
	$y = $a[4]
	_GuiHole($gui, $hole_x_start, $hole_y_start, $hole_width, $hole_height)
EndFunc   ;==>GetPos
