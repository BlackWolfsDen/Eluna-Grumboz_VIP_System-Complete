local timer = 1 -- speed to eliminate the chance of double clicking exploit.
local itemid = ACCT["SERVER"].Vip_stone

local function RemoveVIPstone(event, _, _, player)
local Paccid = player:GetAccountId()
	SetVip(player, ACCT[Paccid].Vip+1)
	UpdateVotes(player, ACCT["SERVER"].Vote_count+1) -- just to balance the math for the checker.
	player:RemoveItem(ACCT["SERVER"].Vip_stone, 1)
end

function VIPstone(event, player, spellID, effindex, item)
local Paccid = player:GetAccountId()

	if(ACCT[Paccid].Vip<=(ACCT["SERVER"].Vip_max-1))then
		player:RegisterEvent(RemoveVIPstone, timer, 1, player)
	
	else
		player:SendBroadcastMessage("you are Max VIP "..ACCT[Paccid].Vip..".")
	return
	end
end
		
RegisterItemEvent(itemid, 2, VIPstone)
print("Grumbo'z VIP Stone loaded.")
