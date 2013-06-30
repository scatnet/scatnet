function commit = git_hash()
	[temp,commit] = system('git show --format=%H');
end