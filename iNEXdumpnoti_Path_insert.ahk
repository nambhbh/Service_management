
if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}

global installPath1 := "C:\IDIS_Solution_Suite\Server"
global installPath2 := "C:\IDIS Solution Suite\Server"
global installPath_etc

sender = nambhbh@naver.com
senderPass = nbhnaver603!
receiver = nambhbh@idis.co.kr
subject = %A_IPAddress1% iNEX dump occure
message = %A_IPAddress1% iNEX dump occure

IfnotExist, %installPath1% && IfnotExist, %installPath2%
{
	Gui, Add, Edit, x10 y10 w180 h20 vPath, iNEX 경로 입력
	Gui, Add, Button, x10 y40 w180 h20 gSave, 저장하기
	Gui, Show, w200 h70, iNEX 설치경로 입력
	return

	Save:
	Gui, Submit, NoHide
	Gui, cancel
	gosub, insertPath
	return

	GuiClose:
	Gui, cancel
}

insertPath:
installPath_etc := Path

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

findDumpfilePath(installPath)
{
	targetDir := installPath					; 변수(targetDir)에 대상 경로(바탕화면)를 대입합니다.
	filePatternsToFind := targetDir . "\*.dmp"	; 변수(filePatternsToFind)에 탐색할 파일 포맷을 대입합니다.
	keywordsToFind := "Service" 	; 변수(keywordsToFind)에 탐색 중 파일명에서 찾을 키워드를 대입합니다.

	Loop, Files, %filePatternsToFind%, F  		; 변수(filePatternsToFind) 경로를 탐색합니다.
	{
		currFilePath := A_LoopFileFullPath		; 변수(currFilePath)에 현재 열람 중인 파일의 경로를 대입합니다.
		if InStr(currFilePath, keywordsToFind) 	; 만약 현재 열람 중인 파일명에 변수(keywordsToFind)가 포함되어 있으면
		{
			return, currFilePath
		}
	}
}

Loop
{
	sleep, 1000
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
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\dump_log.txt
			break
		}
	}
	else IfExist, %installPath2%
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
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\dump_log.txt
			break
		}
	}
	else IfExist, %installPath_etc%
	{
		IfExist, %installPath_etc%\*.dmp
		{
			attachment := findDumpfilePath(installPath_etc)
			sendMail(sender, senderPass, receiver, subject, message, attachment)
			FileCreateDir, %A_WorkingDir%\dump
			FileCopy, %installPath_etc%\*.dmp, %A_WorkingDir%\dump
			FileCopy, %installPath_etc%\*.dmz, %A_WorkingDir%\dump
			FileDelete, %installPath_etc%\*.dmp
			FileDelete, %installPath_etc%\*.dmz
			FileAppend, %A_Hour%:%A_Min%:%A_Sec% dump_move`n, %A_WorkingDir%\dump\dump_log.txt
			break
		}
	}
}
ExitApp

^!c::
ExitApp
return