sleep, 10000
global checker := "cd FirmwareChecker"
global manager := "cd FirmwareManager"

;------------------------------- 한영키 확인-----------------------------------
IME_CHECK(WinTitle)
{
    WinGet,hWnd,ID,%WinTitle%
    Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd),0x005,"")
}

Send_ImeControl(DefaultIMEWnd, wParam, lParam)
{
    DetectSave := A_DetectHiddenWindows
    DetectHiddenWindows,ON
    SendMessage 0x283, wParam,lParam,,ahk_id %DefaultIMEWnd%
	if (DetectSave <> A_DetectHiddenWindows)
		DetectHiddenWindows,%DetectSave%
		return ErrorLevel
}

ImmGetDefaultIMEWnd(hWnd)
{
	return DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)
}

WinGetActiveTitle, ExplorerTitle
ime_status := % IME_CHECK("A")
if (ime_status = "0")
{
	;
}
else
{
	Send, {vk15sc138}
}

;------------------------------- npm 실행-----------------------------------
start_npm(url)
{
	send, #r
	sleep, 3000

	send, cmd
	sleep, 1000
	send, {Enter}
	sleep, 3000

	send, cd\
	sleep, 500
	send, {Enter}
	sleep, 500
	send, cd UPS
	sleep, 500
	send, {Enter}
	sleep, 500
	send, %url%
	sleep, 500
	send, {Enter}
	sleep, 500
	send, npm start
	sleep, 500
	send, {Enter}
	sleep, 500
}

start_npm(checker)
start_npm(manager)

;-----------------------Firmware Upgrade manager 실행-------------------------

run, http://10.0.131.101:3001/main
sleep, 3000


ExitApp