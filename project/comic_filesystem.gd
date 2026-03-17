extends Node

var database: ComicDatabase
var root_path: String
var dir

func read_from_filesystem(_db: ComicDatabase, _root: String) -> void:
	pass

func write_to_filesystem(db: ComicDatabase, root: String) -> void:
	if not db or not root:
		return
	database = db
	root_path = root

	# check if comic folder exists
	dir = DirAccess.open(root_path)
	if not dir:
		return
	
	if dir.dir_exists(database.id):
		Console.print("directory", database.id, "exists")
	else:
		Console.print("directory", database.id, "does not exists; Creating it.")
		dir.make_dir(database.id)
		
	dir.change_dir(database.id)
	Console.print("opened directory", database.id)
	
	for chapter in database.chapters:
		if dir.dir_exists(chapter.id):
			Console.print("directory", chapter.id, "exists")
		else:
			Console.print("directory", chapter.id, "does not exists; Creating it.")
			dir.make_dir(chapter.id)
		
		dir.change_dir(chapter.id)
		Console.print("opened directory", chapter.id)
		write_chapter_files()
		
		for page in chapter.pages:
			if dir.dir_exists(page.id):
				Console.print("directory", page.id, "exists")
			else:
				Console.print("directory", page.id, "does not exists; Creating it.")
				dir.make_dir(page.id)
			
			dir.change_dir(page.id)
			Console.print("opened directory", page.id)
			write_page_files()
			dir.change_dir("..")
		
		dir.change_dir("..")

func write_chapter_files() -> void:
	pass

func write_page_files() -> void:
	pass
