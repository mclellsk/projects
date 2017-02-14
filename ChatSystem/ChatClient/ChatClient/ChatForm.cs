using System;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Sockets;
using System.Windows.Forms;
using System.Security.Cryptography;
using ChatLibrary;

namespace ChatClient
{
    public partial class formMain : Form
    {
        public class StateObject
        {
            public UserInfo user = null;
            public byte[] buffer = new byte[1024];
            public ManualResetEvent recvDone = new ManualResetEvent(false);
            public StringBuilder sb = new StringBuilder();
        }

        public const string SYS_NAME = "SYSTEM";

        private static ManualResetEvent connectDone = new ManualResetEvent(false);
        private static ManualResetEvent sendDone = new ManualResetEvent(false);
        private static ManualResetEvent receiveDone = new ManualResetEvent(false);

        public static Socket server = new Socket(0, SocketType.Stream, ProtocolType.Tcp);

        public static Thread threadReceive;

        public static formMain instance;

        public static string name = "";

        public static RSAParameters privateKey;
        public static byte[] aesKey;
        public static byte[] aesIV;

        public delegate void ResultHandler(string sender, string msg);
        public static ResultHandler Result;
        public static Action Connection;

        public formMain()
        {
            if (instance == null)
                instance = this;

            InitializeComponent();

            btnSend.Click += BtnSend_Click;
            btnConnect.Click += BtnConnect_Click;

            Result = new ResultHandler(Output);
            Connection = new Action(SetConnected);
        }

        private void SetConnected()
        {
            if (server != null)
            {
                btnSend.Enabled = server.Connected;
                btnConnect.Text = (server.Connected) ? "Disconnect" : "Connect";
            }
            else
            {
                btnSend.Enabled = false;
                btnConnect.Text = "Connect";
            }
        }

        private void BtnConnect_Click(object sender, EventArgs e)
        {
            if (!server.Connected)
            {
                if (String.IsNullOrEmpty(txtIP.Text))
                {
                    Output(SYS_NAME, "Enter a valid connection.");
                    return;
                }

                //Establish connection to ip
                Connect(IPAddress.Parse(txtIP.Text));
                btnConnect.Text = "Disconnect";
                btnSend.Enabled = true;
            }
            else
            {
                Disconnect();
                btnSend.Enabled = false;
                btnConnect.Text = "Connect";
            }
        }

        private void BtnSend_Click(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(txtMessage.Text))
                return;

            SendMessage(server, txtMessage.Text);
            txtMessage.ResetText();
        }

        private void Output(string sender, string message)
        {
            txtOutput.AppendText(sender + ": " + message);
            txtOutput.AppendText("\n");
        }

