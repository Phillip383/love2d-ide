extends Node

var client := StreamPeerTCP.new()
var lsp_handle = {}
var debug_output = []
# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the LSP
	#TODO: change this to a path configured by the application...
	lsp_handle = OS.execute_with_pipe("D:\\dev\\tooling\\lua-lsp\\bin\\lua-language-server.exe", ["--log=debug"])
	if lsp_handle["pid"] == -1:
		print("LSP failed to Execute")
	else:
		print("LSP running pid ", lsp_handle["pid"])

func send_initialize_request(project_root: String):
	var request = {
		"jsonrpc": "2.0",
		"id": 1,
		"method": "initialize",
		"params": {
			"processId": 1234,
			"rootUri": project_root,
			"capabilities": {}
		}
	}
	send_json(request)
	
func send_json(data):
	var json_string = JSON.stringify(data)
	client.put_data((json_string + "\n").to_utf8_buffer())
	

func send_completion_request(current_doc_path: String, position: Vector2):

	var request = {
	"jsonrpc": "2.0",
	"id": 3,
	"method": "textDocument/completion",
	"params": {
		"textDocument": { "uri": current_doc_path },
		"position": { "line": position.x, "character": position.y }
	}
}
	send_json(request)

func send_hover_request(path_to_script: String, position: Vector2):
	# TODO: change this to use the current open file and cursor position...
	var request = {
  "jsonrpc": "2.0",
  "id": 2,
  "method": "textDocument/hover",
  "params": {
	"textDocument": { "uri": path_to_script },
	"position": { "line": position.x, "character": position.y }
  }
}
	send_json(request)

func handle_completion_response(_response):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _notification(what):
	if what == NOTIFICATION_CRASH:
		print("Killing LSP")
		OS.kill(lsp_handle["pid"])
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Killing LSP")
		OS.kill(lsp_handle["pid"])
