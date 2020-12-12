sudo yum update -y
sudo yum install -y docker jq automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel mailcap

git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure --prefix=/usr --with-openssl
make
sudo make install

cd ..
git clone https://github.com/plexinc/pms-docker.git
cd pms-docker
sudo systemctl start docker
sudo docker build -f Dockerfile.arm64 -t plexinc/pms-docker:latest .