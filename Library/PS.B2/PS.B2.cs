using System;

namespace PSB2
{
    public class Account
    {
        public string AccountId;
        public Uri ApiUri;
        public Uri DownloadUri;
        public string Token;
        public Account() { }
        public Account(string AccountId, Uri ApiUri, Uri DownloadUri, string Token)
        {
            this.AccountId = AccountId;
            this.ApiUri = ApiUri;
            this.DownloadUri = DownloadUri;
            this.Token = Token;
        }
        public override string ToString()
        {
            return this.AccountId;
        }
    }
    public enum BucketType { allPublic, allPrivate, snapshot }
    public class Bucket
    {
        public string BucketName;
        public long BucketId;
        public BucketType BucketType;
        public long AccountId;
        public Bucket() {  }
        public Bucket(string BucketName, long BucketId, BucketType BucketType, long AccountId)
        {
            this.BucketName = BucketName;
            this.BucketId = BucketId;
            this.BucketType = BucketType;
            this.AccountId = AccountId;
        }
        public override string ToString()
        {
            return this.BucketName;
        }
    }
    public enum Action { upload, folder }
    public class File
    {
        public string Name;
        public long Size;
        public DateTime UploadTime;
        public Action Action;
        public long FileId;
        public File() {  }
        public File(string Name, long Size, DateTime UploadTime, Action Action, long FileId)
        {
            this.Name = Name;
            this.Size = Size;
            this.UploadTime = UploadTime;
            this.Action = Action;
            this.FileId = FileId;
        }
        public File(string Name, long Size, long UploadUnixTimestamp, Action Action, long FileId)
        {
            var x = FromUnixTime(UploadUnixTimestamp);
            this.Name = Name;
            this.Size = Size;
            this.UploadTime = x;
            this.Action = Action;
            this.FileId = FileId;
        }
        private static DateTime FromUnixTime(long unixTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return epoch.AddSeconds(unixTime).ToLocalTime();
        }
        public override string ToString()
        {
            return this.Name;
        }
    }
    public enum FileType { /* TODO: Add FileType enumerables */ }
    public class FileProperty
    {
        public string Name;
        public string FileInfo;
        public FileType Type;
        public long Length;
        public long BucketId;
        public long AccountId;
        public string SHA1;
        public long FileId;
        public FileProperty() {  }
        public FileProperty(
            string Name, string FileInfo, FileType Type, long Length,
            long BucketId, long AccountId, string SHA1, long FileId
        )
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
}
