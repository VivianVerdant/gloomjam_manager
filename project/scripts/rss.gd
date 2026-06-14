extends Node

func rss_string(comic: ComicDatabase) -> String:
	var items: = []
	var lang = comic.attributes.languages[0]
	var latest_update_time = 0

	
	var cannonical = comic.attributes.link.rstrip("/") + "/"
	var fileroot = comic.attributes.fileroot
	if fileroot == "":
		fileroot = cannonical
	
	for c in comic.attributes.chapters.size():
		var chapter = comic.attributes.chapters[c]
		var ct = "Chapter " + str(c+1)
		if chapter.attributes.title.has(lang) and chapter.attributes.title[lang] != "":
			ct = chapter.attributes.title[lang]
		for p in chapter.attributes.pages.size():
			var page = chapter.attributes.pages[p]

			if Time.get_unix_time_from_datetime_string(page.attributes.pubDate) > Time.get_unix_time_from_datetime_string(str(latest_update_time)):
				latest_update_time = page.attributes.pubDate

			var pt = "Page " + str(p+1)
			if page.attributes.title.has(lang) and page.attributes.title[lang] != "":
				pt = page.attributes.title[lang]
			var dict = {
				"id": page.attributes.id,
				"title": ct + " - " + pt,
				"link": cannonical + "?page=" + page.attributes.id,
				"rss_content": "",
				"pubDate": page.attributes.pubDate
			}
			match comic.attributes.rss_content:
				"thumb":
					dict.rss_content = "<h1>%s</h1><p><img src=\"%s\"></p>" % [dict.title,fileroot + page.attributes.thumbnail]
				"image":
					dict.rss_content = "<h1>%s</h1><p><img src=\"%s\"></p>" % [dict.title, fileroot + page.attributes.image_filename[lang]]
				"_":
					dict.rss_content = dict.link
			
			dict.rss_content = "<a href=\"%s\" target=\"_blank\">%s</a>" % [dict.link, dict.rss_content]
			
			items.push_back(dict)
	
	print(items)
	
	var comic_title = "Comic"
	if comic.attributes.title != "":
		comic_title = comic.attributes.title
		
	var comic_author = "Author"
	if comic.attributes.author != "":
		comic_author = comic.attributes.author
	
	var atom_string: = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" \
		+ "<feed  xmlns=\"http://www.w3.org/2005/Atom\">\n" \
		+ "\t<title>%s</title>\n" % [comic_title] \
		+ "\t<link href=\"%s\" rel=\"alternate\"/>\n" % [cannonical] \
		+ "\t<link href=\"%s\" rel=\"self\"/>\n" % [fileroot.path_join("atom.xml")] \
		+ "\t<id>%s</id>\n" % [cannonical] \
		+ "\t<updated>%s</updated>\n" % [latest_update_time + "+00:00"]
	
	for item in items:
		var content_string = item.rss_content.replace("&", "&amp;") \
				.replace("'", "&apos;") \
				.replace("\"","&quot;") \
				.replace("<", "&lt;") \
				.replace(">", "&gt;")
		
		var title_string = "\t\t\t<title>%s</title>\n" % [item.title]
		var link_string = "\t\t\t<link href=\"%s\" rel=\"alternate\"/>\n" % [item.link]
		var id_string = "\t\t\t<id>%s</id>\n" % [item.link]
		var author_string = "\t\t\t<author><name>%s</name></author>\n" % [comic_author]
		var desc_string = "\t\t\t<content type=\"html\">\n\t\t\t\t%s\n\t\t\t</content>\n" % [content_string]
		var pubdate_string = "\t\t\t<updated>%s+00:00</updated>\n" % [item.pubDate]
		var inside_string = title_string + link_string + id_string + author_string + desc_string + pubdate_string
		var xml_string = "\t\t<entry>\n%s\t\t</entry>\n" % [inside_string]
		atom_string += xml_string
	
	atom_string += "</feed>"
	
	return atom_string

func write_rss(comic: ComicDatabase) -> Error:
	var string = rss_string(comic)

	var atom = FileAccess.open(GlobalSettings.export_path.path_join("atom.xml"), FileAccess.WRITE)
	if atom:
		atom.store_string(string)
		Console.print("Created atom.xml")
		return Error.OK
	else:
		var error = atom.get_error()
		Console.warn("!Error saving RSS: ", error_string(error))
		return error
