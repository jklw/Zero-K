#!/bin/zsh

set -eu

lw=(
    cmd_moving_lances_hold_fire.lua
    cmd_stored_build_queue.lua
    gui_contextmenu.lua
    cmd_hold_ctrl_to_place_and_morph.lua
    dbg_unit_stats_dumper.lua
)

for x in $lw
do
    local src=LuaUI/Widgets/$x 
    local dest=/h/dist/zero-k-portable/LuaUI/Widgets/$x
    if [[ -e $src ]]
    then
        if [[ $src -ef $dest ]] 
        then
            echo "  Already linked: $src"
        else
            [[ -e $dest ]] && /usr/bin/trash $dest || :
            ln -v $src $dest
        fi
    else 
        echo "Source does not exist: $src"
    fi
done

toTrash=(
    gui_chili_nuke_warning.lua
    gui_chili_share.lua
    gui_keyboard_manager.lua
    gui_chili_integral_menu.lua
    ../Configs/border_menu_commands.lua
    ../Configs/customCmdTypes.lua
    ../Configs/integral_menu_commands.lua 
    ../Configs/integral_menu_config.lua 
    ../Configs/integral_menu_culling.lua 
    ../Images/commands/states/formation_rank_0.png
    ../Images/commands/states/formation_rank_1.png
    ../Images/commands/states/formation_rank_2.png
    ../Images/commands/states/formation_rank_3.png
    cmd_customformations2.lua
    unit_start_state.lua
)

for x in $toTrash
do
    local dest=/h/dist/zero-k-portable/LuaUI/Widgets/$x
    [[ -e $dest ]] && /usr/bin/trash $dest && echo "Trashed: $dest" || :
done
