# Publish Roact-Navigation - From Git to Perforce
1. **git**
	1. Update the CHANGELOG.md to list all the changes since the last tag
	2. Create new annotated tag:
		1. `$ cd roact-navigation `
		2. `$ git tag -a v0.x.y ` (Could do `$ git tag -l` to see what the most recent tags are)
		3. list the information about all the changes since the last tag
		4. `$ git push origin v0.x.y `
2. **Build and Publish**
	1. go to: https://teamcity.simulpong.com
	2. select  **Projects** in top left corner
		1. if no project are shown
			1. click on **Configure Visible Projects** and<br/>in **Hidden Projects** on the right<br/>	find **Client / Lua Apps and Tools**  and <br/>	add it to **Visible Projects** on the left
		2. in the list of projects find and open **Lua Apps and Tools**
		3. find **Roact Navigation Publish** project
		4. next to the **Run** button on the right click on **...**
		5. in the dialog that pops up select **Changes** tab
		6. under **Build Branch** select the tag you've cut in step 1 <br/>NOTE: it takes some time for git tag to propagate (up to 15 min)
		7. click on **Run Build**
		8. between **Roact Navigation Publish** and **Run** button you should see "1 build queued"
		9. the successful build will update:
			1. repo https://github.rbx.com/Roblox/rotriever-index.git
			2. with comment:<br/>"Publish roblox/roact-navigation version 0.x.y"
			3. this will allow you to use rotriever to upgrade RoactNavigation in  Branches_ClientIntegration_Client_content_LuaPackages
3. **Perforce**
	1. make sure you have not files modified in your workspace
	2. in p4v right-click on **Branches/ClientIntegration/Client/content/LuaPackages**<br/>and click on **Check Out ...** and select new changelist
	3. `$ cd Branches/ClientIntegration/Client/content/LuaPackages`
	4. run rotriever to update **only** the RoactNavigation
	5. `$ rotrieve upgrade --packages RoactNavigation`
	6. in p4v right-click on the change list and click on **Revert unchanged files**
	7. in p4v right-click on the change list and click on **Shelve files ...**
	8. follow the usual Perforce steps for review, build and submit
