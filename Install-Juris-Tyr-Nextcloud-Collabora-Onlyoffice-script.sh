#!/bin/bash 
# Ask for user inputs
echo "Indiquez votre nom de domaine (exemple.com):"
read YOUR_DOMAIN

echo "Indiquez votre Mot de passe:"
read -s NEXTCLOUD_PASSWORD
echo "Confirmez votre mot de passe:"
read -s NEXTCLOUD_PASSWORD_CONFIRM
if [[ "$NEXTCLOUD_PASSWORD" != "$NEXTCLOUD_PASSWORD_CONFIRM" ]]; then
    echo "Error: Passwords do not match."
    exit 1
fi

echo "Indiquez votre future adresse mail sous la forme contact@exemple.com ou john-snow@exemple.com:"
read EMAIL

# Continue with the installation process using provided inputs
clear
echo "Mise à jour..."

# Update system packages
sudo apt update
sudo apt upgrade -y

echo "Installation du serveur web apache2"

sudo apt install -y apache2 apache2-utils
sudo systemctl start apache2
sudo systemctl enable apache2
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT

echo "Installation du par feu UFW"

sudo apt install ufw
sudo ufw allow ssh
sudo ufw enable
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 25
sudo ufw allow 110
sudo ufw allow 143
sudo ufw allow 465
sudo ufw allow 587
sudo ufw allow 993
sudo ufw allow 995
sudo ufw allow 22
sudo ufw allow 21
sudo ufw allow 8000
sudo ufw allow 8080
sudo ufw allow 8892
sudo ufw allow 9200
sudo ufw allow 9300
sudo ufw allow 9980
sudo ufw allow 9981
sudo ufw reload

sudo apt install -y nano

sudo nano /etc/apache2/conf-available/servername.conf <<EOF
'ServerName localhost'
EOF

echo "Installation de MariaDB"

sudo a2enconf servername.conf
sudo systemctl reload apache2

sudo chown www-data:www-data /var/www/html/ -R
sudo chown www-data:www-data /var/www/ -R

# Install MariaDB server and client
sudo apt install mariadb-server mariadb-client -y

# Start MariaDB (if not automatically started)
sudo systemctl start mariadb

# Enable MariaDB to start automatically on boot
sudo systemctl enable mariadb

# Run the post-installation security script
sudo mysql_secure_installation

# Prompt user to set the root password for MariaDB
read -s -p "Enter the root password for MariaDB: " $NEXTCLOUD_PASSWORD
echo

# Log in to MariaDB as root
echo $NEXTCLOUD_PASSWORD | sudo mariadb -u root

# Exit MariaDB
echo "exit;" | sudo mariadb
echo "Installation de PHP"

#install php
sudo apt install -y lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common

sudo add-apt-repository ppa:ondrej/php

sudo apt update

sudo apt install -y php8.2 libapache2-mod-php8.2 php8.2-mysql php-common php8.2-cli php8.2-common php-fpm php8.2-json php8.2-opcache php8.2-readline

sudo a2enmod php8.2

sudo systemctl restart apache2

sudo a2dismod php8.2

sudo apt install php8.2-fpm

sudo a2enmod proxy_fcgi setenvif
#Activate configuration file /etc/apache2/conf-available/php8.2-fpm.conf file :

sudo a2enconf php8.2-fpm
#Restart Apache for changes to take effect :

sudo systemctl restart apache2

sudo apt update && sudo apt install -y apache2 libapache2-mod-php8.2 php8.2 php8.2-gd php8.2-mysql php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip unzip certbot python3-certbot-apache postgresql libpq-dev


sudo apt install -y postgresql postgresql-contrib


# Enable necessary Apache modules
echo "Enabling required Apache modules..."
sudo a2enmod rewrite headers expires ssl
sudo systemctl restart apache2

