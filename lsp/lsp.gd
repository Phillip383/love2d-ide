extends Node

var client := StreamPeerTCP.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the LSP
	#TODO: change this to a path configured by the application...
	var pid = OS.execute("D:\\dev\\tooling\\lua-lsp\\bin\\lua-language-server.exe", ["--socket=5050"], false)
	if pid == -1:
		print("LSP failed to Execute")
	else:
		print("LSP running pid ", pid)
		connect_to_lsp("127.0.0.1", 5050)

func connect_to_lsp(ip: String, port: int):
	var err = client.connect_to_host(ip, port)
	if err == OK:
		print("Connected to Lua LSP Server!")
	else:
		print("Failed to connect:", err)

func send_initialize_request():
	var request = {
		"jsonrpc": "2.0",
		"id": 1,
		"method": "initialize",
		"params": {
			"processId": 1234,
			"rootUri": "file:///path/to/project",
			"capabilities": {}
		}
	}
	send_json(request)
	
func send_json(data):
	var json_string = JSON.stringify(data)
	client.put_data((json_string + "\n").to_utf8_buffer())
	

func send_hover_request():
	# TODO: change this to use the current open file and cursor position...
	var request = {
  "jsonrpc": "2.0",
  "id": 2,
  "method": "textDocument/hover",
  "params": {
	"textDocument": { "uri": "file:///path/to/script.lua" },
	"position": { "line": 5, "character": 10 }
  }
}
	send_json(request)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if client.get_available_bytes() > 0:
		var response = client.get_string(client.get_available_bytes())
		print("LSP Respone:", response)
