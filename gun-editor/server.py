import BaseHTTPServer
import time
import sys
import cgi

HOST_NAME	= "localhost"
PORT_NUMBER	= 9000

file_name = sys.argv[1]

class Handler(BaseHTTPServer.BaseHTTPRequestHandler):
	def do_GET(self):
		self.send_response(200)
		self.send_header("Content-type", "text/html")
		self.end_headers()

		self.wfile.write("Response!")

	def do_POST(self):
		ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
		if ctype == 'multipart/form-data':
			postvars = cgi.parse_multipart(self.rfile, pdict)
		elif ctype == 'application/x-www-form-urlencoded':
			length = int(self.headers.getheader('content-length'))
			postvars = cgi.parse_qs(self.rfile.read(length), keep_blank_values=1)
		else:
			postvars = {}

		data = postvars['data'][0]
		with open(file_name, 'w') as f:
			f.write("define " + data)

		print time.asctime(), "Wrote file - %s:%s" % (HOST_NAME, PORT_NUMBER)

		self.send_response(200)
		self.send_header("Content-type", "text/html")
		self.send_header('Access-Control-Allow-Origin', '*')
		self.end_headers()

server_class = BaseHTTPServer.HTTPServer

httpd = server_class((HOST_NAME, PORT_NUMBER), Handler)
print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
try:
	httpd.serve_forever()
except KeyboardInterrupt:
	pass

httpd.server_close()
print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)