        private void Connect(IPAddress ip)
        {
            try
            {
                server = new Socket(ip.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
                var ep = new IPEndPoint(ip, 13000);
                Output(SYS_NAME, "Establishing connection...");
                server.BeginConnect(ep, new AsyncCallback(ConnectCallback), server);
                connectDone.WaitOne();
            }
            catch (Exception e)
            {
                Output(SYS_NAME, e.ToString());
            }
        }

        private static void ConnectCallback(IAsyncResult ar)
        {
            try
            {
                server = (Socket)ar.AsyncState;
                server.EndConnect(ar);
                //Create a private and public key for RSA
                var rsaKey = Chat.GetRSAKeys();
                privateKey = rsaKey[0];
                //Send RSA public key to server
                var byteKey = Chat.ConvertToBinary(rsaKey[1]);
                Send(server, byteKey);
                //Receive key for AES through an RSA encrypted message
                ReceiveAESKey(server);

                connectDone.Set();
                instance.Invoke(Result, SYS_NAME, "Connected to " + ((IPEndPoint)server.RemoteEndPoint).Address);

                threadReceive = new Thread(ThreadReceiver);
                threadReceive.Start();
            }
            catch
            {
                connectDone.Set();
                instance.Invoke(Result, SYS_NAME, "Connection to server failed.");
            }
        }

        private static void ThreadReceiver()
        {
            while (true)
            {
                receiveDone.Reset();
                Receive(server);
                receiveDone.WaitOne();
            }
        }

        private static void SendMessage(Socket soc, string message)
        {
            var msg = new ChatMessage(name, message);
            var bMsg = Chat.SendMessage(msg, aesKey, aesIV);
            Send(soc, bMsg);
        }

        private static void Send(Socket soc, byte[] bytes)
        {
            soc.BeginSend(bytes, 0, bytes.Length, 0, new AsyncCallback(SendCallback), soc);
            sendDone.WaitOne();
        }

        private static void SendCallback(IAsyncResult ar)
        {
            try
            {
                Socket client = (Socket)ar.AsyncState;
                int bytes = client.EndSend(ar);
                sendDone.Set();
            }
            catch (Exception e)
            {
                //Error 
                Console.WriteLine(e.ToString());
            }
        }

        private static void Receive(Socket server)
        {
            try
            {
                StateObject state = new StateObject();
                state.user = new UserInfo(server);
                server.BeginReceive(state.buffer, 0, state.buffer.Length, 0, new AsyncCallback(ReceiveCallback), state);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void ReceiveCallback(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                Socket server = state.user.soc;
                int read = server.EndReceive(ar);
                if (read > 0)
                {
                    var msg = Chat.ReceiveMessage(state.buffer, aesKey, aesIV);
                    Console.WriteLine("Message received.");
                    instance.Invoke(Result, "[" + msg.timestamp + "] " + msg.name, msg.message);
                }
                receiveDone.Set();
            }
            catch
            {
                threadReceive.Abort();
                receiveDone.Set();
                instance.Invoke(Connection);
                instance.Invoke(Result, SYS_NAME, "Connection to server lost.");
            }
        }

        private static void ReceiveAESKey(Socket server)
        {
            try
            {
                StateObject state = new StateObject();
                state.user = new UserInfo(server);
                state.buffer = new byte[261];
                server.BeginReceive(state.buffer, 0, state.buffer.Length, 0, new AsyncCallback(ReceiveAESKeyCallback), state);
                receiveDone.WaitOne();
                ReceiveAESIV(server);
            }
            catch (Exception e)
            {
                //Error
                Console.WriteLine(e.ToString());
            }
        }

        private static void ReceiveAESIV(Socket server)
        {
            try
            {
                StateObject state = new StateObject();
                state.user = new UserInfo(server);
                state.buffer = new byte[261];
                server.BeginReceive(state.buffer, 0, state.buffer.Length, 0, new AsyncCallback(ReceiveAESIVCallback), state);
                receiveDone.WaitOne();
            }
            catch (Exception e)
            {
                //Error
                Console.WriteLine(e.ToString());
            }
        }

        private static void ReceiveAESKeyCallback(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                Socket server = state.user.soc;
                int read = server.EndReceive(ar);
                Console.WriteLine("bit count received: {0}", read * 8);
                if (read > 0)
                {
                    Console.WriteLine("buffer length:" + state.buffer.Length * 8);
                    var aesDecryptedKey = Chat.RSADecrypt(state.buffer, privateKey);
                    aesKey = aesDecryptedKey;
                    Console.WriteLine("AES key received.");
                }
                receiveDone.Set();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void ReceiveAESIVCallback(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                Socket server = state.user.soc;
                int read = server.EndReceive(ar);
                if (read > 0)
                {
                    var aesDecryptedIV = Chat.RSADecrypt(state.buffer, privateKey);
                    aesIV = aesDecryptedIV;
                    Console.WriteLine("AES initialization vector received.");
                }
                receiveDone.Set();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }

        private static void Disconnect()
        {
            server.Close();
        }

        private void txtUsername_TextChanged(object sender, EventArgs e)
        {
            name = txtUsername.Text;
        }
    }
}
