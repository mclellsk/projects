using System;
using System.Net.Sockets;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using System.Security.Cryptography;

namespace ChatLibrary
{
    /// <summary>
    /// ChatMessage class is a serializable object which contains the of the sender,
    /// the timestamp of the message, and the message itself.
    /// </summary>
    [Serializable]
    public class ChatMessage
    {
        public DateTime timestamp;
        public string name;
        public string message;

        public ChatMessage(string name, string message)
        {
            this.message = message;
            this.name = name;
            timestamp = DateTime.Now;
        }
    }

    /// <summary>
    /// UserInfo class is used by the server to hold all relevant client information for the
    /// duration of the session.
    /// </summary>
    public class UserInfo
    {
        public int clientId;
        public Socket soc;
        public RSAParameters rsaPublicKey;
        public byte[] aesKey;
        public byte[] aesIV;

        public UserInfo(Socket soc)
        {
            this.soc = soc;
        }
    }

    /// <summary>
    /// Client attempts to connect to server socket. Server listening accepts connection with client,
    /// the server then waits for the client to send the public key for RSA encryption which will support
    /// a message length of 256 bytes. Once the server receives the key, it generates the AES key and initialization
    /// vector for symmetric key cryptography for this specific user. The server then encrypts both these values with
    /// the RSA encryption, and then sends them to the client. This is because asymmetric encryption is expensive, so
    /// symmetric key cryptography should be used to encrypt the actual messages sent between the server and the 
    /// client.
    /// </summary>
    public static class Chat
    {
        /// <summary>
        /// Converts a serializable object into a binary formatted byte stream.
        /// </summary>
        /// <param name="obj">Serializable object.</param>
        /// <returns>Binary formatted bit stream.</returns>
        public static byte[] ConvertToBinary(object obj)
        {
            MemoryStream ms = new MemoryStream();
            BinaryFormatter bf = new BinaryFormatter();
            bf.Serialize(ms, obj);
            return ms.GetBuffer();
        }

        /// <summary>
        /// Generic type deserializer of a binary formatted byte stream.
        /// </summary>
        /// <typeparam name="T">Object type.</typeparam>
        /// <param name="bytes">Binary formatted byte stream.</param>
        /// <returns>Deserialized object.</returns>
        public static T DeserializeTo<T>(byte[] bytes)
        {
            BinaryFormatter bf = new BinaryFormatter();
            MemoryStream ms = new MemoryStream(bytes);
            return (T)bf.Deserialize(ms);
        }

        /// <summary>
        /// Takes a ChatMessage object, serializes it, and then encrypts it using AES key and initialization vector.
        /// </summary>
        /// <param name="msg">Message to serialize.</param>
        /// <param name="key">AES key.</param>
        /// <param name="initv">AES initialization vector.</param>
        /// <returns>AES encrypted byte stream of message.</returns>
        public static byte[] SendMessage(ChatMessage msg, byte[] key, byte[] initv)
        {
            var bMsg = ConvertToBinary(msg);
            var encrypted = AESEncrypt(bMsg, key, initv);
            return encrypted;
        }

        /// <summary>
        /// Takes a byte stream of AES encrypted data, decrypts it using the AES key and initialization vector,
        /// and then deserializes the binary formatted byte stream to a ChatMessage object.
        /// </summary>
        /// <param name="data">AES encrypted byte stream.</param>
        /// <param name="key">AES key.</param>
        /// <param name="initv">AES initialization vector.</param>
        /// <returns></returns>
        public static ChatMessage ReceiveMessage(byte[] data, byte[] key, byte[] initv)
        {
            var decrypted = AESDecrypt(data, key, initv);
            var msg = DeserializeTo<ChatMessage>(decrypted);
            return msg;
        }

