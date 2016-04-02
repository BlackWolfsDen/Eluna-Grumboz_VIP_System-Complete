function Bloodyvipcoinxxx_Trigger(item, caster, event)
local Vip = ACCT[caster:GetAccountId()].Vip
	if (Vip >= 1)and(Vip <= 19) then
		caster:RemoveItem(63021, 1)
		UpdateVip(caster, 1)
		return false;
	end
	if(Vip == 20)then
		caster:SendBroadcastMessage("you cannot levelup your VIP with this stone anymore. You are VIP"..Vip..".")
		return false;
	end
end
RegisterItemGossipEvent(63021, 1, Bloodyvipcoinxxx_Trigger)