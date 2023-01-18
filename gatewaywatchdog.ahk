global installPath1 := "C:\Program Files (x86)\FEN Service"
global installPath2 := "D:\Program Files (x86)\FEN Service"
global installPath3 := "E:\Program Files (x86)\FEN Service"
global dump
global rebootstr

dump := 0
rebootstr := "shutdown /r /t 0"

SetCapsLockState, off
;-----------------------FEN Site 실행-------------------------
CoordMode, mouse, Relative
IfWinNotExist, Fen Service Administration Page - Windows Internet Explorer
{
	IfWinNotExist, Windows 보안
	{
		IfWinNotExist, 인증서 오류: 탐색이 차단됨 - Windows Internet Explorer
		{
			run, https://%A_IPAddress1%:4433
		}
	}
}
sleep, 1000

ifWinExist, 인증서 오류: 탐색이 차단됨 - Windows Internet Explorer
	WinActivate, 인증서 오류: 탐색이 차단됨 - Windows Internet Explorer
	ControlClick, x187 y278, 인증서 오류: 탐색이 차단됨 - Windows Internet Explorer, , , ,NA
sleep, 1000

ifWinExist, Windows 보안
	WinActivate, Windows 보안
	ControlSend, ,{Enter}, Windows 보안

;------------------------------- email 설정-----------------------------------
sender = nambhbh@naver.com
senderPass = nbhnaver603!
receiver = nambhbh@idis.co.kr
subject = %A_IPAddress1% FEN dump occure
message = %A_IPAddress1% FEN dump occure

;------------------------------- 한영키 확인 함수-----------------------------------

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

;------------------------------- email 함수-----------------------------------

sendMail(sender, senderPass, receiver, subject, message, attachment)
{
pmsg := ComObjCreate("CDO.Message")
pmsg.From := sender                ;I believe that the change required is to be made here
pmsg.To := receiver,
pmsg.Subject := subject,
pmsg.TextBody := message,

sAttach := attachment

fields := Object()
fields.smtpserver := "smtp.naver.com"
fields.smtpserverport := 465
fields.smtpusessl := true
fields.sendusing := 2
fields.smtpauthenticate := 1
fields.sendusername := sender
fields.sendpassword := senderPass
fields.smtpconnectiontimeout := 60
schema := "http://schemas.microsoft.com/cdo/configuration/"

pfld := pmsg.Configuration.Fields

For field,value in fields
pfld.Item(schema . field) := value
pfld.Update()
Loop, Parse, sAttach, |, %A_Space%%A_Tab%
	pmsg.AddAttachment(A_LoopField)
pmsg.Send()
}

;--------------------------- dump 파일 경로 확인 함수 -------------------------------

findDumpfilePath(installPath)
{
	targetDir := installPath					; 변수(targetDir)에 대상 경로(바탕화면)를 대입합니다.
	filePatternsToFind := targetDir . "\*.dmp"	; 변수(filePatternsToFind)에 탐색할 파일 포맷을 대입합니다.
	keywordsToFind := "Fen" 	; 변수(keywordsToFind)에 탐색 중 파일명에서 찾을 키워드를 대입합니다.

	Loop, Files, %filePatternsToFind%, F  		; 변수(filePatternsToFind) 경로를 탐색합니다.
	{
		currFilePath := A_LoopFileFullPath		; 변수(currFilePath)에 현재 열람 중인 파일의 경로를 대입합니다.
		if InStr(currFilePath, keywordsToFind) 	; 만약 현재 열람 중인 파일명에 변수(keywordsToFind)가 포함되어 있으면
		{
			return, currFilePath
		}
	}
}

;----------------------------- dump 파일 검색 및 이동---------------------------------

Loop
{
	ifWinExist, Windows 보안
	{
		send, {Enter}
	}

	sleep, 10000
	IfExist, %installPath1%
	{
		IfExist, %installPath1%\*.dmp
		{
			attachment := findDumpfilePath(installPath1)
			sendMail(sender, senderPass, receiver, subject, message, attachment)
			FileCreateDir, %A_WorkingDir%\dump
			FileCopy, %installPath1%\*.dmp, %A_WorkingDir%\dump
			FileCopy, %installPath1%\*.dmz, %A_WorkingDir%\dump
			FileDelete, %installPath1%\*.dmp
			FileDelete, %installPath1%\*.dmz
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\reboot_log.txt
			dump++
			if (dump >1)
			{
				break
			}
		}
	}
	IfExist, %installPath2%
	{
		IfExist, %installPath2%\*.dmp
		{
			attachment := findDumpfilePath(installPath2)
			sendMail(sender, senderPass, receiver, subject, message, attachment)
			FileCreateDir, %A_WorkingDir%\dump
			FileCopy, %installPath2%\*.dmp, %A_WorkingDir%\dump
			FileCopy, %installPath2%\*.dmz, %A_WorkingDir%\dump
			FileDelete, %installPath2%\*.dmp
			FileDelete, %installPath2%\*.dmz
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\reboot_log.txt
			dump++
			if (dump >1)
			{
				break
			}
		}
	}
	IfExist, %installPath3%
	{
		IfExist, %installPath3%\*.dmp
		{
			attachment := findDumpfilePath(installPath3)
			sendMail(sender, senderPass, receiver, subject, message, attachment)
			FileCreateDir, %A_WorkingDir%\dump
			FileCopy, %installPath3%\*.dmp, %A_WorkingDir%\dump
			FileCopy, %installPath3%\*.dmz, %A_WorkingDir%\dump
			FileDelete, %installPath3%\*.dmp
			FileDelete, %installPath3%\*.dmz
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\reboot_log.txt
			dump++
			if (dump >1)
			{
				break
			}
		}
	}
}

;------------------------------- 리부팅 -----------------------------------

if (dump > 1)
{
	dump := 0
	FileAppend, %A_Hour%:%A_Min%:%A_Sec% watchdog occure!!`n, %A_WorkingDir%\dump\reboot_log.txt

	send, #r
	sleep, 1000

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
	send, %rebootstr%
	sleep, 1000
	send, {Enter}
}
ExitApp

^!c::
ExitApp
return