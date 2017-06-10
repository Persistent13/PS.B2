using System;
using System.Security.Cryptography;

namespace PSB2
{
    public class Account
    {
        public string AccountId;
        public Uri ApiUri;
        public Uri DownloadUri;
        public string Token;
        public long RecommendedPartSize;
        public long MinimumPartSize;
        public Account() { }
        public Account(string AccountId,
                       Uri ApiUri,
                       Uri DownloadUri,
                       string Token,
                       long RecommendedPartSize,
                       long MinimumPartSize)
        {
            this.AccountId = AccountId;
            this.ApiUri = ApiUri;
            this.DownloadUri = DownloadUri;
            this.Token = Token;
            this.RecommendedPartSize = RecommendedPartSize;
            this.MinimumPartSize = MinimumPartSize;
        }
        public override string ToString()
        {
            return this.ApiUri.ToString();
        }
    }
    public enum BucketType { allPublic, allPrivate, snapshot }
    public class Bucket
    {
        public string BucketName;
        public string BucketId;
        public string BucketInfo;
        public string LifecycleRules;
        public BucketType BucketType;
        public string AccountId;
        public long Revision;
        public Bucket() {  }
        public Bucket(string BucketName,
                      string BucketId,
                      BucketType BucketType,
                      string AccountId,
                      string BucketInfo,
                      string LifecycleRules,
                      long Revision)
        {
            this.BucketName = BucketName;
            this.BucketId = BucketId;
            this.BucketType = BucketType;
            this.AccountId = AccountId;
            this.BucketInfo = BucketInfo;
            this.LifecycleRules = LifecycleRules;
            this.Revision = Revision;
        }
        public override string ToString()
        {
            return this.BucketName;
        }
    }
    public enum Action { upload, folder, hide }
    public class File
    {
        public string Name;
        public long Size;
        public DateTime UploadTime;
        public Action ItemType;
        public string FileId;
        public string ContentType;
        public string SHA1;
        public string Info;
        public File() {  }
        public File(string Name,
                    long Size,
                    DateTime UploadTime,
                    Action ItemType,
                    string FileId,
                    string ContentType,
                    string SHA1,
                    string Info)
        {
            this.Name = Name;
            this.Size = Size;
            this.UploadTime = UploadTime;
            this.ItemType = ItemType;
            this.FileId = FileId;
            this.ContentType = ContentType;
            this.SHA1 = SHA1;
            this.Info = Info;
        }
        public File(string Name,
                    long Size,
                    long UploadUnixTimestamp,
                    Action ItemType,
                    string FileId,
                    string ContentType,
                    string SHA1,
                    string Info)
        {
            DateTime x = FromUnixTime(UploadUnixTimestamp);
            this.Name = Name;
            this.Size = Size;
            this.UploadTime = x;
            this.ItemType = ItemType;
            this.FileId = FileId;
            this.ContentType = ContentType;
            this.SHA1 = SHA1;
            this.Info = Info;
        }
        private static DateTime FromUnixTime(long unixTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return epoch.AddMilliseconds(unixTime).ToLocalTime();
        }
        public override string ToString()
        {
            return this.Name;
        }
    }
    public class FileProperty
    {
        public string Name;
        public string FileInfo;
        public string Type;
        public long Length;
        public string BucketId;
        public string AccountId;
        public SHA1 SHA1;
        public string FileId;
        public FileProperty() {  }
        public FileProperty(string Name,
                            string FileInfo,
                            string Type,
                            long Length,
                            string BucketId,
                            string AccountId,
                            SHA1 SHA1,
                            string FileId)
        {
            this.Name = Name;
            this.FileInfo = FileInfo;
            this.Type = Type;
            this.Length = Length;
            this.BucketId = BucketId;
            this.AccountId = AccountId;
            this.SHA1 = SHA1;
            this.FileId = FileId;
        }
        public override string ToString()
        {
            return this.Name;
        }
    }
    public class UploadUri
    {
        public string BucketId;
        public Uri BucketUri;
        public string Token;
        public UploadUri() {  }
        public UploadUri(string BucketId, Uri BucketUri, string Token)
        {
            this.BucketId = BucketId;
            this.BucketUri = BucketUri;
            this.Token = Token;
        }
        public override string ToString()
        {
            return this.BucketUri.ToString();
        }
    }
}
