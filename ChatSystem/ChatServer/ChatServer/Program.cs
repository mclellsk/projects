using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Net;
using System.Net.Sockets;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using ChatLibrary;

namespace ChatServer
{
    class Program
    {
        private static int _port = 13000;
        private static IPAddress _addr = IPAddress.Any;
        private static IPEndPoint _ep;

        public static ManualResetEvent allDone = new ManualResetEvent(false);
        public static ManualResetEvent disconnectDone = new ManualResetEvent(false);

        public static List<UserInfo> clients = new List<UserInfo>();
        public static Dictionary<int, Thread> threads = new Dictionary<int, Thread>();

        public static int nextClientIndex = 0;

        public class StateObject
        {
            public UserInfo user = null;
            public byte[] buffer = new byte[1024];
            public ManualResetEvent recvDone = new ManualResetEvent(false);
            public ManualResetEvent sendDone = new ManualResetEvent(false);
        }

        static void Main(string[] args)
        {
            _ep = new IPEndPoint(_addr, _port);

            //Start listener thread
            Thread listener = new Thread(Listen);
            listener.Start();
        }

        private static void AddUser(UserInfo client)
        {
            //Keep incrementing the client index until one is selected that is not being used
            while (clients.FindIndex(p => p.clientId == nextClientIndex) >= 0)
                nextClientIndex = (nextClientIndex + 1) % int.MaxValue;

            client.clientId = nextClientIndex;
            nextClientIndex++;
            clients.Add(client);
            CreateThread(client);
        }

        private static void RemoveUser(Socket soc)
        {
            var client = clients.Find(p => p.soc == soc);
            if (client != null)
            {
                clients.Remove(client);
                threads[client.clientId].Abort();
            }
        }

        private static void CreateThread(UserInfo client)
        {
            var t = new Thread(Receiving);
            threads.Add(client.clientId, t);
            t.Start(client.soc);
            Console.WriteLine("Client receiving thread started.");
        }

        private static void Receiving(object client)
        {
            ManualResetEvent recvDone = new ManualResetEvent(false);
            while (true)
            {
                recvDone.Reset();
                StateObject state = new StateObject();
                state.user = new UserInfo((Socket)client);
                state.recvDone = recvDone;
                state.user.soc.BeginReceive(state.buffer, 0, state.buffer.Length, 0, new AsyncCallback(ReadCallback), state);
                recvDone.WaitOne();                  
            }
        }

