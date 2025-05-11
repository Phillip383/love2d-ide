extends Node

var client := StreamPeerTCP.new()
var lsp_pid = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the LSP
	#TODO: change this to a path configured by the application...
	lsp_pid = OS.execute("D:\\dev\\tooling\\lua-lsp\\bin\\lua-language-server.exe", ["--socket=5050"], false)
	if lsp_pid == -1:
		print("LSP failed to Execute")
	else:
		print("LSP running pid ", lsp_pid)
		connect_to_lsp("127.0.0.1", 5050)

func connect_to_lsp(ip: String, port: int):
	var err = client.connect_to_host(ip, port)
	if err == OK:
		print("Connected to Lua LSP Server!")
	else:
		print("Failed to connect:", err)

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
	var json_string = JSON.print(data)
	client.put_data((json_string + "\n").to_utf8())
	

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if client.get_available_bytes() > 0:
		var response = client.get_string(client.get_available_bytes())
		print("LSP Respone:", response)

func _notification(what):
	if what == NOTIFICATION_CRASH:
		print("Killing LSP")
		OS.kill(lsp_pid)
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		print("Killing LSP")
		OS.kill(lsp_pid)
