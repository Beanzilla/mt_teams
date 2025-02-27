mt_teams = {}
local storage = minetest.get_mod_storage()
mt_teams.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}
mt_teams.teams = {{color=mt_teams.colors.orange,
        owner='singplayer',
        name='base',
        members={},
        id=mt_teams.teams_num
    }}
mt_teams.teams_num = 1
players = {}

function mt_teams.load_teams()
    mt_teams.teams = minetest.deserialize(storage:get_string('mt_teams:table')) 
end
function mt_teams.save_teams()
    storage:set_float('mt_teams:is_in_here_somewhere', 1)
    storage:set_string('mt_teams:table', minetest.serialize(mt_teams.teams))
end

function mt_teams.get_team(player)
    local meta = player:get_meta()
    return meta:get_float("mt_teams:team")
end
function mt_teams.get_teams_name(player)
    local meta = player:get_meta()
    return meta:get_string("mt_teams:name")
end
function mt_teams.get_name_id(id)
    return mt_teams.teams[id].name
end
function mt_teams.remove_player(player)--removes player and if not there returns false
    local name = player:get_player_name()
    local team = player:get_meta():get_float('mt_teams:team')
    i = 1
    for key, val in mt_teams.teams[team].members do
        if val==name then mt_teams.teams[team].members.remove(i) return true
        else i = i+1 end
    end
    return false
end
function mt_teams.set_team(player,team)
    local meta = player:get_meta()
    if meta:get_float('mt_teams:team') ~= nil then
        local r = mt_teams.remove_player(player)
        if r == false then
            minetest.chat_send_player(player:get_player_name(), "Not listed in "..mt_teams.get_teams_name(player).."'s members")
        --no way to get rid of members in a team so for now... no changing
        end 
    end 
    if mt_teams.teams[team] ~= nil then
        meta:set_float('mt_teams:team', team)
        table_insert(mt_teams.teams[team].members,player:get_player_name())
        minetest.chat_send_all(string.format("*** %s joined team "..minetest.colorize(mt_teams.teams[meta:get_float("mt_teams:team")].color,mt_teams.teams[team].name),minetest.colorize(mt_teams.teams[meta:get_float("mt_teams:team")].color, player:get_player_name())))
    else
        minetest.chat_send_player(player:get_player_name(), "Team doesnt appear to exist")
    end
end
function mt_teams.create_team(player, name, color)
    mt_teams.teams_num = mt_teams.teams_num+1
    local meta = player:get_meta()
    meta:set_float('mt_teams:team', mt_teams.teams_num)
    meta:set_bool('mt_teams:is_owner', true)
    meta:set_string('mt_teams:name', name)
    table.insert_all(mt_teams.teams, 
        {color=color,
        owner=player,
        name=name,
        id=mt_teams.teams_num
    })
    mt_teams.save_teams()
end

minetest.register_on_mods_loaded(function()
    mt_teams.load_teams()
end)
minetest.register_on_joinplayer(function(player, last_login)
    local meta = player:get_meta()
    if storage:contains('mt_teams:is_in_here_somewhere') == true then
        mt_teams.load_teams()
    else
        mt_teams.save_teams()
    end
    if meta:contains('mt_teams:team') == false then
        math.randomseed(100)
        local rand = math.ceil((math.random()*mt_teams.teams_num))
        mt_teams.set_team(player, rand)
        minetest.chat_send_player(player:get_player_name(), mt_teams.teams[rand].name)
    end
end
)