        private static void Listen()
        {
            Socket listener = new Socket(_ep.Address.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

            try
            {
                listener.Bind(_ep);
                listener.Listen(10);

                Console.WriteLine("Server:" + _ep.Address + " Port:" + _ep.Port);

                while (true)
                {
                    allDone.Reset();
                    //Listen for connection
                    Console.WriteLine("Listening for connection...");
                    listener.BeginAccept(new AsyncCallback(AcceptCallback), listener);
                    allDone.WaitOne();
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void AcceptCallback(IAsyncResult ar)
        {
            try
            {
                Socket listener = (Socket)ar.AsyncState;
                var client = listener.EndAccept(ar);
                StateObject state = new StateObject();
                state.user = new UserInfo(client);
                state.recvDone = new ManualResetEvent(false);
                client.BeginReceive(state.buffer, 0, state.buffer.Length, 0, new AsyncCallback(UserCallback), state);
                state.recvDone.WaitOne();
                Console.WriteLine("Connected Client " + ((IPEndPoint)client.RemoteEndPoint).Address);
                allDone.Set();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void UserCallback(IAsyncResult ar)
        {
            var state = (StateObject)ar.AsyncState;
            var client = state.user.soc;
            try
            {
                int received = client.EndReceive(ar);
                if (received > 0)
                {
                    //Receive the data as a serializable object that contains the public key 
                    //and the name of the sender.
                    var rsaKey = Chat.DeserializeTo<RSAParameters>(state.buffer);

                    //Get the name of the user, set up the public key for RSA, the IV and Key for AES.
                    //Send those 3 values back to the client.
              
                    var user = new UserInfo(client);
                    user.aesIV = Chat.AESGenerateIV();
                    user.aesKey = Chat.AESGenerateKey();
                    //user.name = initUser.name;

                    //Set RSA public key
                    user.rsaPublicKey = rsaKey;
                    Console.WriteLine("rsa length:" + user.rsaPublicKey.Modulus.Length * 8);
                    Console.WriteLine("aeskey length:" + user.aesKey.Length * 8);
                    Console.WriteLine("aesiv length:" + user.aesIV.Length * 8);

                    //Send the aes key encrypted
                    var aesEncryptedKey = Chat.RSAEncrypt(user.aesKey, user.rsaPublicKey);
                    //Send the aes init vector encrypted
                    var aesEncryptedIV = Chat.RSAEncrypt(user.aesIV, user.rsaPublicKey);

                    SendAES(user.soc, aesEncryptedKey, aesEncryptedIV);
                    
                    AddUser(user);
                }
                state.recvDone.Set();
            }
            catch (Exception e)
            {
                //Close connection
                Console.WriteLine(e.ToString());
            }
        }

        private static void ReadCallback(IAsyncResult ar)
        {
            var state = (StateObject)ar.AsyncState;
            var client = state.user.soc;
            try
            {
                int received = client.EndReceive(ar);
                state.recvDone.Set();
                if (received > 0)
                {
                    //TODO: format into a message string, send that to the clients
                    var user = clients.Find(p => p.soc == client);
                    if (user != null)
                    {
                        var msg = Chat.ReceiveMessage(state.buffer, user.aesKey, user.aesIV);
                        Console.WriteLine(msg.message);

                        //Send data to all other clients, including sender
                        BroadcastMessage(msg);
                    }
                }
            }
            catch (SocketException e)
            {
                //Close connection
                RemoveUser(client);
                Console.WriteLine("Connection to {0} forcibly closed by client.", ((IPEndPoint)client.RemoteEndPoint).Address);
            }
        }

        private static void BroadcastMessage(ChatMessage msg)
        {
            for (int i = 0; i < clients.Count; i++)
            {
                var data = Chat.SendMessage(msg, clients[i].aesKey, clients[i].aesIV);
                Send(clients[i].soc, data);
            }
        }

        private static void Send(Socket client, byte[] data)
        {
            client.BeginSend(data, 0, data.Length, 0, new AsyncCallback(SendCallback), client);
        }

        private static void SendCallback(IAsyncResult ar)
        {
            try
            {
                Socket client = (Socket)ar.AsyncState;
                int sent = client.EndSend(ar);
                Console.WriteLine("Data sent to client {0}", ((IPEndPoint)client.RemoteEndPoint).Address);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void SendAES(Socket client, byte[] encryptedKey, byte[] encryptedIV)
        {
            StateObject stateKey = new StateObject();
            stateKey.user = new UserInfo(client);
            stateKey.sendDone = new ManualResetEvent(false);
            client.BeginSend(encryptedKey, 0, encryptedKey.Length, 0, new AsyncCallback(SendAESCallback), stateKey);
            stateKey.sendDone.WaitOne();
            Console.WriteLine("AES {0}-bit key sent to {1}", encryptedKey.Length * 8, ((IPEndPoint)client.RemoteEndPoint).Address);

            StateObject stateIV = new StateObject();
            stateIV.user = new UserInfo(client);
            stateIV.sendDone = new ManualResetEvent(false);
            client.BeginSend(encryptedIV, 0, encryptedIV.Length, 0, new AsyncCallback(SendAESCallback), stateIV);
            stateIV.sendDone.WaitOne();
            Console.WriteLine("AES {0}-bit iv sent to {1}", encryptedIV.Length * 8, ((IPEndPoint)client.RemoteEndPoint).Address);
        }

        private static void SendAESCallback(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                int sent = state.user.soc.EndSend(ar);
                state.sendDone.Set();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void Disconnect(Socket client)
        {
            var i = clients.FindIndex(p => p.soc == client);
            if (i >= 0)
                clients.RemoveAt(i);

            client.BeginDisconnect(true, new AsyncCallback(DisconnectCallback), client);
            disconnectDone.WaitOne();
        }

        private static void DisconnectCallback(IAsyncResult ar)
        {
            try
            {
                Socket client = (Socket)ar.AsyncState;
                client.EndDisconnect(ar);
                disconnectDone.Set();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }
    }
}
