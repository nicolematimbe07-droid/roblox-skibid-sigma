-- SKIBIDI TOILET vs. SIGMA MALE: O CONFRONTO FINAL
-- GameManager.lua - Sistema Principal do Jogo

local GameManager = {}
GameManager.__index = GameManager

local Teams = {
	SKIBIDI = "FACÇÃO SKIBIDI (BANHEIROS)",
	SIGMA = "FACÇÃO SIGMA (HOMENS)"
}

local GAME_STATES = {
	LOBBY = "lobby",
	PREPARING = "preparing",
	ACTIVE = "active",
	ENDING = "ending"
}

function GameManager.new()
	local self = setmetatable({}, GameManager)
	self.state = GAME_STATES.LOBBY
	self.players = {}
	self.teamCounts = {
		[Teams.SKIBIDI] = 0,
		[Teams.SIGMA] = 0
	}
	self.globalRanking = {}
	self.gameTime = 0
	self.maxGameTime = 600 -- 10 minutos
	
	return self
end

function GameManager:addPlayer(player, faction)
	if not self.players[player.UserId] then
		self.players[player.UserId] = {
			player = player,
			faction = faction,
			rizz = 0,
			kills = 0,
			alive = true,
			position = Vector3.new(0, 5, 0)
		}
		self.teamCounts[faction] = self.teamCounts[faction] + 1
		self:updateGlobalRanking()
	end
end

function GameManager:removePlayer(player)
	if self.players[player.UserId] then
		local faction = self.players[player.UserId].faction
		self.teamCounts[faction] = self.teamCounts[faction] - 1
		self.players[player.UserId] = nil
		self:updateGlobalRanking()
	end
end

function GameManager:addRizz(player, amount)
	if self.players[player.UserId] then
		self.players[player.UserId].rizz = self.players[player.UserId].rizz + amount
		self:updateGlobalRanking()
		return true
	end
	return false
end

function GameManager:recordKill(player)
	if self.players[player.UserId] then
		self.players[player.UserId].kills = self.players[player.UserId].kills + 1
		self:addRizz(player, 50)
		return true
	end
	return false
end

function GameManager:updateGlobalRanking()
	self.globalRanking = {}
	for userId, playerData in pairs(self.players) do
		table.insert(self.globalRanking, {
			name = playerData.player.Name,
			rizz = playerData.rizz,
			faction = playerData.faction,
			kills = playerData.kills
		})
	end
	table.sort(self.globalRanking, function(a, b)
		return a.rizz > b.rizz
	end)
	-- Limitar aos top 3
	self.globalRanking = {self.globalRanking[1], self.globalRanking[2], self.globalRanking[3]}
end

function GameManager:getTeamCounts()
	return self.teamCounts[Teams.SKIBIDI], self.teamCounts[Teams.SIGMA]
end

function GameManager:getGameState()
	return self.state
end

function GameManager:setGameState(newState)
	self.state = newState
end

function GameManager:getPlayerFaction(player)
	if self.players[player.UserId] then
		return self.players[player.UserId].faction
	end
	return nil
end

function GameManager:getTopPlayers()
	return self.globalRanking
end

return GameManager
