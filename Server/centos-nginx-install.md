https://launchpad.net/nginx/0.7/0.7.66/+download/nginx-0.7.66.tar.gz


```bash
# install dependency
yum install -y gcc  # GNU compiler
yum install -y pcre pcre-devel  # PCRE(Perl Compatible Regular Expression)
# ubuntu system
# apt-get install libpcre3 libpcre3-dev 
yum install -y zlib zlib-devel  # gzip compression library
#ubuntu system
# apt-get install zliblg zliblg-dev
yum install -y openssl openssl-devel

# download nginx 
cd ~/downloads
wget https://launchpad.net/nginx/0.7/0.7.66/+download/nginx-0.7.66.tar.gz
tar xzvf nginx-0.7.66.tar.gz
cd nginx-0.7.66 # change extracted directory 

# compile
./configure --prefix=/usr/local/nginx-0.7.66 --with-cc-opt=-Wno-error
make
make install 
cd /usr/local/nginx-0.7.66/sbin
./nginx
```