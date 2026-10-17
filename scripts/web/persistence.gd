extends Node
var generation: int = 0
var confirmed: int = 0
var pending: bool = false
var message: String = ""
var callback
signal completed(ok: bool, message: String)

func setup() -> void:
	if OS.has_feature("web"):
		callback = JavaScriptBridge.create_callback(finish)

func confirm(text: String, path: String) -> void:
	if not OS.has_feature("web"):
		return
	generation += 1
	pending = true
	message = "Saving to browser storage…"
	if not OS.is_userfs_persistent():
		pending = false
		message = "Browser storage is temporary. Download a backup."
		completed.emit(false,message)
		return
	var window = JavaScriptBridge.get_interface("window")
	window.__soloSaveComplete = callback
	JavaScriptBridge.eval("window.__soloSaveRequest="+JSON.stringify({"generation":generation,"path":ProjectSettings.globalize_path(path),"text":text}),true)
	JavaScriptBridge.force_fs_sync()
	JavaScriptBridge.eval(FileAccess.get_file_as_string("res://scripts/web/persistence.js"),true)

func finish(arguments: Array) -> void:
	if arguments.size()!=3 or int(arguments[0])!=generation:
		return
	pending = false
	var ok: bool = bool(arguments[1])
	message = str(arguments[2])
	if ok:
		confirmed = generation
	completed.emit(ok,message)

func _exit_tree() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if(window.__soloSaveJob)window.__soloSaveJob.cancel();",true)
