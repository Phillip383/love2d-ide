extends Node

var lsp_handle = {}
var response_thread: Thread

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the LSP
	#TODO: change this to a path configured by the application...
	lsp_handle = OS.execute_with_pipe("D:\\dev\\tooling\\lua-lsp\\bin\\lua-language-server.exe", ["--log=debug"])
	if lsp_handle["pid"] == -1:
		print("LSP failed to Execute")
	else:
		print("LSP running pid ", lsp_handle["pid"])

		send_initialize_request(Global.project_path)

func send_initialize_request(project_root: String):
	var request = {
		"jsonrpc": "2.0",
		"id": 1,
		"method": "initialize",
		"params": {
			"processId": OS.get_process_id(),
			"rootUri": project_root,
			"capabilities": {
				"textDocument":{
					"completionItem":{
						"snippetSupport": true
					}
				}
			}
		},
		"clientInfo":{
			"name": "Love2D IDE",
			"version": "0.2.0"
		}
	}
	var lsp_stdio = lsp_handle["stdio"]
	# Send Request
	var request_text = JSON.stringify(request)
	var header = "Content-Length: %d \r\n\r\n" % [request_text.to_utf8_buffer().size()]
	lsp_stdio.store_string(header + request_text)
	lsp_stdio.flush()

	var callable = Callable(self, "read_pipe")
	response_thread = Thread.new()
	var _err = response_thread.start(callable, Thread.PRIORITY_HIGH)


# Read Response
func read_pipe():
	print("reading pipe")
	var lsp_stdio = lsp_handle["stdio"]
	print(lsp_stdio.get_line())

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
