#!/bin/bash
# Demandes des données pour l'installation 
echo "Indiquez votre nom de domaine (exemple.com):"
read YOUR_DOMAIN
echo "Indiquez votre nom d'utilisateur administrateur pour Nextcloud, InvoiceNinja et Wordpress:"
read NEXTCLOUD_USER
echo "Choisir un mot de passe long et original (https://www.avast.com/fr-fr/random-password-generator#pc) :"
read -s NEXTCLOUD_PASSWORD
echo "Confirmez votre mot de passe :"
read -s NEXTCLOUD_PASSWORD_CONFIRM
if [[ "$NEXTCLOUD_PASSWORD" != "$NEXTCLOUD_PASSWORD_CONFIRM" ]]; then
    echo "Erreur : Les mots de passe saisis ne correspondent pas entre eux. Relancez le script"
    exit 1
fi
echo "Indiquez votre adresse mail sous la forme contact@exemple.com ou john-snow@exemple.com (si vous etes John SNOW...):"
read EMAIL
# Continue with the installation process using provided inputs
clear
echo "Mise à jour préalable du système d'exploitation..."
# Mise à jour du système
sudo apt update --quiet
sudo apt upgrade -y --quiet
echo "Installation du serveur web apache2"
sudo apt install -y --no-install-recommends --quiet apache2 apache2-utils
sudo systemctl start apache2
sudo systemctl enable apache2
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
echo "Installation du par feu UFW"
sudo apt install -y --no-install-recommends --quiet ufw
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
yes | sudo ufw reload
sudo apt install -y --no-install-recommends nano
sudo nano /etc/apache2/conf-available/servername.conf <<EOL
ServerName localhost
EOL
sudo a2enconf servername.conf
sudo systemctl reload apache2
echo "Installation du serveur web apache2 terminée"
sudo chown www-data:www-data /var/www/html/ -R
sudo chown www-data:www-data /var/www/ -R
# Install MariaDB server and client
echo "Installation de MariaDB"
sudo apt install -y --no-install-recommends mariadb-server mariadb-client
# Start MariaDB (if not automatically started)
sudo systemctl start mariadb
# Enable MariaDB to start automatically on boot
sudo systemctl enable mariadb
# Run the post-installation security script
sudo mysql_secure_installation
# Prompt user to set the root password for MariaDB
read -s -p "Entrez le mot de passe root pour MariaDB
: " $NEXTCLOUD_PASSWORD
echo
# Log in to MariaDB as root
echo $NEXTCLOUD_PASSWORD | sudo mariadb -u root
# Exit MariaDB
echo "exit;" | sudo mariadb
echo "Installation de MariaDB terminée"
echo "Installation de php8.2 et php8.3"
#install php
sudo apt install -y --no-install-recommends lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
yes | sudo add-apt-repository ppa:ondrej/php
sudo apt update --quiet
sudo apt install -y --no-install-recommends --quiet php8.2 libapache2-mod-php8.2 php8.2-mysql php-common php8.2-cli php8.2-common php-fpm php8.2-json php8.2-opcache php8.2-readline
sudo a2enmod php8.2
sudo systemctl restart apache2
sudo a2dismod php8.2
sudo apt install -y --no-install-recommends --quiet php8.2-fpm
sudo a2enmod proxy_fcgi setenvif
#Activate configuration file /etc/apache2/conf-available/php8.2-fpm.conf file :
sudo a2enconf php8.2-fpm
#Restart Apache for changes to take effect :
sudo systemctl restart apache2
sudo apt update --quiet && sudo apt install -y --no-install-recommends --quiet apache2 libapache2-mod-php8.2 php8.2 php8.2-gd php8.2-mysql php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip unzip certbot python3-certbot-apache postgresql libpq-dev
sudo apt install -y --no-install-recommends --quiet postgresql postgresql-contrib
# Enable necessary Apache modules
echo "Enabling required Apache modules..."
sudo a2enmod rewrite headers expires ssl
sudo systemctl restart apache2
echo "Installation de php8.2 et php8.3 terminée"
# Install PostgreSQL, create the nextcloud user and database
echo "Installation de PostgreSQL and configuration de la base de données de Nextcloud..."
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -u postgres psql <<EOF
CREATE USER $NEXTCLOUD_USER WITH ENCRYPTED PASSWORD '$NEXTCLOUD_PASSWORD';
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON DATABASE nextcloud TO $NEXTCLOUD_USER;
\q
EOF
echo "Installation de Nextcloud"
sudo apt install -y --no-install-recommends  unzip
# Téléchargement et extraction de Nextcloud 28.0.1

