-- Grumbo'z Bloody VIP System
-- The Core Engine of the VIP System
-- this must be the first script of the VIP system to load.

print("-----------------------------------")
print("Grumbo'z VIP Engine loading:\n")
local core = "ElunaEngine"

if(GetLuaEngine()~=core)then
	print("err: "..GetLuaEngine().." Detected.\n")
	print("LOAD HALTED")
	return false;
else
	print("Approved: "..GetLuaEngine().." Detected.\n")
end

local VIPMAX = 20; -- you can set it to what ever your little heart desires.
local VOTECOUNT = 125; -- how many votes required to level-up
local VIPCOIN = 63020;
local VIPSTONE = 63021;
local MAGICGOLD = 44209;
local VIPTPBONUS = 14; -- how many extra talentpoints for each level of vip.
local COMMANDS = "vcommands"; -- command used to list vip commands
ACCT = {}
print("VIP Table Allocated.")
ACCT["SERVER"] = {
	Vip_max = VIPMAX,
	Vote_count = VOTECOUNT,
	Vip_coin = VIPCOIN,
	Vip_stone = VIPSTONE,
	Mg = MAGICGOLD,
	Tp_mod = VIPTPBONUS,
	Commands = COMMANDS
		};
print("CORE settings loaded.")

local function Player_Vip_Table(event, player)
local Paccid = player:GetAccountId()

	local Q = WorldDBQuery("SELECT username, vip, votes, mg FROM auth.account WHERE `id` = '"..player:GetAccountId().."';");
	ACCT[Paccid] = {
		chat = 0,
		Name = Q:GetString(0),
		Vip = Q:GetUInt32(1),
		Votes = Q:GetUInt32(2), -- you can table this independantly if you want to query the data from a different db location
		Mg = Q:GetUInt32(3),
		Health = player:GetMaxHealth()
					};
	print(ACCT[Paccid].Name.." :VIP table loaded.")

		if(ACCT[Paccid].Votes < ACCT["SERVER"].Vote_count)then
			SetVip(player,1)
			player:SendBroadcastMessage("/say "..ACCT["SERVER"].Commands.."|cff00cc00 for a list of VIP commands.|r")
			return false;
			end
		if(ACCT[Paccid].Votes > (ACCT["SERVER"].Vote_count*ACCT["SERVER"].Vip_max))then
			SetVip(player,ACCT["SERVER"].Vip_max)
			player:SendBroadcastMessage("/say "..ACCT["SERVER"].Commands.."|cff00cc00 for a list of VIP commands.|r")
			return false;
			end
	SetVip(player,(math.ceil(ACCT[Paccid].Votes / ACCT["SERVER"].Vote_count)))
	player:SendBroadcastMessage("/say "..ACCT["SERVER"].Commands.."|cff00cc00 for a list of VIP commands.|r")
end

RegisterPlayerEvent(3, Player_Vip_Table)
print("Player VIP Table prepared.")

function AddMG(player, change)
	if((change or 0)==0)then
	return
	end

	local Paccid = player:GetAccountId()
	local Paccnm = player:GetAccountName()
	local newmg = ACCT[Paccid].Mg+change
	ACCT[Paccid].Mg = newmg
	WorldDBQuery("UPDATE auth.account SET `mg`='"..newmg.."' WHERE `username`='"..Paccnm.."';");
	player:SendBroadcastMessage("Banker|cff00cc00:+"..change.."MG's added.|r")
	end

function DeleteMG(player, change)
	if((change or 0)==0)then
	return
	end
	
	local Paccid = player:GetAccountId()
	local Paccnm = player:GetAccountName()
	local newmg = ACCT[Paccid].Mg-change
	ACCT[Paccid].Mg = newmg
	WorldDBQuery("UPDATE auth.account SET `mg`='"..newmg.."' WHERE `username`='"..Paccnm.."';");
	player:SendBroadcastMessage("Banker|cff00cc00:-"..change.."MG's removed.|r")
	end
	

function SetVip(player, vip)
	if((vip or 0)==0)then
	return
	end

	local Paccid = player:GetAccountId()
	local Paccnm = player:GetAccountName()
	ACCT[Paccid].Vip = vip
	WorldDBQuery("UPDATE auth.account SET `vip`='"..vip.."' WHERE `username`='"..Paccnm.."';");
	player:SendBroadcastMessage("|cff00cc00You\'re VIP is set to "..ACCT[Paccid].Vip..".|r")

end

function UpdateVotes(player, change)
	if((change or 0)==0)then
	return
	end
	
	local Paccid = player:GetAccountId()
	local Paccnm = player:GetAccountName()
	ACCT[Paccid].Votes = (ACCT[Paccid].Votes+change)
	WorldDBQuery("UPDATE auth.account SET `votes`=`votes`+'"..change.."' WHERE `username`='"..Paccnm.."';");
	return
end

function UpdatePvpReward(killer, victim)
local Kaccid = killer:GetAccountId()
local Vaccid = victim:GetAccountId()
	AddMG(killer, ACCT[Kaccid].Vip+ACCT[Vaccid].Vip)
	killer:SendBroadcastMessage("|cff00cc00PvP Winner. "..ACCT[Kaccid].Vip.."+"..ACCT[Vaccid].Vip.." MG's transfered.|r")
	ACCT[Vaccid].Mg = ACCT[Vaccid].Mg-ACCT[Vaccid].Vip
	DeleteMG(victim, ACCT[Vaccid].Vip)
	victim:SendBroadcastMessage("|cffcc0000PvP Loser. -"..ACCT[Vaccid].Vip.." MG's lost.|r")
	end
	
function LoadVipTable(event, player, msg)

local message = "Load Vip Table"

	if(msg==message)then
		ACCT = {}
		ACCT["SERVER"] = {
			Vip_max = VIPMAX,
			Vote_count = VOTECOUNT,
			Vip_coin = VIPCOIN,
			Vip_stone = VIPSTONE,
			Mg = MAGICGOLD,
			Tp_mod = VIPTPBONUS,
			Commands = COMMANDS
				};
		for _,v in ipairs(GetPlayersInWorld()) do
	
	 		if(v and v:IsInWorld()) then
				local Q = WorldDBQuery("SELECT id, username, vip, votes, mg FROM auth.account WHERE `id` = '"..v:GetAccountId().."';");
				ACCT[Q:GetUInt32(0)] = {
					Name = Q:GetString(1),
					Vip = Q:GetUInt32(2),
					Votes = Q:GetUInt32(3),
					Mg = Q:GetUInt32(4)
							};
				print(ACCT[v:GetAccountId()].Name.." : VIP Table re-Loaded.")
				player:SendBroadcastMessage("/say "..ACCT["SERVER"].Commands.."|cff00cc00 for a list of VIP commands.|r")
			end
		end
	player:SendBroadcastMessage("Grumbo'z VIP Table Re-loaded.")
	print("VIP Table re-loaded")
	end
end

RegisterPlayerEvent(18, LoadVipTable) 

local function Vcommands(event, player, msg)

local message = "Load Vip Table"

	if(msg:lower() == ACCT["SERVER"].Commands)then
		player:SendBroadcastMessage("|cff00cc00VIP Commands:|r")
		
			if(player:GetGMRank() >= 3)then
				player:SendBroadcastMessage("/say "..message.." |cff00cc00To re-load the VIP Tables.|r")
			else
			end
	else
	end
end

RegisterPlayerEvent(18, Vcommands) 
LoadVipTable()

print("\nGrumbo'z VIP Engine running.")
print("-----------------------------------")