-- Generate static blog; remade in Lua

-- Variables to modify content
indexSwitch = true -- Display newest file first in index
includeRecent = true -- Display recent posts in side-bar; useful for blogs, not books
paginateAfter = 5 -- Number of posts to begin paginating after (on index); 0 for no pagination
sendTo = "" -- Where output will be placed (directory used for blog/book); ends in /; leave blank for current directory
source = "" -- Source of blog/book (single file; generally something like "source.txt")
blogName = "Blog" -- Title to be displayed on index page
encoding = "utf-8" -- Text encoding; generally utf-8 for English content

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
		total = "<!DOCTYPE html><html><head><title>" .. blogName .. ": " .. n .. "</title><meta charset = \"" .. encoding .. "\" /></head><body>"
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
		page = "<!DOCTYPE html><html><head><title>" .. blogName .. "</title><meta charset = \"" .. encoding .. "\" /></head><body>"
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
	individual = "<!DOCTYPE html><html><head><title>" .. title .. "</title><meta charset = \"" .. encoding .. "\" /></head><body><div id = \"title\">" .. title .. "</div><div id = \"author\">" .. author .. "</div><div id = \"date\">" .. date .."</div><div id = \"post\">" .. post .. "</div><br><div>" .. main .. "</div></body></html>"
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