echo "Téléchargement de Nextcloud, extraction et propriété..."
cd /var/www/html
sudo wget https://download.nextcloud.com/server/releases/nextcloud-28.0.1.zip
sudo unzip nextcloud-28.0.1.zip
sudo mv nextcloud-28.0.1/* .
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo chmod 750 /var/www/html/nextcloud/config
sudo chmod 750 /var/www/html/nextcloud/core
sudo find /var/www/html/nextcloud -type f -exec chmod 640 {} \;
echo "Configuration du serveur web apache pour Nextcloud"
# Configure Apache for Nextcloud
echo "Configuring Apache for Nextcloud..."
sudo a2enconf php8.2-fpm
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo systemctl restart apache2
sudo a2enmod http2
cat >> /etc/apache2/sites-available/nextcloud.conf <<EOF
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
    #TraceEnable off
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
sudo apt install -y --no-install-recommends --quiet imagemagick libapache2-mod-php php-imagick php8.2-imagick php8.2-common php8.2-pgsql php8.2-fpm php8.2-gd php8.2-curl php8.2-imagick php8.2-zip php8.2-xml php8.2-mbstring php8.2-bz2 php8.2-intl php8.2-bcmath php8.2-gmp
sudo apt install -y --no-install-recommends --quiet imagemagick libapache2-mod-php php8.3-imagick php8.3-common php8.3-pgsql php8.3-fpm php8.3-gd php8.3-curl php8.3-imagick php8.3-zip php8.3-xml php8.3-mbstring php8.3-bz2 php8.3-intl php8.3-bcmath php8.3-gmp
sudo wget -O /usr/local/bin/php-module-builder https://global-social.net/apps/raw/s/php-module-builder
sudo chmod +x /usr/local/bin/php-module-builder
cd /usr/local/bin/
sudo php-module-builder
sudo systemctl reload apache2 php8.2-fpm php8.3-fpm
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
echo "Installation de LetsEncrypt et configuration"
sudo apt install -y --no-install-recommends --quiet certbot python3-certbot-apache
sudo certbot --apache --agree-tos --redirect --staple-ocsp --email $EMAIL -d cloud.$YOUR_DOMAIN
sudo chmod 750 /var/www/html/config
sudo chmod 750 /var/www/html/core
sudo find /var/www/html -type f -exec chmod 640 {} \;
sudo systemctl restart apache2
echo "Installation et configuration terminées ! Vous pouvez accéder à votre instance Nextcloud à
 https://cloud.$YOUR_DOMAIN"
# Modify the nextcloud-le-ssl.conf file to add HSTS header
echo "Modification de nextcloud-le-ssl.conf to ajout de HSTS header..."
sudo sed -i 's/#Header always set Strict-Transport-Security "max-age=31536000"/Header always set Strict-Transport-Security "max-age=31536000"/' /etc/letsencrypt/options-ssl-apache.conf
sudo systemctl restart apache2
# Cleanup
echo "Nettoyage..."
sudo apt autoremove -y
echo "Installation de Nextcloud terminée"
echo "Amélioration des performances de Nextcloud"
#Amélioration des performances :
sudo sed -i 'pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18' /etc/php/8.2/fpm/pool.d/www.conf
sudo sed -i 'pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18' /etc/php/8.3/fpm/pool.d/www.conf
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
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
EOF
cat >> /etc/php/8.3/fpm/php.ini <<EOF
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
EOF
sudo systemctl restart php8.2-fpm php8.3-fpm apache2
echo "Installation de Redis"
sudo apt install -y --no-install-recommends --quiet redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo apt install -y --no-install-recommends --quiet php8.2-redis php-redis php8.3-redis
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
echo "Parametrage de Nextcloud"
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
cat >> /var/www/html/nextcloud/config/config.php <<EOF
);
EOF
sudo apt-get install -y libmagickcore-6.q16-6-extra
sudo apt install -y --no-install-recommends --quiet ffmpeg
sudo sed -i '127.0.0.1   localhost/127.0.0.1 localhost $YOUR_DOMAIN cloud.$YOUR_DOMAIN    collabora.$YOUR_DOMAIN    onlyoffice.$YOUR_DOMAIN pdf.$YOUR_DOMAIN     ai.$YOUR_DOMAIN    visio.$YOUR_DOMAIN     facturation.$YOUR_DOMAIN' /etc/hosts
echo "Tapez la touche 1 pour choisir l'éditeur de texte nano puis sur les touches Control et C"
sudo -u www-data crontab -e
echo "1"
read -s 1
$1
cat >> /tmp/nextcloud-cron.txt <<EOF
*/5 * * * * php8.2 -f /var/www/html/nextcloud/cron.php
@daily certbot renew --quiet && systemctl reload apache2
EOF
#Add the cronjob to www-data user's crontab
sudo crontab -u www-data /tmp/nextcloud-cron.txt
rm /tmp/nextcloud-cron.txt
cd /var/www/html/nextcloud
sudo -u www-data php occ app:install approval
sudo -u www-data php occ app:install bookmarks
sudo -u www-data php occ app:install certificate24
sudo -u www-data php occ app:install cfg_share_links
sudo -u www-data php occ app:install collectives
sudo -u www-data php occ app:install data_request
sudo -u www-data php occ app:install deck
sudo -u www-data php occ app:install emlviewer
sudo -u www-data php occ app:install external
sudo -u www-data php occ app:install externalportal
sudo -u www-data php occ app:install extract
sudo -u www-data php occ app:install federatedfilesharing
sudo -u www-data php occ app:install federation
sudo -u www-data php occ app:install files_accesscontrol
sudo -u www-data php occ app:install files_automatedtagging
sudo -u www-data php occ app:install files_confidential
sudo -u www-data php occ app:install files_downloadactivity
sudo -u www-data php occ app:install files_downloadlimit
sudo -u www-data php occ app:install files_external
sudo -u www-data php occ app:install files_fulltextsearch
sudo -u www-data php occ app:install fulltextsearch_elasticsearch
sudo -u www-data php occ app:install files_fulltextsearch_tesseract
sudo -u www-data php occ app:install files_linkeditor
sudo -u www-data php occ app:install files_rightclick
sudo -u www-data php occ app:install files_scripts
sudo -u www-data php occ app:install files_sharing
sudo -u www-data php occ app:install files_versions
sudo -u www-data php occ app:install flow_notifications
sudo -u www-data php occ app:install forms
sudo -u www-data php occ app:install fulltextsearch
sudo -u www-data php occ app:install fulltextsearch
sudo -u www-data php occ app:install integration_openai
sudo -u www-data php occ app:install integration_replicate
sudo -u www-data php occ app:install logreader
sudo -u www-data php occ app:install notes
sudo -u www-data php occ app:install onlyoffice
sudo -u www-data php occ app:install provisioning_api
sudo -u www-data php occ app:install recommendations
sudo -u www-data php occ app:install registration
sudo -u www-data php occ app:install sharebymail
sudo -u www-data php occ app:install side_menu
sudo -u www-data php occ app:install socialsharing_email
sudo -u www-data php occ app:install stt_whisper
sudo -u www-data php occ app:install tables
sudo -u www-data php occ app:install text_templates
sudo -u www-data php occ app:install translate
sudo -u www-data php occ app:install workflow_ocr
sudo -u www-data php occ app:install workflowengine
sudo -u www-data php occ app:install workflow_pdf_converter
sudo -u www-data php occ app:install calendar
sudo -u www-data php occ app:install contacts
sudo -u www-data php occ app:install contactsinteraction
sudo -u www-data php occ app:install richdocuments
sudo -u www-data php occ app:install activity
sudo -u www-data php occ app:install gptfreeprompt
sudo -u www-data php occ app:install memegen
sudo -u www-data php occ stt_whisper:download-models medium
sudo -u www-data php occ stt_whisper:download-models large
sudo -u www-data php occ translate:download-models
sudo apt install -y --no-install-recommends --quiet ffmpeg
yes | sudo add-apt-repository ppa:alex-p/tesseract-ocr5
sudo apt update --quiet
sudo apt install -y --no-install-recommends --quiet tesseract-ocr
sudo apt-get install -y --no-install-recommends --quiet tesseract-ocr-fra
sudo apt-get install -y --no-install-recommends --quiet tesseract-ocr-deu
echo "Paramétrage de Nextcloud terminé"
echo "Installation CollaboraOnline"
#Installation CollaboraOnline
yes | echo deb https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-ubuntu2204 ./ | sudo tee /etc/apt/sources.list.d/collabora.list
yes | sudo apt-key adv –keyserver keyserver.ubuntu.com –recv-keys 0C54D189F4BA284D ubuntu Collabora public key
sudo wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && yes | sudo apt-key add repomd.xml.key
sudo apt install -y --no-install-recommends --quiet apt-transport-https ca-certificates
sudo apt update --quiet
sudo apt install -y --no-install-recommends --quiet coolwsd code-brand
sudo coolconfig set ssl.enable false
sudo coolconfig set ssl.termination true
sudo coolconfig set storage.wopi.host cloud.$YOUR_DOMAIN
sudo systemctl restart coolwsd
cat >> /etc/apache2/sites-available/collabora.conf <<EOF
<VirtualHost *:80>
  Protocols h2 http/1.1
  ServerName collabora.$YOUR_DOMAIN
  Options -Indexes
  #ErrorLog "/var/log/apache2/collabora_error"
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
sudo apt install -y --no-install-recommends --quiet certbot
sudo apt install -y --no-install-recommends --quiet python3-certbot-apache
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email $EMAIL -d collabora.$YOUR_DOMAIN
sudo systemctl restart apache2
echo "Installation CollaboraOnline terminée"
echo "Installation d'OnlyOfffice"
#install OnlyOffice
sudo apt install -y --no-install-recommends --quiet apt-transport-https ca-certificates curl software-propertie-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | yes | sudo apt-key add -
yes | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y --no-install-recommends --quiet apache2 vim docker-ce
sudo a2enmod ssl rewrite headers proxy proxy_http deflate cache proxy_wstunnel
sudo systemctl restart apache2
cat >> /etc/apache2/sites-available/onlyoffice.conf <<EOF
<VirtualHost *:80>
  ServerName onlyoffice.$YOUR_DOMAIN
  ErrorLog ${APACHE_LOG_DIR}/onlyoffice.$YOUR_DOMAIN.error.log
  CustomLog ${APACHE_LOG_DIR}/onlyoffice.$YOUR_DOMAIN.access.log combined
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
    -v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice \
    -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data \
    -v /app/onlyoffice/DocumentServer/lib:/var/lib/onlyoffice \
    -v /app/onlyoffice/DocumentServer/rabbitmq:/var/lib/rabbitmq \
    -v /app/onlyoffice/DocumentServer/redis:/var/lib/redis \
    -v /app/onlyoffice/DocumentServer/db:/var/lib/postgresql onlyoffice/documentserver:latest