        /// <summary>
        /// Performs AES encryption on byte stream using key and initialization vector.
        /// </summary>
        /// <param name="encrypt">Byte stream to encrypt.</param>
        /// <param name="key">AES key.</param>
        /// <param name="initv">AES initialization vector.</param>
        /// <returns>AES encrypted byte stream.</returns>
        private static byte[] AESEncrypt(byte[] encrypt, byte[] key, byte[] initv)
        {
            using (AesCryptoServiceProvider aes = new AesCryptoServiceProvider())
            {
                aes.Padding = PaddingMode.None;
                var encryptor = aes.CreateEncryptor(key, initv);
                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor, CryptoStreamMode.Write))
                    {
                        using (BinaryWriter sw = new BinaryWriter(cs))
                        {
                            sw.Write(encrypt);
                        }
                        return ms.ToArray();
                    }
                }
            }
        }
        
        /// <summary>
        /// Performs AES decryption on encrypted byte stream using key and initialization vector.
        /// </summary>
        /// <param name="decrypt">Byte stream to decrypt.</param>
        /// <param name="key">AES key.</param>
        /// <param name="initv">AES initialization vector.</param>
        /// <returns>Decrypted byte stream.</returns>
        private static byte[] AESDecrypt(byte[] decrypt, byte[] key, byte[] initv)
        {
            using (AesCryptoServiceProvider aes = new AesCryptoServiceProvider())
            {
                aes.Padding = PaddingMode.None;
                var decryptor = aes.CreateDecryptor(key, initv);
                using (MemoryStream ms = new MemoryStream(decrypt))
                {
                    using (CryptoStream cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
                    {
                        using (BinaryReader br = new BinaryReader(cs))
                        {
                            return br.ReadBytes(decrypt.Length);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Gets parameters for RSA encryption, where the first index is the private key, and the 
        /// second index is the public key.
        /// </summary>
        /// <returns>Array with private and public RSA keys.</returns>
        public static RSAParameters[] GetRSAKeys()
        {
            RSAParameters[] keys = new RSAParameters[2];
            using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider(2088))
            {
                //Get private and public keys
                keys[0] = rsa.ExportParameters(true);
                keys[1] = rsa.ExportParameters(false);
            }
            return keys;
        }

        /// <summary>
        /// Generates AES initialization vector.
        /// </summary>
        /// <returns>AES initialization vector as byte stream.</returns>
        public static byte[] AESGenerateIV()
        {
            using (AesCryptoServiceProvider aes = new AesCryptoServiceProvider())
            {
                aes.GenerateIV();
                return aes.IV;
            }
        }

        /// <summary>
        /// Generates AES symmetric key.
        /// </summary>
        /// <returns>AES symmetric key.</returns>
        public static byte[] AESGenerateKey()
        {
            using (AesCryptoServiceProvider aes = new AesCryptoServiceProvider())
            {
                aes.GenerateKey();
                return aes.Key;
            }
        }

        /// <summary>
        /// Performs RSA asymmetrical encryption on byte stream. It is important that the key size be 
        /// large enough to support encrypting a payload as large as the AES key and initialization vector.
        /// </summary>
        /// <remarks>Asymmetric encryption is expensive, do not use this to encrypt regular messages.</remarks>
        /// <example>We use a 2088 bit RSA key size to support our 256 byte AES key.</example>
        /// <param name="encrypt">Data to encrypt.</param>
        /// <param name="key">RSA public key.</param>
        /// <returns>RSA encrypted byte stream.</returns>
        public static byte[] RSAEncrypt(byte[] encrypt, RSAParameters key)
        {
            using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider(2088))
            {
                //Set public key parameters
                rsa.ImportParameters(key);
                return rsa.Encrypt(encrypt, false);
            }
        }

        /// <summary>
        /// Performs RSA decryption on encrypted byte stream. Byte stream must be smaller than the modulus of the RSA key.
        /// </summary>
        /// <param name="decrypt">Encrypted byte stream to decrypt.</param>
        /// <param name="key">RSA private key.</param>
        /// <returns>Decrypted byte stream.</returns>
        public static byte[] RSADecrypt(byte[] decrypt, RSAParameters key)
        {
            using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider(2088))
            {
                rsa.ImportParameters(key);
                return rsa.Decrypt(decrypt, false);
            }
        }

        /// <summary>
        /// Compares the SHA256 hash received from the sender to the SHA256 hash calculated
        /// from the byte stream provided. Used to check data integrity.
        /// </summary>
        /// <param name="hash">SHA256 hash on data, provided by sender.</param>
        /// <param name="data">Data received from sender.</param>
        /// <returns>Result based on equality of hashes.</returns>
        public static bool HashEqual(byte[] hash, byte[] data)
        {
            //use SHA2
            var hasher = SHA256.Create();
            var hash2 = hasher.ComputeHash(data);
            return hash.Equals(hash2);
        }
    }
}
