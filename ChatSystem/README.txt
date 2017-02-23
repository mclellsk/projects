Chat System (C#)
----------------
This project was written with the intent of teaching myself about the C# networking libraries. It contains 3 specific components: the chat client, the chat server, and the chat library. This project allows you to setup a chat server that listens on port 13000. The client program attempts to establish a connection to the ip provided. Once the connection is accepted, the client can send the server messages which are encrypted using AES symmetric encryption. This is established per client using RSA encryption to send the client the AES key. All messages received by the server are broadcast to all clients connected at the time.

INSTALLATION:

Open the Chat Project solution located in the Chat Client folder. Build the server project first, then run the server executable. Once the server is listening, build the chat client and run it. In the Windows Form, change the IP address to that of the server. If you use 127.0.0.1 you can connect to the server locally. This project has only been tested on a local connection, it is possible you may run into connectivity issues so check your firewall and open the port 13000.