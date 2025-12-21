extends Node
# Save/Load system using JSON method

# "user" prefix instead of "res" to allow for read/write actions by the game when it is exported
const save_location = "user://SaveFile.json"

# All data that is being saved
var contents_to_save: Dictionary = {
	"progress_bar_value": 0.0,
	"new_data_to_save": false
}

func _ready() -> void:
	# Call _load() in _ready() to ensure game data is loaded as soon as possible
	_load()

# Saving function
func _save():
	# Variable to WRITE data from the save file (encrypted)
	var file = FileAccess.open_encrypted_with_pass(save_location, FileAccess.WRITE, "92B455hF4")
	# Use "store_var" to save the "contents_to_save" variable inside the save file
	# We duplicate to ensure we are copying the data and not using the original directly
	file.store_var(contents_to_save.duplicate())
	# Close the file after writing the data to it
	file.close()

# Loading function
func _load():
	# Check if the file exists in the save location to avoid crashes
	if FileAccess.file_exists(save_location):
		# Variable to READ data from the save file (encrypted)
		var file = FileAccess.open_encrypted_with_pass(save_location, FileAccess.READ, "92B455hF4")
		# Temporary variable to house data inside the save file
		var data = file.get_var()
		# Close the file as we can just use the "data" variable to refer to saved data
		file.close()
		
		# Create a duplicate of the data and assign it to a new variable
		var save_data = data.duplicate()
		# Set the variables in the script to the data on the save file
		contents_to_save.progress_bar_value = save_data.progress_bar_value
		# Add more data to save
		contents_to_save.new_data_to_save = save_data.new_data_to_save