echo "Installation d'OnlyOfffice terminée"
#installation postfix test
echo "Installation du serveur mail"
#curl -s https://mailinabox.email/setup.sh | sudo bash
echo "Pour terminer l'installation du serveur e-mail, visionnez cette vidéo : https://www.youtube.com/watch?v=9WOmkoEYMIg&t=856s"
echo "Installation de php composer"
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
echo "Installation de InvoiceNinja"
sudo wget https://github.com/invoiceninja/invoiceninja/releases/download/v5.8.23/invoiceninja.zip
sudo apt install -y --no-install-recommends --quiet unzip
sudo mkdir -p /var/www/html/invoiceninja/
sudo unzip invoiceninja.zip -d /var/www/html/invoiceninja/
sudo chown www-data:www-data /var/www/html/invoiceninja/ -R
sudo chmod 755 /var/www/html/invoiceninja/storage/ -R
sudo mysql -e "
create database invoiceninja;
create user '$NEXTCLOUD_USER'@'localhost' identified by '$NEXTCLOUD_PASSWORD';
grant all privileges on invoiceninja.* to '$NEXTCLOUD_USER'@'localhost';
flush privileges;"
sudo apt install -y --no-install-recommends --quiet software-properties-common
yes | sudo add-apt-repository ppa:ondrej/php -y
sudo apt install -y --no-install-recommends --quiet php-imagick php8.2 php8.2-mysql php8.2-fpm php8.2-common php8.2-bcmath php8.2-gd php8.2-curl php8.2-zip php8.2-xml php8.2-mbstring php8.2-bz2 php8.2-intl php8.2-gmp php8.2-fileinfo php8.2-pdo
sudo apt install -y --no-install-recommends --quiet php-imagick php8.3 php8.3-mysql php8.3-fpm php8.3-common php8.3>-bcmath php8.3-gd php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-bz2 php8.3-intl php8.3-gmp php8.3-fileinfo php8.3-pdo
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
cat >> /etc/apache2/sites-available/invoice-ninja.conf <<EOF
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
cat >> /tmp/invoiceninja-cron.txt <<EOF
#InvoiceNinja
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-recurring > /dev/null
0 8 * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan ninja:send-reminders > /dev/null
* * * * * /usr/bin/php8.2 /var/www/html/invoiceninja/artisan schedule:run >> /dev/null 2>&1
EOF
#Add the cronjob to www-data user's crontab
sudo crontab -u www-data /tmp/invoiceninja-cron.txt
rm /tmp/invoiceninja-cron.txt
echo "Installation de InvoiceNinja terminée"
echo "Installation de SignaturePDf"
sudo apt install -y --no-install-recommends --quiet php librsvg2-bin pdftk imagemagick potrace git
cd /var/www/html/
sudo git clone https://github.com/24eme/signaturepdf.git --quiet
sudo chown www-data:www-data -R /var/www/html/signaturepdf
sudo chmod 755 -R /var/www/html/signaturepdf/public
cd /var/www/html/signaturepdf/
sudo cp config/config.ini{.example,}
sudo sed -i '#PDF_STORAGE_PATH=/path/to/folder/PDF_STORAGE_PATH=/var/www/html/signaturepdf/pdfuploaded' /var/www/html/signaturepdf/config.ini
sudo mkdir /var/www/html/signaturepdf/pdfuploaded
sudo chown www-data:www-data -R /var/www/html/signaturepdf/pdfuploaded
sudo php -S localhost:8000 -t public
clear
cat >> /etc/apache2/sites-available/pdf.conf <<EOF
<VirtualHost *:80>
Servername pdf.$YOUR_DOMAIN
DocumentRoot /var/www/html/signaturepdf/public
<Directory /var/www/html/signaturepdf/public>
    Require all granted
    FallbackResource /index.php
    php_value max_file_uploads 201
    php_value upload_max_filesize 24M
    php_value post_max_size 24M