# Install PostgreSQL, create the nextcloud user and database
echo "Installing PostgreSQL and configuring Nextcloud database..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -u postgres psql <<EOF
CREATE USER nextclouduser WITH ENCRYPTED PASSWORD '$NEXTCLOUD_PASSWORD';
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextclouduser;
\q
EOF
echo "Installation de Nextcloud"
sudo apt install unzip

# Download and extract Nextcloud 28.0.1, set correct ownership
echo "Downloading Nextcloud, extraction, and setting ownership..."
cd /var/www/html
sudo wget https://download.nextcloud.com/server/releases/nextcloud-28.1.0.zip
sudo unzip nextcloud-28.0.1.zip
sudo mv nextcloud-28.0.1/* .
sudo chown -R www-data:www-data /var/www/html/
sudo chmod 750 /var/www/html/config
sudo chmod 750 /var/www/html/core
sudo find /var/www/html -type f -exec chmod 640 {} \;

echo "Configuration du serveur web apache pour Nextcloud"

# Configure Apache for Nextcloud
echo "Configuring Apache for Nextcloud..."
sudo a2enconf php8.2-fpm
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo systemctl restart apache2
sudo a2enmod http2

cat > /etc/apache2/sites-available/nextcloud.conf <<EOF

 <VirtualHost *:80>
        <IfModule mod_http2.c>
           Protocols h2 http/1.1               
           # Solves slow upload speeds caused by http2
           H2WindowSize 5242880
        </IfModule>
        <IfModule pagespeed_module>
           ModPagespeed off
        </IfModule>
           <IfModule mod_security.c>
           SecFilterEngine Off
           SecFilterScanPOST Off
        </IfModule>
        DocumentRoot "/var/www/html/nextcloud"
        ServerName cloud.$YOUR_DOMAIN
        ErrorLog ${APACHE_LOG_DIR}/nextcloud.error
        CustomLog ${APACHE_LOG_DIR}/nextcloud.access combined
        <Directory /var/www/html/nextcloud/>
            Require all granted
            Options FollowSymlinks MultiViews
            AllowOverride All
           <IfModule mod_dav.c>
               Dav off
           </IfModule>
        SetEnv HOME /var/www/html/nextcloud
        SetEnv HTTP_HOME /var/www/html/nextcloud
        Satisfy Any
    # Disable HTTP TRACE method.
    TraceEnable off
    <Files ".ht*">
        Require all denied
    </Files>
       </Directory>
</VirtualHost>
EOF

sudo a2ensite nextcloud.conf
sudo a2enmod rewrite headers env dir mime setenvif ssl
sudo a2dismod php8.2
sudo a2dismod mpm_prefork
sudo a2dismod mpm_prefork

sudo systemctl restart apache2 php8.2-fpm
sudo apt install imagemagick libapache2-mod-php php-imagick php8.2-common php8.2-pgsql php8.2-fpm php8.2-gd php8.2-curl php8.2-imagick php8.2-zip php8.2-xml php8.2-mbstring php8.2-bz2 php8.2-intl php8.2-bcmath php8.2-gmp
sudo apt install imagemagick libapache2-mod-php php-imagick php8.3-common php8.3-pgsql php8.3-fpm php8.3-gd php8.3-curl php8.3-imagick php8.3-zip php8.3-xml php8.3-mbstring php8.3-bz2 php8.3-intl php8.3-bcmath php8.3-gmp
sudo wget -O /usr/local/bin/php-module-builder https://global-social.net/apps/raw/s/php-module-builder

sudo chmod +x /usr/local/bin/php-module-builder
cd /usr/local/bin/
sudo php-module-builder

sudo systemctl reload apache2 php8.2-fpm php8.3-fpm

sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
echo "Installation de LetsEncrypt et configuration"

sudo apt install certbot python3-certbot-apache

sudo certbot --apache --agree-tos --redirect --staple-ocsp --email $EMAIL -d cloud.$YOUR_DOMAIN

sudo chmod 750 /var/www/html/config
sudo chmod 750 /var/www/html/core
sudo find /var/www/html -type f -exec chmod 640 {} \;

echo "Installation and configuration completed! You can access your Nextcloud instance at https://$YOUR_DOMAIN"

# Modify the nextcloud-le-ssl.conf file to add HSTS header
echo "Modifying nextcloud-le-ssl.conf to add HSTS header..."
sudo sed -i 's/#Header always set Strict-Transport-Security "max-age=31536000"/Header always set Strict-Transport-Security "max-age=31536000"/' /etc/letsencrypt/options-ssl-apache.conf
sudo systemctl restart apache2

# Cleanup
echo "Cleaning up..."
sudo apt autoremove -y

echo "Amélioration des performances de Nextcloud"

#Amélioration des performances :
sudo sed -i 'pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18'  /etc/php/8.2/fpm/pool.d/www.conf

sudo sed -i 'pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18'  /etc/php/8.3/fpm/pool.d/www.conf
sudo systemctl reload php8.2-fpm php8.3-fpm


sudo sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/8.2/fpm/pool.d/www.conf
sudo sed -i 's/;clear_env = no/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf


sudo sed -i 's/#Header always set Strict-Transport-Security "max-age=31536000"/Header always set Strict-Transport-Security "max-age=31536000"/' /etc/letsencrypt/options-ssl-apache.conf


sudo sed -i 's/client_max_body_size 512M;/client_max_body_size 1024M;/g' /etc/apache2/conf.d/nextcloud.conf


sudo systemctl reload apache2


sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /etc/php/8.2/fpm/php.ini

sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /etc/php/8.3/fpm/php.ini

cat >> /etc/php/8.2/fpm/php.ini <<EOF
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
EOF


cat >> /etc/php/8.3/fpm/php.ini <<EOF
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
EOF

sudo systemctl restart php8.2-fpm php8.3-fpm apache2

sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo apt install php8.2-redis php-redis php8.3-redis
sudo phpenmod redis
EOF

cat >> /var/www/html/nextcloud/config/config.php <<EOF
'memcache.distributed' => '\OC\Memcache\Redis',
'memcache.local' => '\OC\Memcache\Redis',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => array(
 'host' => 'localhost',
 'port' => 6379,
),
EOF


sudo systemctl restart apache2 php8.2-fpm php8.3-fpm
#Parametrage de Nextcloud 

cd /var/www/html/nextcloud/
sudo -u www-data php occ db:add-missing-indices
sudo -u www-data php occ maintenance:mode --on
sudo -u www-data php occ db:convert-filecache-bigint
sudo -u www-data php occ maintenance:mode --off

sudo cp /var/www/html/nextcloud/config/config.php /var/www/html/nextcloud/config/config.save.php

cat >> /var/www/html/nextcloud/config/config.php <<EOF
'session_lifetime' => 86400,
'remember_login_cookie_lifetime' => 1296000,
'session_relaxed_expiry' => false,
'allow_local_remote_servers' => true,
'default_language' => 'fr',
'force_language' => 'fr',
'default_locale' => 'fr_FR',
'force_locale' => 'fr_FR',
'default_phone_region' => 'FR',
'logtimezone' => 'Europe/Paris',
'allow_user_to_change_display_name' => true,
'log_rotate_size' => 52428800,
'enable_previews' => true,
'trashbin_retention_obligation' => 'auto, 4',

'loglevel' => 3,
'app_install_overwrite' =>
array (
0 => 'ojsxc',
1 => 'pdfdraw',
2 => 'files_fulltextsearch_tesseract',
3 => 'previewgenerator',
4 => 'ocr',
5 => 'emlviewer',
6 => 'talk_simple_poll',
7 => 'files_trackdownloads',
8 => 'whiteboard',
9 => 'fulltextsearch_elasticsearch',
10 => 'carnet',
11 => 'sendent',
12 => 'scanner',
13 => 'ocsms',
14 => 'files_texteditor',
15 => 'wopi',
16 => 'documentserver_community',
17 => 'pdfannotate',
18 => 'cms_pico',
19 => 'approval',
20 => 'apporder',
21 => 'extract',
22 => 'fulltextsearch',
23 => 'impersonate',
24 => 'files_fulltextsearch',
25 => 'jitsi',
26 => 'files_linkeditor',
27 => 'onlyoffice',
28 => 'pdf_downloader',
29 => 'transfer',
30 => 'files_mindmap',
31 => 'appointments',
32 => 'data_request',
33 => 'jsloader',
34 => 'user_external',
35 => 'workflow_script',
36 => 'files_scripts',
37 => 'sorts',
38 => 'side_menu',
39 => 'afterlogic',
40 => 'files_downloadactivity',
41 => 'event_update_notification',
42 => 'login_notes',
43 => 'workflow_ocr',
44 => 'files_downloadlimit',
45 => 'workflow_kitinerary',
46 => 'libresign',
47 => 'cfg_share_links',
48 => 'externalportal',
49 => 'registration',),
'enabledPreviewProviders' =>
array (
0 => 'OC\Preview\Movie',
1 => 'OC\Preview\PNG',
2 => 'OC\Preview\JPEG',
3 => 'OC\Preview\GIF',
4 => 'OC\Preview\BMP',
5 => 'OC\Preview\XBitmap',
6 => 'OC\Preview\MP3',
7 => 'OC\Preview\MP4',
8 => 'OC\Preview\TXT',
9 => 'OC\Preview\MarkDown',
10 => 'OC\Preview\PDF',
11 => 'OC\Preview\OpenDocument',
12 => 'OC\Preview\Krita',
13 => 'OC\Preview\EMF',
),
'preview_max_x' => 128,
'preview_max_y' => 128,
'preview_max_filesize_image' => 128,
'mail_smtpsecure' => 'tls',
'mail_smtpauthtype' => 'LOGIN',
'mail_smtpname' => '$EMAIL',
'mail_smtppassword' => '$NEXTCLOUD_PASSWORD',
'memcache.distributed' => 'OC\Memcache\Redis',
'memcache.local' => 'OC\Memcache\Redis',
'memcache.locking' => 'OC\Memcache\Redis',
'redis' =>
array (
'host' => 'localhost',
'port' => 6379,
'timeout' => 0.0,
),
'has_rebuilt_cache' => true,
'defaultapp' => 'files,dashboard',
);
EOF

sudo sed -i ');/' /var/www/html/nextcloud/config/config.php 

cat >> /var/www/html/nextcloud/config/config.php  <<EOF
);
EOF
echo "Installation CollaboraOnline"

#Installation CollaboraOnline
echo deb https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-ubuntu2204 ./ | sudo tee /etc/apt/sources.list.d/collabora.list
sudo apt-key adv –keyserver keyserver.ubuntu.com –recv-keys 0C54D189F4BA284D ubuntu Collabora public key
sudo wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && sudo apt-key add repomd.xml.key
sudo apt install -y  apt-transport-https ca-certificates
sudo apt update
sudo apt install -y  coolwsd code-brand
sudo coolconfig set ssl.enable false

sudo coolconfig set ssl.termination true
sudo coolconfig set storage.wopi.host cloud.$YOUR_DOMAIN
sudo systemctl restart coolwsd

cat > /etc/apache2/sites-available/collabora.conf <<EOF
<VirtualHost *:80>
  Protocols h2 http/1.1
  ServerName collabora.exemple.com
  Options -Indexes

  ErrorLog “/var/log/apache2/collabora_error”

  # Encoded slashes need to be allowed
    AllowEncodedSlashes NoDecode

  # keep the host
    ProxyPreserveHost On

  # static html, js, images, etc. served from coolwsd
  # loleaflet/browser is the client part of Collabora Online
    ProxyPass /loleaflet http://127.0.0.1:9980/loleaflet retry=0
    ProxyPassReverse /loleaflet http://127.0.0.1:9980/loleaflet
    ProxyPass /browser http://127.0.0.1:9980/browser retry=0
    ProxyPassReverse /browser http://127.0.0.1:9980/browser
  # WOPI discovery URL
    ProxyPass /hosting/discovery http://127.0.0.1:9980/hosting/discovery retry=0
    ProxyPassReverse /hosting/discovery http://127.0.0.1:9980/hosting/discovery
  # Capabilities
    ProxyPass /hosting/capabilities http://127.0.0.1:9980/hosting/capabilities retry=0
    ProxyPassReverse /hosting/capabilities http://127.0.0.1:9980/hosting/capabilities
  # Main websocket
    ProxyPassMatch “/cool/(.*)/ws$” ws://127.0.0.1:9980/cool/$1/ws nocanon
  # Admin Console websocket
    ProxyPass /cool/adminws ws://127.0.0.1:9980/cool/adminws
  # Download as, Fullscreen presentation and Image upload operations
    ProxyPass /cool http://127.0.0.1:9980/cool
    ProxyPassReverse /cool http://127.0.0.1:9980/cool
</VirtualHost>
EOF

sudo a2enmod proxy proxy_wstunnel proxy_http
sudo a2ensite collabora.conf
sudo apt install -y  certbot
sudo apt install -y  python3-certbot-apache
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email $EMAIL -d collabora.$YOUR_DOMAIN
sudo systemctl restart apache2

echo "Installation OnlyOfffice"

#install OnlyOffice
sudo apt install -y  apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y  apache2 vim docker-ce
sudo a2enmod ssl rewrite headers proxy proxy_http deflate cache proxy_wstunnel
sudo systemctl restart apache2


cat >  /etc/apache2/sites-available/onlyoffice.conf <<EOF
<VirtualHost *:80>
  ServerName onlyoffice.exemple.com
  
  ErrorLog ${APACHE_LOG_DIR}/onlyoffice.exemple.com.error.log
  CustomLog ${APACHE_LOG_DIR}/onlyoffice.exemple.com.access.log combined
  
  SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS

  SSLHonorCipherOrder on
  SSLCompression off

  SetEnvIf Host "^(.*)$" THE_HOST=$1

  RequestHeader setifempty X-Forwarded-Proto https
  RequestHeader setifempty X-Forwarded-Host %{THE_HOST}e

  ProxyAddHeaders Off

  ProxyPassMatch (.*)(\/websocket)$ "ws://127.0.0.1:9981/$1$2"
  ProxyPass / "http://127.0.0.1:9981/"
  ProxyPassReverse / "http://127.0.0.1:9981/"

</VirtualHost>

EOF


sudo a2ensite onlyoffice.conf
sudo systemctl restart apache2

sudo certbot –apache –agree-tos –redirect –hsts –staple-ocsp –email $EMAIL -d onlyoffice.$YOUR_DOMAIN

sudo systemctl restart apache2

sudo docker run -i -t -d --restart=always -e JWT_ENABLED=true -e JWT_SECRET=$NEXTCLOUD_PASSWORD -p 9981:80 \
    -v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
    -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
    -v /app/onlyoffice/DocumentServer/lib:/var/lib/onlyoffice \
    -v /app/onlyoffice/DocumentServer/rabbitmq:/var/lib/rabbitmq \
    -v /app/onlyoffice/DocumentServer/redis:/var/lib/redis \
    -v /app/onlyoffice/DocumentServer/db:/var/lib/postgresql  onlyoffice/documentserver:latest

#installation postfix
#echo "Installation du serveur mail"

#curl -s https://mailinabox.email/setup.sh | sudo bash

#echo "Pour terminer l'installation du serveur e-mail, visionnez cette vidéo : https://www.youtube.com/watch?v=9WOmkoEYMIg&t=856s"

```
#echo "Installation de InvoiceNinja"
sudo wget https://github.com/invoiceninja/invoiceninja/releases/download/v5.8.23/invoiceninja.zip
sudo apt install unzip

sudo mkdir -p /var/www/html/invoiceninja/

sudo unzip invoiceninja.zip -d /var/www/html/invoiceninja/

sudo chown www-data:www-data /var/www/html/invoiceninja/ -R
sudo chmod 755 /var/www/html/invoiceninja/storage/ -R
flush privileges;
exit;


sudo mysql -e "
create database invoiceninja;
create user 'ninja'@'localhost' identified by '$NEXTCLOUD_PASSWORD';
grant all privileges on invoiceninja.* to 'ninja'@'localhost';
flush privileges;"

sudo apt install software-properties-common

sudo add-apt-repository ppa:ondrej/php -y

sudo apt install -y php-imagick php8.2 php8.2-mysql php8.2-fpm php8.2-common php8.2-bcmath php8.2-gd php8.2-curl php8.2-zip php8.2-xml php8.2-mbstring php8.2-bz2 php8.2-intl php8.2-gmp php8.2-fileinfo php8.2-pdo

sudo apt install -y php-imagick php8.3 php8.3-mysql php8.3-fpm php8.3-common php8.3>-bcmath php8.3-gd php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-bz2 php8.3-intl php8.3-gmp php8.3-fileinfo php8.3-pdo

sudo systemctl restart apache2

cd /var/www/html/invoiceninja/

sudo cp .env.example .env
sudo sed -i 'APP_URL=http://localhost/APP_URL=http://facturation.$YOUR_DOMAIN' /var/www/html/invoiceninja/.env


sudo sed -i 'DB_PASSWORD=ninja_password/DB_PASSWORD=$NEXTCLOUD_PASSWORD' /var/www/html/invoiceninja/.env

sudo sed -i 'PDF_GENERATOR=hosted_ninja/PDF_GENERATOR=snappdf' /var/www/html/invoiceninja/.env

sudo chown www-data:www-data /var/www/html/invoiceninja/.env


sudo php8.2 /var/www/html/invoiceninja/artisan key:generate

sudo php8.2 /var/www/html/invoiceninja/artisan migrate:fresh --seed
sudo -u www-data ./vendor/bin/snappdf download

cat > /etc/apache2/sites-available/invoice-ninja.conf <<EOF
<VirtualHost *:80>
    ServerName facturation.$YOUR_DOMAIN
    DocumentRoot /var/www/html/invoiceninja/public
    <Directory /var/www/html/invoiceninja/public>
       DirectoryIndex index.php
       Options +FollowSymLinks
       AllowOverride All
       Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/invoice-ninja.error.log
    CustomLog ${APACHE_LOG_DIR}/invoice-ninja.access.log combined
</VirtualHost>
EOF

sudo a2ensite invoice-ninja.conf

sudo a2enmod rewrite

sudo systemctl restart apache2

sudo a2dissite 000-default.conf

sudo systemctl restart apache2 php8.2-fpm php8.3-fpm

sudo chown -R www-data:www-data /var/www/html/invoiceninja/ sudo find ./ -type d -exec chmod 755 {} \;

sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email $EMAIL -d facturation.$YOUR_DOMAIN

sudo systemctl restart apache2


sudo chown www-data:www-data /var/www/html/invoiceninja/storage/framework/cache/data/ -R

sudo -u www-data crontab -e
cat > /etc/apache2/sites-available/invoice-ninja.conf <<EOF
#InvoiceNinja
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-recurring > /dev/null
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-reminders > /dev/null
* * * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan schedule:run >> /dev/null 2>&1
EOF


cat <<EOF > /tmp/invoiceninja-cron.txt
#InvoiceNinja
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-recurring > /dev/null
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-reminders > /dev/null
* * * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan schedule:run >> /dev/null 2>&1
EOF

# Add the cronjob to www-data user's crontab
crontab -u www-data /tmp/invoiceninja-cron.txt
rm /tmp/invoiceninja-cron.txt
