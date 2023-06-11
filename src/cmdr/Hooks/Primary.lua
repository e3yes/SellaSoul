return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "Admin" and context.Executor.UserId ~= 737746186 then
			return "You dont have Permission to use this command"
		end
	end)
end