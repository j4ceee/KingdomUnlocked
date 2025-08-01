local Unlocked_I_Chat = Classes.Job_InteractionBase:Inherit("Unlocked_I_Chat")

function Unlocked_I_Chat:Test( sim1, sim2, autonomous )
	if (sim1 == Universe:GetPlayerGameObject() or sim2 == Universe:GetPlayerGameObject()) then
		return false -- don't allow player sim to be involved in this interaction
	end

	if ( sim1 == sim2 ) then
		return false
	end

	if ( Class:InheritsFrom(sim2, "NPC_Protomakoto") ) then
		if (not Task:IsTaskComplete( "NPC_PM_SocialReboot" )) then
			return false
		end
	end -- check protomakoto

	return true
end

function Unlocked_I_Chat:Destructor()
end

local socialAnims = {
	{
		name = "chatneutral", -- name of the social anim
		response = "", -- response to the chat (empty for random, nil for no response)
	},
	{
		name = "chathappy",
		response = "",
	},
	{
		name = "chatangry",
		response = "",
	},
	{
		name = "chatsad",
		response = "",
	},
	{
		name = "chatgrumpy",
		response = "",
	},
	{
		name = "talkexcited",
		response = "",
	},
	{
		name = "talkexcited2",
		response = "",
	},
	{
		name = "talkneutral",
		response = "",
	},
	{
		name = "talkthoughtful",
		response = "",
	},
	{
		name = "talkpanic",
		response = "",
	},
	{
		name = "talkconfused",
		response = "",
	},
	{
		name = "compliment",
		response = "talkexcited",
	},
	{
		name = "chathappyreactlistenbad",
		response = "",
	},
	{
		name = "talkangry",
		response = "talkangry",
	}

}

function Unlocked_I_Chat:Action( sim1, sim2 )
	local simA = sim1
	local simB = sim2

	local loops = math.random( 1, 4 ) -- random number of loops

	for i = 1, loops do
		self:Chat( simA, simB )

		-- 50/50 chance to swap sims
		if math.random( 2 ) == 1 then
			simA, simB = simB, simA -- swap sims
		end
	end
end

function Unlocked_I_Chat:Chat( simA, simB )
	local socialAnim = socialAnims[ math.random( #socialAnims ) ]

	local params = {
		socialAnim = socialAnim.name, -- name of the social anim
		bReverseAnims = false,
	}

	local socialJob = Classes.Job_SocialBase:Spawn(simA, simB, params)
	socialJob:Execute(simA)

	local result, reason = socialJob:WaitToPush()

	if result == BlockingResult.Succeeded then
		simB:PushInteraction( socialJob, "Social", params )
	end
end