</Directory>
</Virtualhost>
EOF
sudo a2ensite pdf.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email $EMAIL -d pdf.$YOUR_DOMAIN
sudo systemctl restart apache2 php8.2-fpm php8.3-fpm
cd /var/www/html/signaturepdf/
sudo git pull -r
echo "Installation de SignaturePDf terminée"
echo "Installation de WordPress"
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip -d /var/www/
sudo mv /var/www/wordpress /var/www/$YOUR_DOMAIN
sudo mysql -e "
create database wordpress;
create user '$NEXTCLOUD_USER@localhost' identified by '$NEXTCLOUD_PASSWORD';
grant all privileges on wordpress.* to '$NEXTCLOUD_USER@localhost';
flush privileges;"
cd /var/www/$YOUR_DOMAIN
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 'define( 'DB_NAME', 'database_name_here' );/define('DB_NAME', 'wordpress' );' /var/www/$YOUR_DOMAIN/wp-config.php
sudo sed -i 'define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'NEXTCLOUD_USER' );' /var/www/$YOUR_DOMAIN/wp-config.php
sudo sed -i 'define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '$NEXTCLOUD_PASSWORD' );' /var/www/$YOUR_DOMAIN/wp-config.php
sudo chown www-data:www-data /var/www/example.com/ -R
cat >> /etc/apache2/sites-available/$YOUR_DOMAIN.conf <<EOF
<VirtualHost *:80> 
        ServerName www.$YOUR_DOMAIN
       ServerAlias $YOUR_DOMAIN
        DocumentRoot /var/www/$YOUR_DOMAIN
        #This enables .htaccess file, which is needed for WordPress Permalink to work. 
        <Directory "/var/www/$YOUR_DOMAIN">
             AllowOverride All
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/$YOUR_DOMAIN.error.log
        CustomLog ${APACHE_LOG_DIR}/$YOUR_DOMAIN.access.log combined
