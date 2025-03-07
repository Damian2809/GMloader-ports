#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/test"
$DATAFILE="test.apk"
# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if patchlog.txt to skip patching
if [ ! -f $GAMEDIR/assets/data.win ]; then
        zip -r -0 $GAMEDIR/$DATAFILE $GAMEDIR/assets/
        rm -rf $GAMEDIR/assets
        mkdir -p saves
else
    pm_message "Patching process already completed. Skipping."
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext" -c "test.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext -c "gmloader.json"

# Cleanup
pm_finish
