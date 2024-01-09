#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 4
SetDefaultMouseSpeed 0
SetMouseDelay -1


home := EnvGet("USERPROFILE")

if home = "" {
  MsgBox("Home folder not set. Something is wrong.", "Error")
  return
}

main := Gui()
lootCords := []
sendsStrArr := []
configFilePath := home "\autoloot.ini"
previousHK := "0"


main.AddGroupBox("w270 h90", "Configuration")
main.AddText("xp+10 yp+20", "Hotkey to loot:")
lootHK := main.AddHotkey("xp+85 yp-3 w100", "vChosenHotkey")
main.AddText("xs+10 yp+30", "Character Name:")
charName := main.AddEdit("xp+85 yp-3 w150", "Character Name")


main.AddGroupBox("xs w270 h275", "Coordinates",)
helperBtn := main.AddButton("xp+10 yp+20", "Set Coordinates Helper")
helperBtn.OnEvent("Click", Start_Helper)
main.AddText("xp y+3", "Char Pos")
charCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Top Left")
topLeftCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Top Middle")
topMiddleCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Top Right")
topRightCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Right")
rightCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Bottom Right")
bottomRightCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Bottom Middle")
bottomMiddleCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Bottom Left")
bottomLeftCords := main.AddEdit("xp+100 w100", "0,0")
main.AddText("xs+10 yp+25", "Left")
leftCords := main.AddEdit("xp+100 w100", "0,0")

btn := main.AddButton("xs", "Save and Start")
btn.OnEvent("Click", Save_Config)
btn.Focus()

; Load the config if exists
if FileExist(configFilePath) {
  charName.Value := IniRead(configFilePath, "CharacterName", "value")
  lootHK.Value := IniRead(configFilePath, "Hotkey", "value")

  charCords.Value := IniRead(configFilePath, "Coordinates", "0")
  topLeftCords.Value := IniRead(configFilePath, "Coordinates", "1")
  topMiddleCords.Value := IniRead(configFilePath, "Coordinates", "2")
  topRightCords.Value := IniRead(configFilePath, "Coordinates", "3")
  rightCords.Value := IniRead(configFilePath, "Coordinates", "4")
  bottomRightCords.Value := IniRead(configFilePath, "Coordinates", "5")
  bottomMiddleCords.Value := IniRead(configFilePath, "Coordinates", "6")
  bottomLeftCords.Value := IniRead(configFilePath, "Coordinates", "7")
  leftCords.Value := IniRead(configFilePath, "Coordinates", "8")

  global lootCords := []
  global sendsStrArr := []

  lootCords.Push(charCords.Value)
  lootCords.Push(topLeftCords.Value)
  lootCords.Push(topMiddleCords.Value)
  lootCords.Push(topRightCords.Value)
  lootCords.Push(rightCords.Value)
  lootCords.Push(bottomRightCords.Value)
  lootCords.Push(bottomMiddleCords.Value)
  lootCords.Push(bottomLeftCords.Value)
  lootCords.Push(leftCords.Value)

  for coords in lootCords {
    arr := StrSplit(coords, ",")
    yCoord := arr.Pop()
    xCoord := arr.Pop()
    strToClick := "+{Click, " . xCoord . "," . yCoord . ", right}"
    sendsStrArr.Push(strToClick)
  }

  global previousHK := lootHK.Value
  Hotkey(lootHK.Value, Get_Loot)
}

; Start helper to copy mouse Coordinates
Start_Helper(Button, Info) {
  if charName.Value = "Character Name" {
    MsgBox("Please set character name so we can find the correct window.", "Error")
  }

  if WinExist("Tibia - " charName.Value) {
    WinActivate("Tibia - " charName.Value)
  }

  end := 0
  main.Minimize()

  while end != 1 {
    MouseGetPos(&currX, &currY)
    ToolTip("X: " currX " Y: " currY, currX + 20, currY + 20, 1)
    if (GetKeyState("RButton", "P")) {
      MouseGetPos(&copyX, &copyY)
      A_Clipboard := copyX "," copyY
      end := 1
    }
  }
  ToolTip
  main.Show()
}

; Save current values in the configuration and start listening to hotkey
Save_Config(Button, Info) {
  if lootHK.Value = "" {
    MsgBox("Please set a hotkey.", "Error")
    return
  }

  if charName.Value = "Character Name" {
    MsgBox("Please set your character name so we can find the correct tibia window.", "Error")
    return
  }

  Hotkey(previousHK, Get_Loot, "Off")

  global lootCords := []
  global sendsStrArr := []

  lootCords.Push(charCords.Value)
  lootCords.Push(topLeftCords.Value)
  lootCords.Push(topMiddleCords.Value)
  lootCords.Push(topRightCords.Value)
  lootCords.Push(rightCords.Value)
  lootCords.Push(bottomRightCords.Value)
  lootCords.Push(bottomMiddleCords.Value)
  lootCords.Push(bottomLeftCords.Value)
  lootCords.Push(leftCords.Value)

  for cord in lootCords {
    if cord = "0,0" or cord = "0.0" {
      MsgBox(cord)
      MsgBox("Please set all coordinates.", "Error")
      return
    }
  }

  for coords in lootCords {
    arr := StrSplit(coords, ",")
    yCoord := arr.Pop()
    xCoord := arr.Pop()
    strToClick := "+{Click, " . xCoord . "," . yCoord . ", right}"
    sendsStrArr.Push(strToClick)
  }

  IniWrite(charName.Value, configFilePath, "CharacterName", "value")
  IniWrite(lootHK.Value, configFilePath, "Hotkey", "value")

  i := 0
  for cord in lootCords {
    IniWrite(cord, configFilePath, "Coordinates", i)
    i++
  }

  Hotkey(lootHK.Value, Get_Loot)
  global previousHK := lootHK.Value
  MsgBox("Settings saved successfully! ", "Success")
  return
}

main.Show()

Get_Loot(*) {
  MouseGetPos(&previousX, &previousY)
  for str in sendsStrArr {
    Send(str)
  }
  MouseMove(previousX, previousY)
}