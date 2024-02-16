
#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127

SetKeyDelay, -1, 1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen

PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High

HWIDFound := true ; removed auth and stuff

MsgBox 3x - This is a public beta test (ptb), Bugs are to be expected.


if HWIDFound
{
    #Include %A_LineFile%\..\JSON.ahk

    init:
    #NoEnv
    #SingleInstance, Force
    #Persistent
    #InstallKeybdHook
    #UseHook
    #KeyHistory, 0
    #HotKeyInterval 1
    #MaxHotkeysPerInterval 127
    traytip,
    SetKeyDelay, -1, 1
    SetControlDelay, -1
    SetMouseDelay, -1
    SetWinDelay, -1
    SendMode, InputThenPlay
    SetBatchLines, -1
    ListLines, Off
    CoordMode, Pixel, Screen, RGB
    CoordMode, Mouse, Screen
    PID := DllCall("GetCurrentProcessId")
    Process, Priority, %PID%, High
    
    
    configuration := A_LineFile . "\..\config.json"
    if (FileExist(configuration)) {
        File := FileOpen(configuration, "r")
        configData := File.Read()
        File.Close()
        config := JSON.Load(configData)
    } else {
        MsgBox, config file not found
        ExitApp
    }
    
    
    
    Preload := {}
    
    HoldMode := false
    Hex := 0xFDFDFC
    AddedCLS := 25
    CenterX := 955
    CenterY := 500
    FieldOfViewX := 50
    FieldOfViewY := 50
    LS := CenterX - FieldOfViewX
    ST := CenterY - FieldOfViewY
    SR := CenterX + FieldOfViewX
    SB := CenterY + FieldOfViewY
    Key := config.Key
    Bone := config.Bone
    FOVAmount := config.FOVAmount
    HeadOffset := config.Offsets.Head
    HumanoidOffset := config.Offsets.Humanoid
    UpperTorsoOffset := config.Offsets.UpperTorso
    VelocityX := config.Velocity.X
    VelocityY := config.Velocity.Y
    SmoothingX := config.Smoothing.X
    SmoothingY := config.Smoothing.Y
    PositionX := 0
    PositionY := 0
    
    
    CoordMode, Mouse, Screen
    
    FOVRange(x, y) {
        return (x >= LS && x <= SR && y >= ST && y <= SB)
    }
    
    hookfunction(str, uint1, intMoveX, intMoveY, uint2, int0) {
        return DllCall(str, "uint", uint1, "int", intMoveX, "int", intMoveY, "uint", uint2, "int", int0)
    }
    
    Loop {
        Locked := False
    
        if ((!HoldMode and GetKeyState(Key, "P")) or (HoldMode and GetKeyState(Key, "P")) or GetKeyState("nothing", "P")) {
            PixelSearch, AimPixelX, AimPixelY, PositionX-20, PositionY-20, PositionX+20, PositionY+20, Hex, AddedCLS, Fast RGB
            if (!ErrorLevel) {
                PositionX := AimPixelX
                PositionY := AimPixelY
                Locked := True
            } else {
                PixelSearch, AimPixelX, AimPixelY, LS, ST, SR, SB, Hex, AddedCLS, Fast RGB
                if (!ErrorLevel) {
                    PositionX := AimPixelX
                    PositionY := AimPixelY
                    Locked := True
                }
            }
    
            if (Locked) {
                AimX := PositionX - CenterX
                AimY := PositionY - CenterY
    
                AimX := AimX + AimX * VelocityX
                AimY := AimY + AimY * VelocityY
    
                DirX := -0.95
                DirY := -0.90
    
                if (Bone = "Head") {
                    DirX := HeadOffset
                    DirY := HeadOffset
                } else if (Bone = "HumanoidRootPart") {
                    DirX := HumanoidOffset
                    DirY := HumanoidOffset
                } else if (Bone = "UpperTorso") {
                    DirX := UpperTorsoOffset
                    DirY := UpperTorsoOffse
                }
    
                AimOffsetX := AimX * DirX
                AimOffsetY := AimY * DirY
                MoveX := Floor((AimOffsetX ** (1 / 2))) * DirX * SmoothingX
                MoveY := Floor((AimOffsetY ** (1 / 2))) * DirY * SmoothingY
                hookfunction("mouse_event", 1, MoveX, MoveY, 0, 0)
                CoordMode, Mouse, Screen
                MouseGetPos, CurMouseX, CurMouseY
            }
        }
    }
    
    toggle := false
    
    
    
    \::
        toggle := !toggle
        if (toggle) {
            SoundBeep, 500, 300
        }
        return
    
    
    if (Locked && toggle) {
        click down
    } else {
        click up
    }
    
    Paused := False
    Alt::
    Pause
    Paused := !Paused
    if (Paused) {
        SoundBeep, 750, 500
    }
    Return
}