</VirtualHost>
EOF
sudo a2ensite $YOUR_DOMAIN.conf
sudo systemctl reload apache2
sudo apt install -y --no-install-recommends --quiet php8.2-mbstring php8.2-xml php8.2-mysql php8.2-gd php8.2-bcmath php8.2-json php8.2-cli php8.2-curl php8.2-zip
sudo apt install -y --no-install-recommends --quiet certbot python3-certbot-apache
sudo certbot --apache --agree-tos --redirect --hsts --uir --staple-ocsp --email $EMAIL -d $YOUR_DOMAIN,www.$YOUR_DOMAIN
sudo systemctl restart apache2
echo "Installation de WordPress terminée"
echo "Installation de Jitsi Meet"
echo 'deb https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
sudo wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | yes | sudo apt-key add -
sudo apt install -y --no-install-recommends --quiet apt-transport-https
echo "A la prochaine étape, indiquez l'adresse : visio.exemple.com ou visio.snow-company.com puis appuyez sur la touche Enter"
sudo apt update 
sudo apt install -y jitsi-meet
echo "Installation du serveur coturn"
sudo wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/c/coturn/coturn_4.5.2-3.1_amd64.deb
sudo ./coturn_4.5.2-3.1_amd64.deb
sudo apt install -y --no-install-recommends jitsi-meet-turnserver
sudo ufw allow 22,80,443,5349/tcp 
sudo ufw allow 10000,3478/udp
sudo /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
sudo certbot --agree-tos -a dns-cloudflare -i apache --redirect --hsts --staple-ocsp --email $EMAIL -d visio.$YOUR_DOMAIN
sudo apt install -y --no-install-recommends --quiet acl 
sudo setfacl -R -m u:prosody:rx /etc/letsencrypt/live /etc/letsencrypt/archive/ 
sudo setfacl -R -m u:jicofo:rx /etc/letsencrypt/live /etc/letsencrypt/archive/ 
sudo setfacl -R -m u:jvb:rx /etc/letsencrypt/live /etc/letsencrypt/archive/
sudo systemctl restart apache2 coturn prosody jitsi-videobridge2 jicofo
echo "Installation du serveur coturn et de Jitsi Meet terminée"
echo "Installation de Ollama et de Ollama WebUI"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo apt update --quiet
sudo apt install -y --no-install-recommends --quiet python3-pip
sudo apt install -y --no-install-recommends --quiet build-essential libssl-dev libffi-dev python3-dev
sudo apt install -y --no-install-recommends --quiet python3-venv
sudo apt install -y --no-install-recommends --quiet ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
yes | sudo echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update --quiet
sudo apt install -y --no-install-recommends --quiet nodejs
sudo apt install -y --no-install-recommends --quiet build-essential
sudo apt install -y --no-install-recommends --quiet nodejs npm
sudo curl https://ollama.ai/install.sh | sh
sudo systemctl start ollama
sudo systemctl enable enable
sudo docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
cat >> /etc/apache2/sites-available/ai.conf <<EOF
<VirtualHost *:80>
ServerName ai.$YOUR_DOMAIN
ProxyPreserveHost On
ProxyVia On
ProxyPass / http://127.0.0.1:3000/
ProxyPassReverse / http://127.0.0.1:3000/
RewriteRule ^/(.*)?$ http://localhost:3000/$1 [P,L]
<Proxy  *>
    Allow from all
