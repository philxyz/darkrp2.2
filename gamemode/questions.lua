Question = {}
Questions = {}

function ccDoQuestion(ply, cmd, args)
	if not Questions[args[1]] or not tonumber(args[2]) then return end

	Questions[args[1]]:HandleNewQuestion(ply, tonumber(args[2]))
end
concommand.Add("ans", ccDoQuestion)

function Question:HandleNewQuestion(ply, response)
	if response == 1 or response == 2 then
		self.yn = response
	end

	ques.HandleQuestionEnd(self.ID, false)
end

ques = {}

function ques:Create(question, quesid, ent, delay, callback, fromPly, toPly)
	local newques = {}
	for k, v in pairs(Question) do newques[k] = v end

	newques.ID = quesid
	newques.Callback = callback
	newques.Ent = ent
	newques.Initiator = fromPly
	newques.Target = toPly

	newques.yn = 0

	Questions[quesid] = newques

	umsg.Start("DoQuestion", ent)
		umsg.String(question)
		umsg.String(quesid)
		umsg.Float(delay)
	umsg.End()

	timer.Create(quesid .. "timer", delay, 1, function() ques.HandleQuestionEnd(quesid, true) end)
end

function ques.DestroyQuestionsWithEnt(ent)
	for k, v in pairs(Questions) do
		if v.Ent == ent then
			umsg.Start("KillQuestionVGUI", v.Ent)
				umsg.String(v.ID)
			umsg.End()

			Questions[k] = nil
		end
	end
end

function ques.HandleQuestionEnd(id, timeIsUp)
	if not Questions[id] then return end
	local q = Questions[id]

	q.Callback(q.yn, q.Ent, q.Initiator, q.Target)

	if timeIsUp then Questions[id] = nil end
end
