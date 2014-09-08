local sched = {}

sched.jobs = {}

sched.ctime = 0

function sched.time()
	return sched.ctime
end 

-- time to wait from now;
-- job (function)
-- arguments in varag to pass (should not be necessary!)
-- function runs in same env as old environment 
function sched.add(time, job, ...)
	local rt = sched.time() 
	local jobspec = {}
	jobspec.exetime = rt + time 
	jobspec.func = job
	jobspec.args = {...}
	table.insert(sched.jobs, jobspec)
end 

-- runs a full check function
-- returns number of jobs done 
function sched.check(dt)
	sched.ctime = sched.ctime + dt

	for i,v in pairs(sched.jobs) do 
		local ct = sched.time()
		if ct > v.exetime then 
			v.func(unpack(v.args or {}))
			sched.jobs[i] = nil
		end 
	end 

	
end 





return sched