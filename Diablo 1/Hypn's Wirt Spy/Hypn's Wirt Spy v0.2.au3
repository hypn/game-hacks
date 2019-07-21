; memory functions from: https://web.archive.org/web/20101007071335/http://www.edgeofnowhere.cc/viewtopic.php?t=346148

Func _MemRead($i_hProcess, $i_lpBaseAddress, $i_nSize, $v_lpNumberOfBytesRead = '')
	Local $v_Struct = DllStructCreate ('byte[' & $i_nSize & ']')
	DllCall('kernel32.dll', 'int', 'ReadProcessMemory', 'int', $i_hProcess, 'int', $i_lpBaseAddress, 'int', DllStructGetPtr ($v_Struct, 1), 'int', $i_nSize, 'int', $v_lpNumberOfBytesRead)
	Local $v_Return = DllStructGetData ($v_Struct, 1)
	$v_Struct=0
	Return $v_Return
EndFunc ;==> _MemRead()

Func _MemWrite($i_hProcess, $i_lpBaseAddress, $v_Inject, $i_nSize, $v_lpNumberOfBytesRead = '')
	Local $v_Struct = DllStructCreate ('byte[' & $i_nSize & ']')
	DllStructSetData ($v_Struct, 1, $v_Inject)
	$i_Call = DllCall('kernel32.dll', 'int', 'WriteProcessMemory', 'int', $i_hProcess, 'int', $i_lpBaseAddress, 'int', DllStructGetPtr ($v_Struct, 1), 'int', $i_nSize, 'int', $v_lpNumberOfBytesRead)
	$v_Struct=0
	Return $i_Call[0]
EndFunc ;==> _MemWrite()

Func _MemOpen($i_dwDesiredAccess, $i_bInheritHandle, $i_dwProcessId)
	$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', $i_dwDesiredAccess, 'int', $i_bInheritHandle, 'int', $i_dwProcessId)
	If @error Then
		SetError(1)
		Return 0
	EndIf
	Return $ai_Handle[0]
EndFunc ;==> _MemOpen()

Func _MemClose($i_hProcess)
	$av_CloseHandle = DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $i_hProcess)
	Return $av_CloseHandle[0]
EndFunc ;==> _MemClose()

Func ReadString($OpenProcess, $Address)
	$i = 0
	$end = false
	$string = ''
	Do
		$v_Read = _MemRead($OpenProcess, $Address, 1)
		$char = chr($v_Read)
		$i = $i + 1
		$Address = $Address + 1
		If hex($v_Read, 8) == "00" Then
			$end = true
		Else
			$string = $string & $char
		EndIf
	until $end
	Return $string
EndFunc

Func ReadByte($OpenProcess, $Address)
	$v_Read = _MemRead($OpenProcess, $Address, 1)
	Return $v_Read
EndFunc

Func Read2Bytes($OpenProcess, $Address)
  $v_Read = _MemRead($OpenProcess, $Address, 2)
  Return $v_Read
EndFunc


Func GetPrice($OpenProcess, $Address)
  ; game code reads the value then adds the "shift right" version of it to calculate the price
  ; 004599BC   A1 E0F16900      MOV EAX,DWORD PTR DS:[69F1E0]
  ; 004599C1   8BD0             MOV EDX,EAX
  ; ...
  ; 004599C5   D1FA             SAR EDX,1
  ; 004599C7   03D0             ADD EDX,EAX

  $price1 = Int(_MemRead($OpenProcess, $Address, 2))
  $price2 = BitShift($price1, 1)
  Return $price1 + $price2
EndFunc


$Process = 'DIABLO.EXE'
$item_name_addr = 0x0069F195
$item_price_addr = 0x0069F1E0

$PID = ProcessExists($Process) ; get Diablo's process id
$OpenProcess = _MemOpen(0x38, False, $PID) ; open the process

$item_name = ReadString($OpenProcess, $item_name_addr)
$item_price = GetPrice($openProcess, $item_price_addr)

$output = 'Wirt has for sale "' & $item_name & '", for ' & $item_price & ' gold'

MsgBox(0, "Hypn's Wirt Spy v0.2", $output)
