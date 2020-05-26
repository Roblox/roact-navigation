# Publish Roact-Navigation - From Git to Perforce
1. **git**
	1. Update the CHANGELOG.md to list all the changes since the last tag
	2. Update version number in rotriever.toml
	3. Generate new tag in roact-navigationr repository (pick ONE):
		A. Run "rotrieve publish" to automatically generate the tag.
		B. *(OR)* Manually create a new annotated tag:
			1. `cd roact-navigation `
			2. `git tag -a v0.x.y ` (Number should match rotriever.toml; use `git tag -l` to see all tags)
			3. Copy-paste the changelog entry into the tag annotation.
			4. `git push origin v0.x.y `
2. **Publish to Roblox internal artifact repository**
	1. go to: https://teamcity.simulpong.com/buildConfiguration/LuaAppsAndTools_CacheRotrieverPackage
	2. Click run.
	3. Put in the RN repository, e.g. `GitHub.com/roblox/roact-navigation`
	4. Put in your new version number, e.g. `0.2.7`. (It will prepend 'v' automatically for the tag.)
	5. Click "Run Build".
3. **lua-apps repository**
	1. Make sure you have no files modified in your workspace. Stash changes if needed.
	2. `cd <repo path>/content/LuaPackages`
	4. Run rotriever to update **only** the RoactNavigation `$ rotrieve upgrade --packages RoactNavigation`
	5. Sanity-check the changes and make sure only files under LuaPackages have changed.
	6. Follow the usual GH rules for review and commit.
