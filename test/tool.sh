source $(pwd)/../config.sh
source $(pwd)/../utils/log.sh
source $(pwd)/../utils/tools.sh

: << !
mkdir -p /test-tools
cd /test-tools
touch homeserver-20201225-173039.tgz
touch homeserver-20201225-170139.tgz
touch homeserver-20201226-173039.tgz
touch homeserver-20201227-173039.tgz
touch homeserver-20201225-123039.tgz

oldest_file /test-tools
rm -rf /test-tools
!
tar -czvf bin.tgz /bin
openssl_encrypt "bin.tgz" "bin.tgz.enc" "${encrypt_password}"
openssl_decrypt "bin.tgz.enc" "bintmp.tgz" "${encrypt_password}"