</Proxy>
<Location "/">
  ProxyPass "http://127.0.0.1:3000/"
  ProxyPassReverse "http://127.0.0.1:3000/"
    Allow from all
</Location>
<Location "/">
  ProxyPass "http://127.0.0.1:11434/"
  ProxyPassReverse "http://127.0.0.1:11434/"
    Allow from all
</Location>
ProxyPass / "http://127.0.0.1:11434"
ProxyPassReverse / "http://127.0.0.1:11434"
ProxyPass / "http://127.0.0.1:8080"
ProxyPassReverse / "http://127.0.0.1:8080"
ErrorLog ${APACHE_LOG_DIR}/ollamawebui.$YOUR_DOMAIN.error.log
CustomLog ${APACHE_LOG_DIR}/ollamawebui.$YOUR_DOMAIN.access.log combined
</VirtualHost>
EOF
sudo a2ensite ai.conf
sudo systemctl reload apache2
sudo apt install -y --no-install-recommends --quiet php8.2-mbstring php8.2-xml php8.2-mysql php8.2-gd php8.2-bcmath php8.2-json php8.2-cli php8.2-curl php8.2-zip
sudo apt install -y --no-install-recommends --quiet certbot python3-certbot-apache
sudo certbot --apache --agree-tos --redirect --hsts --uir --staple-ocsp --email $EMAIL -d ai.$YOUR_DOMAIN
sudo systemctl restart apache2
echo "Installation de Ollama et de Ollama WebUI terminée"
echo "Installation du LLM Vigostral"
cd  ~/
sudo wget https://huggingface.co/TheBloke/Vigostral-7B-Chat-GGUF/resolve/main/vigostral-7b-chat.Q4_K_M.gguf
cat >> ~/Modelfile <<EOF
FROM ~/vigostral-7b-chat.Q4_K_M.gguf
PARAMETER temperature 0.2
SYSTEM """You are a helpfull assistant who answer always in French."""
EOF
sudo ollama create vigostral-local -f Modelfile
echo "Installation du LLM Vigostral terminée"
echo "Installation de Whisper WebUI - logiciel de reconnaissance vocale"
cd /var/www/html/ 
sudo git clone https://github.com/xenova/whisper-web.git --quiet 
cd /var/www/html whisper-web 
sudo npm install 
sudo chown www-data:www-data -R /var/www/html/whisper-web
sudo chmod 775 -R /var/www/html/whisper-web
sudo npm run dev 
cat >> /etc/apache2/sites-available/vocal.conf <<EOF
<VirtualHost *:80>
ServerName vocal.$YOUR_DOMAIN
ProxyPreserveHost On
ProxyVia On
ProxyPass / http://127.0.0.1:5173/
ProxyPassReverse / http://127.0.0.1:5173/
  <Proxy  *>
    Allow from all
  </Proxy>
