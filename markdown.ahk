
; Opens the command shell 'cmd' in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
; Credit to: Eli Bendersky (original) -> https://superuser.com/questions/205359/how-can-i-open-a-command-prompt-in-current-folder-with-a-keyboard-shortcut
SetTitleMatchMode RegEx
return

; 
; Added an elevation option
OpenCmdInCurrent(elevated)
{

    ; This is required to get the full path of the file from the address bar
    WinGetText, full_path, A
    WinGetActiveTitle, title

    MsgBox, Elevated %elevated%, Path %full_path%, Title %title%

    ; Split on newline (`n)
    StringSplit, word_array, full_path, `n

    ; Find and take the element from the array that contains address
    Loop, %word_array0%
    {
        IfInString, word_array%A_Index%, Address
        {
            full_path := word_array%A_Index%
            break
        }
    }  

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Addresse: ", "")

    ; Just in case - remove all carriage returns (`r)
    StringReplace, full_path, full_path, `r, , all
    !IfInString full_path, \
    {
        EnvGet, full_path, USERPROFILE
    }

    if elevated
    {
            Try
            {
                Run *Runas, cmd /K cd /d "%full_path%"
            }
            Catch
            {
                ; If elevation fails
                exit
            }
    }
    else
    {
        Run,  cmd /K cd /D "%full_path%"
    }
}


number_inputbox(TextboxTitle)
{
    output = ""
    InputBox, current_input, %TextboxTitle%
    If !ErrorLevel
    {
        try {
            if (current_input != ""){
                if current_input is number
                    output = %current_input%
            }
        } 
    }
    Else
    {
        exit
    }
    return output
}
generate_markdown_table(rows, columns)
{
    ; Header Generation
    output := "|"
    Loop %columns%
    {
        output = %output% Header %A_Index% |
    }
    output = %output%`n

    output = %output%|
    ; Header Separator
    Loop %columns%
    {
        output = %output%---|
    }
    output = %output%`n
    ; Body Generation

    loop %rows%
    {
        output = %output%|
        loop %columns%
        {
            output = %output% Row %row% Column  %column% |
        }
        output = %output%`n
    }
    return output
}
hotstring_box(){
    output = ""
    InputBox, current_input, "Hotstring Box"
    If (ErrorLevel = "Timeout")
    {
        MsgBox, [ Options, Title, Text, Timeout]
    }
}


#t::
Markdown_DefaultTableColumns = 3
Markdown_DefaultTableRows = 3

rows_to_create = Markdown_DefaultTableRows
row_input := number_inputbox("Rows")

if row_input != ""
    rows_to_create = %row_input%


cols_to_create = Markdown_DefaultTableColumns
col_input := number_inputbox("Cols")
if col_input != ""
    cols_to_create = %col_input%


table:=generate_markdown_table(rows_to_create, cols_to_create)
Send %table%
return

; Shells
; Windows + Enter -> new Shell
#Enter::
Run "cmd.exe"
return

; Windows + Shift + Enter -> elevated Shell
#<+Enter::
    Try
    {
        Run *Runas "cmd.exe"
    }
    Catch
    {
        exit
    }
return


; if the explorer is in focus open a terminal in the current folder
#IfWinActive ahk_class ExploreWClass|CabinetWClass
    #<+Enter::
        OpenCmdInCurrent(1)
    return

    #Enter::
        OpenCmdInCurrent(0)
    return
#IfWinActive