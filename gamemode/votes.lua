Vote = {}
Votes = {}

function ccDoVote(ply, cmd, args)
	if not Votes[args[1]] or not tonumber(args[2]) or not Votes[args[1]][tonumber(args[2])] then return end

	if not ply.VoteHistory then
		ply.VoteHistory = {}
	end

	Votes[args[1]]:HandleNewVote(ply, tonumber(args[2]))
end
concommand.Add("vote", ccDoVote)

function Vote:HandleNewVote(ply, id)
	self[id] = self[id] + 1

	if self[1] + self[2] >= (#player.GetAll() - 1) then
		vote.HandleVoteEnd(self.ID)
	end
end

vote = {}

function vote:Create(question, voteid, ent, delay, callback)
	if #player.GetAll() == 1 then
		Notify(ent, 1, 4, "No other players to vote against you.")
		callback(1, ent)
		return
	end

	if not ent.VoteHistory then
		ent.VoteHistory = {}
	end

	ent.VoteHistory[voteid] = true

	local newvote = {}
	for k, v in pairs(Vote) do newvote[k] = v end

	newvote.ID = voteid
	newvote.Callback = callback
	newvote.Ent = ent

	newvote[1] = 0
	newvote[2] = 0

	Votes[voteid] = newvote

	umsg.Start("DoVote")
		umsg.String(question)
		umsg.String(voteid)
		umsg.Float(delay)
	umsg.End()

	if string.find(question, "Cop") then
		VoteCopOn = true
	elseif string.find(question, "Mayor") then
		VoteMayorOn = true
	end
	Notify(ent, 1, 4, "Vote created!")

	timer.Create(voteid .. "timer", delay, 1, function() vote.HandleVoteEnd(voteid) end)
end

function vote.DestroyVotesWithEnt(ent)
	for k, v in pairs(Votes) do
		if v.Ent == ent then
			umsg.Start("KillVoteVGUI")
				umsg.String(v.ID)
			umsg.End()

			for k, v in pairs(player.GetAll()) do
				v.VoteHistory[v.ID] = nil
			end

			Votes[k] = nil
		end
	end
end

function vote.HandleVoteEnd(id)
	if not Votes[id] then return end

	local choice = 1

	if Votes[id][2] >= Votes[id][1] then choice = 2 end

	Votes[id].Callback(choice, Votes[id].Ent)

	for k, v in pairs(player.GetAll()) do
		if not v.VoteHistory then v.VoteHistory = {} end
		v.VoteHistory[id] = nil
	end

	umsg.Start("KillVoteVGUI")
		umsg.String(id)
	umsg.End()

	Votes[id] = nil
end