<Location "/">
  ProxyPass "http://127.0.0.1:5173/"
  ProxyPassReverse "http://127.0.0.1:5173/"
    Allow from all
</Location>
ErrorLog ${APACHE_LOG_DIR}/whisperweb.$YOU_DOMAIN.error.log
CustomLog ${APACHE_LOG_DIR}/whisperweb.$YOUR_DOMAIN.access.log combined
</VirtualHost>
EOF
sudo a2ensite vocal.conf
sudo systemctl reload apache2
sudo certbot --apache --agree-tos --redirect --hsts --uir --staple-ocsp --email $EMAIL -d vocal.$YOUR_DOMAIN
sudo systemctl restart apache2
echo "Installation de Whisper WebUI terminée"
IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "L'addresse IP de ce server est : $IP_ADDRESS"
echo "Votre nom d'utilisateur principal pour Nextcloud, InvoiceNinja et Wordpress est  : $NEXTCLOUD_USER"
echo "Votre mot de passe principal est  : $NEXTCLOUD_PASSWORD"
echo "Votre nom de domaine est  : $YOUR_DOMAIN" 
echo "Le nouveau port pour accéder au serveur via ssh n'est plus 22 mais 34067" 
echo "Modification du port pour accéder au serveur via ssh de 22 en 34067"
sudo sed -i '#Port 22/#Port 34067' /etc/ssh/sshd_config
sudo ufw allow 34067/tcp
Yes | sudo ufw reload
sudo /sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 34067 -j ACCEPT
echo "Attention, le nouveau port pour accéder au serveur via ssh n'est plus 22 mais 34067"
