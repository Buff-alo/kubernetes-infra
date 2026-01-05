## Create Namespace

```bash
kubectl create ns minio
```

## Add minio helm repo

```bash
helm repo add minio https://charts.min.io/
helm repo update
```

## Install Minio

```bash
helm upgrade -i minio minio/minio \
  -n minio \
  -f minio-values.yaml
```

## Get Credentials

```bash
export ROOT_USER=$(kubectl -n minio get secret minio -o jsonpath='{.data.rootUser}' | base64 -d)
export ROOT_PASSWORD=$(kubectl -n minio get secret minio -o jsonpath='{.data.rootPassword}' | base64 -d)
echo "ROOT_USER     = $ROOT_USER"
echo "ROOT_PASSWORD = $ROOT_PASSWORD"
```

## Install minio client

```bash
# Download ARM64 version
curl https://dl.min.io/client/mc/release/linux-arm64/mc -o ~/mc
chmod +x ~/mc
sudo mv ~/mc /usr/local/bin/mc

# Verify
mc --version
```

## Set Alias

```bash
mc alias set kls-s3 https://minio-api.kwadwolabs.cloud <username> <password> --api s3v4
```

## Change root password

```bash
# Change root password
mc admin user add kls-s3 newroot
mc admin user info kls-s3 newroot  # copy access/secret
# Attach policy
mc admin policy attach kls-s3 POLICY_NAME --user=USERNAME
mc admin policy attach kls-s3 consoleAdmin --user=newroot
# Change root password
mc admin user add kls-s3 admin NEW_PASSWORD
mc admin user info kls-s3 admin
```

## Note

- Don't forget to set the correct app selectors


## Basic Commands
```bash
# CONFIG
mc alias set kls-s3 https://minio-api.kwadwolabs.cloud minioadmin minioadmin123 --api s3v4

# BUCKETS
mc mb kls-s3/my-bucket
mc ls kls-s3

# UPLOAD / DOWNLOAD
mc cp file.txt kls-s3/my-bucket/
mc cp kls-s3/my-bucket/file.txt .

# LIST
mc ls kls-s3/my-bucket

# PUBLIC ACCESS
mc anonymous set download kls-s3/my-bucket

# SHARE LINK
mc share download kls-s3/my-bucket/file.txt

# VERSIONING
mc version enable kls-s3/my-bucket
mc ls --versions kls-s3/my-bucket/file.txt
```