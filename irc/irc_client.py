import sys
import socket
import string

HOST="irc.freenode.net"
PORT=6667
NICK="MauBot"
IDENT="maubot"
REALNAME="MauritsBot"
readbuffer=""

s=socket.socket( )
s.connect((HOST, PORT))
s.send("NICK %s\r\n" % NICK)
s.send("USER %s %s bla :%s\r\n" % (IDENT, HOST, REALNAME))


sys.path.insert(0, 'plugins')

def load_plugin(name):
    mod = __import__("%s" % name)
    return mod

def call_plugin(name, *args, **kwargs):
    plugin = load_plugin(name)
    plugin.plugin_main(*args, **kwargs)

while 1:
    readbuffer = readbuffer + s.recv(1024)
    temp = string.split(readbuffer, "\n")
    readbuffer = temp.pop( )

    for line in temp:
        line = string.rstrip(line)
        line = string.split(line)
        print line
        words = "helloworld" #string.split(line, " ")
        call_plugin(words, line)