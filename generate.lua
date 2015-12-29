--[[
	Generate static blog; remade in Lua
	Modify variables (below) to suit your needs
	Stylesheets not provided; examples may be added later
	Written once without refactoring; will be inefficient; features much repetition
	Intended only as an example; not full-featured or meant for full release
	
	Usage:
		Source file setup:
			Date
			Author
			Title
			Post content
			New post date
			New post author
			New post title
			New post content
			...
		
		Linux/UNIX (OS X?) execution:
			lua /path/to/generate.lua
			
		Windows execution:
			Not tested
]]--


-- Variables to modify content
indexSwitch = true -- Display newest file first in index (true, false)
includeRecent = true -- Display recent posts in individual posts; useful for blogs, not books (true, false)
paginateAfter = 5 -- Number of posts to begin paginating after (on index); 0 for no pagination (e.g. 0, 5, 7, 15 ...)
sendTo = "/home/robben/Documents/Website/post/" -- Where output will be placed (directory used for blog/book); ends in /; leave blank for current directory (e.g. "/home/user/Blog/")
source = "source.txt" -- Source of blog/book (single file; generally something like "source.txt"); include directory (e.g. "/home/user/Blog/source.txt")
blogName = "Blog" -- Title to be displayed on index page (e.g. "My Blog")
encoding = "utf-8" -- Text encoding; generally utf-8 for English content (e.g. "utf-8")
indexStyle = "index.css" -- Stylesheet for index files; already at sendTo, so generally only a file name or in a directory for styles (e.g. "index.css")
postStyle = "post.css" -- Stylesheet used on each post; see above (e.g. "post.css")
addHead = "<link href = \"https://fonts.googleapis.com/css?family=Roboto\" rel = \"stylesheet\" type = \"text/css\">" -- Add other things (in HTML), such as online fonts, theme colors, or JavaScript libraries to the <head> tag (e.g. "<link href = \"somewebsite ...\" />")

-- Generate pages of index when pagination enabled
function buildPages(source)
	toMake = {}
	if not indexSwitch then
		for q = 4, #source, 4 do
			link = q/4
			table.insert(toMake, "<div><a href = \"" .. link .. ".html\">" .. source[q - 1] .. "</a> <span>" .. source[q - 3] .. "</span></div>")
		end
	else
		for q = #source, 1, -4 do
			link = q/4
			table.insert(toMake, "<div><a href = \"" .. link .. ".html\">" .. source[q - 1] .. "</a> <span>" .. source[q - 3] .. "</span></div>")
		end
	end
	
	pages = math.floor((#source/4) / paginateAfter)
	if (#source/4) % paginateAfter > 0 then pages = pages + 1 end
	
	print(pages .. " pages made")

	counter = 0
	
	for n = 1, pages do
		total = "<!DOCTYPE html><html><head><title>" .. blogName .. ": " .. n .. "</title><meta charset = \"" .. encoding .. "\" /><link type = \"text/css\" rel = \"stylesheet\" href = \"" .. indexStyle .. "\" />" .. addHead .. "</head><body>"
		for j = 1, paginateAfter do
			counter = counter + 1
			if toMake[counter] then
				total = total .. toMake[counter]
			else
				total = total .. "<div class = \"noDisplay\" style = \"visibility: hidden;\">no content</div>"
			end
		end
		if n == 1 then
			newFile = io.open(sendTo .. "index.html", "w")
		else
			newFile = io.open(sendTo .. "index" .. n .. ".html", "w")
		end
		
		total = total .. "<ul>"
		
		for k = 1, pages do
			if k == n then
				total = total .. "<li>" .. k .. "</li>"
			elseif k == 1 then
				total = total .. "<li><a href = \"index.html\">" .. k .. "</a></li>"
			else
				total = total .. "<li><a href = \"index" .. k .. ".html\">" .. k .. "</a></li>"
			end
		end
		
		total = total .. "</ul></body></html>"
		io.input(newFile)
		newFile:write(total)
		newFile:close()
	end
end

-- Make an index page to include links to content
function indexAll(source)
	if paginateAfter > 0 and paginateAfter % 1 == 0 and #source > paginateAfter then -- Pagination
		buildPages(source)
	else -- No pagination
		toPage = {}
		page = "<!DOCTYPE html><html><head><title>" .. blogName .. "</title><meta charset = \"" .. encoding .. "\" /><link type = \"text/css\" rel = \"stylesheet\" href = \"" .. indexStyle .. "\" />" .. addHead .. "</head><body>"
		if not indexSwitch then
			for q = 1, #source, 4 do
				table.insert(toPage, "<div><a href = \"" .. q/4 .. ".html\">" .. source[q + 2] .. "</a> <span>" .. source[q] .. "</span></div>")
			end
		else
			for q = #source, 1, -4 do
				table.insert(toPage, "<div><a href = \"" .. q/4 .. ".html\">" .. source[q - 1] .. "</a> <span>" .. source[q - 3] .. "</span></div>")
			end
		end
		for n = 1, #toPage do
			page = page .. toPage[n]
		end
		page = page .. "</body></html>"
		local file = io.open(sendTo .. "index.html", "w")
		io.input(file)
		file:write(page)
		file:close()
	end
	
end

-- Make individual pages with content
function makeContent(date, author, title, post, number, main)
	individual = "<!DOCTYPE html><html><head><title>" .. title .. "</title><meta charset = \"" .. encoding .. "\" /><link type = \"text/css\" rel = \"stylesheet\" href = \"" .. postStyle .. "\" />" .. addHead .. "</head><body><div id = \"title\">" .. title .. "</div><div id = \"author\">" .. author .. "</div><div id = \"date\">" .. date .."</div><div id = \"post\">" .. post .. "</div><br><div>" .. main .. "</div></body></html>"
	local file = io.open(sendTo .. number .. ".html", "w")
	io.input(file)
	file:write(individual)
	file:close()
end

-- Open the file to be used in text generation
file = io.open(source, "r")
io.input(file)
content = io.read("*all") -- Stores all contents of file in variable "content"

-- Create a table of each line in the file
tab = {}
for i in string.gmatch(content, "([^\n]+)") do -- Separate string at newline characters
	table.insert(tab, i)
end

-- Add recent posts to individual segments
if includeRecent then
	main = "<div>Recent posts</div>"
	for m = #tab, #tab - 16, -4 do
		if tab[m] then
			main = main .. "<div><a href = \"" .. m/4 .. ".html\">" .. tab[m - 1] .. "</a> <span>" .. tab[m - 3] .. "</span></div>"
		end
	end
else
	main = ""
end

-- Get unique sections of content ("posts," "chapters," etc.)
for i = 1, #tab do
	if (i % 4 == 0) then
		makeContent(tab[i - 3], tab[i - 2], tab[i - 1], tab[i], i/4, main)
	end
end

indexAll(tab)
