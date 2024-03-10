# Juris-Tyr

Juris Tyr = Nextcloud + Serveur d’e-mails + InvoiceNinja + Jitsi Meet + OnlyOffice + SignaturePDF + Wordpress + Ollama Web Ui + (…) sur un VPS.

Nous vous proposons une méthode simplifiée pour installer rapidement la solution logicielle proposée par Juris-Tyr sur un serveur ou un VPS.

🧑‍💻 Après avoir effectué l’installation, vous accèderez aux logiciels de votre plateforme, en tapant les adresses suivantes dans la barre d’adresse de votre navigateur (remplacer exemple.com par le nom de domaine de votre entreprise ou cabinet d’avocats) :
cloud.exemple.com : pour accéder à Nextcloud, l’application de gestion de fichiers et de collaboration avec vos collaborateurs et clients
facturation.exemple.com  : pour accéder à l’application de facturation Invoiceninja afin d’envoyer des factures et des propositions de devis à vos clients
onlyoffice.exemple.com : pour accéder à la suite bureautique en ligne Onlyoffice afin de créer et d’éditer des documents Office Word, Excel…
visio.exemple.com : pour accéder à Jitsi Meet afin d’organiser des visioconférences avec vos clients ou vos partenaires
pdf.exemple.com : pour accéder à SignaturePDF afin d’annoter et modifier des fichiers PDF de manière confidentielle
exemple.com/wp-login : pour accéder à l’interface administrateur de WordPress afin de créer et d’éditer votre site internet ‘exemple.com’
ai.exemple.com : pour accéder à ‘Ollama WebUI’, logiciel d’intelligence artificielle permettant utiliser des LLM open source ou GPT4 de OpenAI
vocal.exemple.com : pour utiliser la reconnaissance vocale Whisper avec un hébergement des données vocales sur votre serveur / VPS
audio.exemple.com : pour utiliser la lecture vocale de textes
mail.exemple.com : pour créer et éditer les adresses e-mails de votre cabinet d’avocats ou entreprise.

Les étapes pour installer la solution logicielle proposée par Cloud Juris-Tyr sont :
1 - Souscrire à une offre d’un serveur VPS sur : ovhcloud.com/fr/vps/ [ ➡️ étape 1 ]
2 - Acheter un nom de domaine sur : ovhcloud.com/fr/domains/ [ ➡️ étape 2 ]
3 - Configurer la zone DNS de votre nom de domaine [ ➡️ étape 3 ]
4 - Se connecter à votre nouveau serveur VPS avec le logiciel Putty [ ➡️ étape 4 ]
5 - Lancer nos scripts d’installation et configurer les logiciels [ ➡️ étape 5 ]

Nous ne recevons aucun avantage ni ne percevons de rémunération de l’hébergeur OVHCloud. Les démarches d’installation fonctionnent avec n’importe quel VPS d’un autre prestataire, à partir du moment ou le VPS/serveur fonctionne sous Ubuntu 22.04 et dispose d’au moins 4go de mémoire vive.

Les noms de domaine les moins coûteux sont les .ovh à partir de 2,99 € HT / an.

Pour le serveur VPS, choisissez un modèle avec minimum 40 Go d’espace disque et 4Go de mémoire vive à partir de 11,50 € / mois.
Il est fortement recommandé de choisir l’option « backup automatisé » à partir de 2 à 3 € HT / supplémentaires par mois selon la capacité de stockage du VPS.

**Etape 1 – Installation, configuration et accès au serveur :**

*Installer/souscrire à un abonnement à un serveur dédié / VPS :*

La première étape est de souscrire à un abonnement à un serveur dédié ou ‘VPS’, par exemple auprès de la société OVH.

Il s’agit de l’hébergeur que nous recommandons mais nous n’avons aucun avantage de la société OVHCloud ni percevons aucune rémunération de cet hébergeur / prestataire. Les démarches d’installation fonctionnent avec n’importe quel VPS d’un autre hébergeur / prestataire, à partir du moment ou le VPS/serveur fonctionne sous Ubuntu 22.04 et dispose d’au moins 4Go de mémoire vive.

Cette solution d’un abonnement mensuel à régler à un prestataire pour l’accès à un serveur dédié ou à un serveur VPS (OVH, Nuxit, Hostsinger …etc.) est certes plus coûteuse à moyen ou long terme qu’utiliser son propre ordinateur serveur en auto hébergement mais cela présente l’avantage indéniable de la sécurisation de vos données en cas d’événement grave survenant dans vos locaux (incendie, d’inondation, cambriolage…etc.) et d’une mise à jour régulière de l’offre et du matériel VPS mis à disposition par le prestataire.

C’est la raison pour laquelle nous préconisons une solution d’installation sur un serveur privé virtuel / VPS que ce soit via la société OVHCloud ou via d’autres prestataires similaires pour des questions de sécurité, de performance du système, de mise à jour régulières du matériel / serveur et in fine, de tranquillité d’esprit…

Si vous recherchez un serveur privé virtuel (VPS), nous vous recommandons ceux d’OVH dont le montant des abonnements est raisonnable et surtout avec des serveurs situés en France, ce qui est une obligation pour les cabinets d’avocats français ou pour d’autres professions réglementés (le secteur médical par exemple).

Il existe toutefois d’autres prestataires avec des offres tout aussi recommandables…

*Souscrire à un abonnement et installer un serveur virtuel privé / VPS sur OVHCloud ou auprès d’un autre prestataire (Nuxit, Hostsinger…):*

➡️ Cliquez sur le lien suivant, pour souscrire à un abonnement à un VPS auprès du prestataire OVHCloud : https://www.ovhcloud.com/fr/vps/

Concernant les offres d’abonnement de la société OVHcloud, l’offre « Starter » à 3,50 € HT par mois permet de faire des tests et d’installer les logiciels et applications. Cette offre permet d’installer les applications de la plateforme Juris-Tyr et de la tester. Toutefois pour une utilisation quotidienne, le VPS avec cette offre, risque de manquer de réactivité, notamment s’il y a plusieurs utilisateurs connectés en même temps.

➡️ Ainsi, sauf pour une installation de test, si vous souhaitez une utilisation plus ‘confortable’ (rapide) de la plateforme, nous vous recommandons de privilégier la souscription à une offre d’abonnement « Essential » à 11,50€ HT par mois ou « Comfort » à 21,62 € HT par mois.

➡️ Lors de votre souscription à un VPS, vous devez choisir l’installation du système d’exploitation ‘Ubuntu 22.04’.

➡️ L’abonnement à OVHCloud peut être résilié selon le respect d’un préavis d’un mois (hors engagement annuel).
Il convient de cocher la case ‘sans engagement’ le cas échéant.

➡️ Nous vous recommandons également de souscrire à l’option de sauvegarde automatique du serveur du Prestataire (OVHCloud ou autres).

➡️ Une fois que vous avez souscrit à une des offres d’abonnement à un VPS auprès du prestataire OVHCloud (par exemple…), l’espace client de gestion de votre VPS s’affichera ainsi :

➡️ Vous recevrez par e-mail les codes de connexion à votre VPS (le login et le mot de passe).
En général le login est ‘ubuntu’ si vous avez choisi de faire installer une distribution (OS) « Ubuntu 22.04 » sur votre VPS lors de votre souscription à un abonnement.

➡️ Veuillez conserver ces login et mot de passe car vous allez les utiliser prochainement pour vous connecter à votre serveur VPS, via le logiciel « Putty » (sous Windows).

Vous venez de souscrire à une offfre d’abonnement à un VPS.
Passons à l’étape suivante, l’achat d’un nom de domaine.

**Etape 2 – Achetez un nom de domaine :**

Nous vous proposons un tutoriel pour acheter un nom de domaine sur le site de la société OVHCloud, cependant vous pouvez passer par les services de toute autre société proposant les mêmes services (NameCheap, Hostsinger…etc.).

➡️ Connectez-vous sur le site internet d’un prestataire gestionnaire de noms de domaine.
Par exemple, sur le site de la société OVHCloud : ovhcloud.com/fr/domains/

➡️ Sur le site de la société OVHCloud, cliquez sur l’onglet « Hébergements web et Domaines » puis sur « Noms de domaine » :

➡️ Choisissez un nom de domaine et indiquez le dans la barre de recherche puis cliquez sur le bouton « Rechercher ».
Par exemple dans l’exemple ci-dessous : « cabinetdupond.com » :

➡️ Choisissez l’extension du nom de domaine (en .com, .fr …etc.), puis cliquez sur le bouton « Continuez la commande »
Dans l’exemple ci-dessous, nous avons choisi une extension de nom de domaine en « .com » :

➡️ Eventuellement, ajoutez l’option « DNS Anycast » pour améliorer le chargement de votre site internet (facultatif).
Cliquez sur le bouton « Continuez la commande » :
Il est inutile de choisir une option d’hébergement.

➡️ Cliquez sur le bouton « Continuez la commande » :

➡️ Connectez vous à votre compte client ou créez un compte client, puis réglez le montant demandé pour l’achat de votre nom de domaine.

Une fois que vous disposez d’un serveur ou d’un abonnement à un VPS et d’un nom de domaine pour un site internet, Nous allons configurer « la zone DNS » de ce nom de domaine.

**Etape 3 – Configurez la Zone DNS de votre nom de domaine ‘exemple.com‘ :**

Vous venez de souscrire à un serveur VPS, vous avez acheté un nom de domaine et il faut désormais paramétrer les différents noms de domaine (exemple.com) et sous-domaine (cloud.exemple.com) qui vous permettront d’accéder aux différents logiciels depuis des sites internet.

A cette fin, il faut modifier la « zone DNS » de votre nom de domaine « exemple.com« .

ℹ️ La ‘Zone DNS’ liste les enregistrements DNS du nom de domaine .
ℹ️ Effectuer un enregistrement ‘DNS’ consiste à indiquer que le nom de domaine (ou le sous domaine) doit renvoyer vers telle ou telle adresse IP d’un serveur informatique ou VPS.

➡️ Si vous avez souscrit un nom de domaine auprès d’OVHCloud, les démarches pour configurer la zone DNS sont les suivantes :

1 - Connectez vous sur votre espace client : https://www.ovh.com/auth/?onsuccess=https%3A//www.ovh.com/manager&ovhSubsidiary=FR
2 - Cliquez sur l’onglet « Web Cloud,
3 - puis sur « Noms de domaine »
4 - puis sur votre nom de domaine (« cabinetdupont.com » par exemple)
5 - puis sur le bouton « Modifier en mode textuel »

Après avoir cliqué sur le bouton « Modifier en mode textuel », la page web devrait ressembler à celle-ci :

➡️ Copier / coller le texte suivant en ajoutant une ligne blanche à la fin du texte, et en remplaçant les mots « $IP_ADDRESS » par l’adresse IP de votre serveur ou de votre VPS qui doit ressembler à quelque chose comme ‘51.23.456.78‘ si vous avez souscrit VPS auprès de la société OVHCloud.
Remplacez également les termes $YOUR_DOMAIN par votre nom de domaine exemple.com :

"
$TTL 3600
@ IN SOA ns11.ovh.net. tech.ovh.net. 
IN NS ns11.ovh.net.
IN NS dns11.ovh.net.
IN MX 50 mail
60 IN A $IP_ADDRESS
600 IN TXT "v=spf1 a mx ip4:$IP_ADDRESS include:$YOUR_DOMAIN include:spf.protection.outlook.com  ~all"
600 IN TXT "v=spf1 mx ~all"
affine IN A $IP_ADDRESS
ai IN A $IP_ADDRESS
cloud IN A $IP_ADDRESS
collabora IN A $IP_ADDRESS
facturation 60 IN A $IP_ADDRESS
comptabilite IN A $IP_ADDRESS
secureaitools IN A $IP_ADDRESS
librechat IN A $IP_ADDRESS
affine IN A $IP_ADDRESS
mail IN A $IP_ADDRESS
onlyoffice IN A $IP_ADDRESS
pdf IN A $IP_ADDRESS
postfixadmin 60 IN A $IP_ADDRESS
visio IN A $IP_ADDRESS
vocal IN A $IP_ADDRESS
webmail IN A $IP_ADDRESS
audio IN A $IP_ADDRESS
www IN A $IP_ADDRESS
      
"
ℹ️ Attention, il doit y avoir une ligne vide supplémentaire à la fin de cette zone DNS.

➡️ Cliquez sur le bouton « Valider » et patientez quelques secondes pour la prise en compte des changements.

Une fois la zone DSN configurée, nous allons utilisez un logiciel spécifique qui s’appelle « Putty » pour se connecter au serveur ou au VPS, puis pour entrer des lignes de commande pour le serveur.

**Etape 4 – Connectez-vous à votre serveur avec le logiciel putty’ :**

➡️ Installez le logiciel ‘Putty‘ puis lancez le.

La fenêtre de connexion suivante s’affichera.

➡️ Connectez vous à votre serveur via ce logiciel Putty, en complétant l’adresse IP du serveur ou du VPS (par exemple 51.124.56.789) et s’il n’est pas affiché, le port ’22’ :

Cliquez sur le bouton ‘Open’

Puis, une fois que la fenêtre de connexion s’affiche…

Autorisez la connexion (cliquez sur le bouton « Accept / tout accepter / tout autoriser »).

Tapez votre nom d’utilisateur de l’utilisateur principal du serveur, a priori le nom d’utilisateur est : « ubuntu » si vous avez suivi ce tutoriel, puis appuyer sur la touche ‘Entrer’,
Puis indiquez le mot de passe de l’utilisateur « ubuntu » pour le serveur ou VPS, en le copiant (sélectionner le mot de passe puis appuyez simultanément que les touches [Control] et [c] de votre clavier), puis en cliquant simplement sur le bouton droit de votre souris ou trackpad dans la fenêtre du terminal pour le copier automatiquement (le mot de passe vous a été communiqué par e-mail par la société OVHCloud),

Appuyez sur la touche ‘Entrer’, pour vous connecter à votre serveur via une connection ssh.

**Etape 5 – Installez la solution logicielle proposée par Juris-Tyr**

Après avoir configuré votre serveur / VPS et noms de domaine, il suffit d’exécuter les commandes précisées dans cette étape 5.

⚒️ Notre script vous permettra d’installer automatiquement et en quelques minutes sur un serveur / VPS les logiciels suivants :
-Un serveur web Apache
-MariaDB
-Postgress
-php8.2 et php8.3
-Nextcloud
-Redis
-CollaboraOnline
-OnlyOffice
-InvoiceNinja
-SignaturePDF
-WordPress
-Jitsi Meet
-Ollama et Ollama WebUI
-Whisper WebUI

ℹ️ L’installation du serveur mail s’effectuera dans un second temps.

➡️ Exécutez la commande suivante :

bash <(wget -qO- https://raw.githubusercontent.com/Arthur-Llevelys/Juris-Tyr/main/Install-Juris-Tyr-Nextcloud-Collabora-Onlyoffice-script.sh);Copier

➡️ Vous allez devoir indiquer :
-votre nom de domaine : exemple.com
-un nom d’utilisateur principal en lettres minuscules, par exemple : johnsnow (ou n’importe quelle autre nom d’utilisateur si vous n’êtes pas John SNOW)
-un mot de passe : mon-super-mot-de-passe-tres-complique!-de-2024
-votre adresse e-mail : contact@exemple.com

➡️ vous devrez appuyer sur la touche ‘Entrer’ ou sur les touches ‘Y’ ou ‘O’, puis sur la touche ‘Entrer’ en fonction des messages affichés…

…A un certain moment de l’installation, il vous sera demandé ou installer des scripts pour certaines extensions php8.3 pour que Nextcloud fonctionne mieux. Vous devrez alors indiquer le dossier d’installation, par exemple celui proposé : /root/projects

Puis vous devrez appuyer sur la touche ‘Entrer’ puis sur ‘Y’.

⏱️ L’installation des logiciels open source est automatisée mais cela dure environ 15/20 minutes…. temps durant lequel vous devez restez devant votre écran pour valider les installations des différents logiciels en appuyant sur les touches ‘Y’ ou ‘O’, puis sur ‘Entrer’.

➡️Une fois l’installation terminée, passez directement à l’étape 6 pour configurer les logiciels.

🏆 L’installation terminée, vous pouvez vous connecter aux différents logiciels et les adapter ou les personnaliser à votre entreprise ou cabinet d’avocats.

🧑‍💻Vous accèderez aux logiciels de votre plateforme, en tapant les adresses suivantes dans la barre d’adresse de votre navigateur (remplacer exemple.com par le nom de domaine de votre entreprise ou cabinet d’avocats) :
- cloud.exemple.com : pour accéder à Nextcloud, l’application de gestion de fichiers et de collaboration avec vos collaborateurs et clients
- facturation.exemple.com  : pour accéder à l’application de facturation Invoiceninja afin d’envoyer des factures et des propositions de devis à vos clients
- onlyoffice.exemple.com : pour accéder à la suite bureautique en ligne Onlyoffice afin de créer et d’éditer des documents Office Word, Excel…
- visio.exemple.com : pour accéder à Jitsi Meet afin d’organiser des visioconférences avec vos clients ou vos partenaires
- pdf.exemple.com : pour accéder à SignaturePDF afin d’annoter et modifier des fichiers PDF de manière confidentielle
- exemple.com/wp-login : pour accéder à l’interface administrateur de WordPress afin de créer et d’éditer votre site internet ‘exemple.com’ à destination de vos clients
- ai.exemple.com : pour accéder à ‘LibreChat’, logiciel d’intelligence artificielle permettant utiliser des LLM open source tel que Mistral ou GPT4 de la société OpenAI (avec une clé API)
- vocal.exemple.com : pour utiliser la reconnaissance vocale Whisper de la société OpenAI avec un hébergement des données vocales sur votre serveur / VPS

**6. Etape 6 – Configuration et personnalisation de la solution logicielle**

*6.1. Configurez Nextcloud :*

Indiquez dans la barre d’adresse de votre navigateur l’adresse crée : https://cloud.exemple.com

Puis, pour terminer l’installation de Nextcloud, vous devez :
1 – Créer un compte administrateur :
Username : John SNOW (ou choisir « admin », un nom d’utilisateur / administrateur de votre choix)
Password : mon-super-mot-de-passe-tres-complique!-de-2024
2 – Saisir le chemin du dossier de données Nextcloud (il est pré-rempli en principe) ;
3 – Cliquer sur le bouton « Postgre SQL »
4 – Entrer les détails de la base de données :
johnsnow (le nom d’utilisateur que vous avez choisi auparavant)
mon-super-mot-de-passe-tres-complique!-de-2024
nexcloud (le nom de la base de données)
localhost (vous pouvez également indiquer localhost:5432 comme adresse d’hôte, car PostgreSQL écoute sur le port 5432)

Nextcloud est installé !

*6.2. Configurez InvoiceNinja :*

Accédez à l’adresse https://facturation.exemple.com/setup pour lancer l’assistant de configuration Web du logiciel InvoiceNinja.

1 – Tout d’abord, vous devez désigner une URL pour votre installation InvoiceNinja : https://facturation.exemple.com

2 – Cliquez ensuite sur le bouton ‘Tester le PDF’ .

3 – Si cela réussit, vous entrerez alors les informations d’identification de connexion à la base de données : votre nom d’utilisateur principal que vous avez choisi lors de l’exécution du script, puis votre mot de passe principal :
localhost (prérempli)
3306 (prérempli)
invoiceninja (prérempli)
johnsnow (le nom d’utilisateur que vous avez choisi auparavant)
mon-super-mot-de-passe-tres-complique!-de-2024

4 – Cliquez sur le bouton Tester la connexion .

5 – Ensuite, entrez les paramètres SMTP pour vous assurer qu’il peut mettre fin aux factures de vos clients par e-mail.

Host: imap.avocat.fr
Username: camille.demonstration@avocat.fr
Password: votre-mot-de-passe-de-votre-adresse-e-mail-avocat.fr
Port: 587
Encryption: STARTTLS

7 – Cliquez ensuite sur le bouton ‘Envoyer un e-mail de test’ sur le site internet pour vérifier si cela fonctionne.

8 – Enfin, créez un compte administrateur.

9 – Après avoir créé l’utilisateur administrateur, vous pouvez vous connecter à InvoiceNinja à l’adresse https://facturation.exemple.com et le configurer selon votre entreprise.

*6.3. Configurez WordPress :*

Connectez vous à l’adresse : https://exemple.com

1 – Créez un compte administrateur et cliquez sur le bouton Installer WordPress .

Désormais, votre nouveau site WordPress est installé.

2 – Pour éditer votre site WordPress pour le personnaliser à votre entreprise ou cabinet d’avocats, connectez-vous à l’adresse :

https://exemple.com/wp-admin

Félicitations WordPress est installé !

🆘 Vous souhaitez que nous nous occupions de l’installation, des mises à jour régulières et/ou de l’assistance technique ?
➡️ Consultez nos offres de services…

**7. Installation d’un serveur mail avec Modoboa :**

➡️ Connectez vous à votre serveur SSH via le logiciel Putty en indiquant le port 22 ou le port 34067 tel qu’il a été modifié lors que l’exécution du premier script.

➡️ Exécutez la commande suivante :

bash <(wget -qO- https://raw.githubusercontent.com/Arthur-Llevelys/Juris-Tyr/main/mail-script-modaboa-apache2);

➡️ Vous allez devoir indiquer :

votre nom de domaine : exemple.com
un nom d’utilisateur principal en lettres minuscules, par exemple : johnsnow (ou n’importe quelle autre nom d’utilisateur si vous n’êtes pas John SNOW)
votre adresse e-mail : contact@exemple.com
Puis, vous devrez appuyer sur la touche ‘Entrer’

⏱️ L’installation du serveur mail est automatisée mais cela dure environ 10 minutes…. temps durant lequel vous devez restez devant votre écran pour valider les installations des différents prologiciels en appuyant sur les touches ‘Y’ ou ‘O’, puis sur ‘Entrer’.

**Etape 8 – Configuration :**

Une fois que Modoboa a terminé l’installation, vous pouvez vous connecter au panneau d’administration avec le nom d’utilisateur admin et le mot de passe por gérer les adresses e-mails de votre serveur.

Allez sur : https://mail.exemple.com

Votre identifiant de connexion est : Admin
et le mot de passe est : password.

Une fois connecté à Modoboa, changez votre nom d’utilisateur et/ou votre mot de passe.

Cliquez sur le nom d’utilisateur en haut à droite du panneau de menu, puis allez dans paramètres >> profil pour effectuer les modifications.

Configurez votre serveur mail : mail.exemple.com :

*8.1. Configuration initiale :*

Pour configurer des domaines pour le serveur, cliquez sur Domaines dans la barre de menu supérieure, puis cliquez sur le bouton Ajouter +.
Assurez-vous d’activer la signature Dkim. Une fois le domaine configuré, vous pouvez récupérer la clé publique pour DKIM en sélectionnant Domaines dans la barre de menu supérieure, puis cliquez sur le nom de domaine.
Cliquez sur le bouton Afficher la clé dans la zone DNS en haut à droite. Vous devrez ajouter la clé de domaine à vos paramètres DNS.

Vous devez modifier les ports IMAP et SMTP et activer SSL/TLS :
Cliquez sur Modoboa dans la barre de menu, puis sélectionnez l’onglet Webmail.
Sous les paramètres IMAP, cliquez sur le bouton radio pour utiliser une connexion sécurisée. et changez le port en 993.
Sous les paramètres SMTP, cliquez sur le bouton radio pour activer STARTTLS, changez le port du serveur en 587,
puis cliquez sur le bouton radio « Oui » pour exiger l’authentification.
Cliquez sur Enregistrer.

Allez dans l’onglet Domaines et cliquez sur le bouton Ajouter pour ajouter un nouveau domaine.

Dans l’écran suivant, vous pouvez choisir de créer un compte administrateur pour votre domaine.
Le protocole SMTP exige qu’un serveur de messagerie ait une adresse postmaster@exemple.com

Ensuite, entrez votre nom de domaine principal dans le champ Nom. Il est fortement recommandé d’activer la signature DKIM, ce qui peut contribuer à la réputation de votre domaine. Dans le champ Sélecteur de clé, vous pouvez saisir un mot aléatoire comme modoboa.
Choisissez 2048 comme clé. longueur.
Cliquez sur le bouton Soumettre et votre nom de domaine sera ajouté dans Modoboa.

Notez que le compte administrateur par défaut créé lors de l’installation n’est pas un compte de messagerie.

*8.2. Ajoutez des adresses e-mail :*

Pour ajouter des adresses e-mail, accédez à l’onglet Domaines et cliquez sur votre nom de domaine.
Puis cliquez sur les boîtes aux lettres.
Cliquez sur le bouton Ajouter et choisissez Compte.
Ensuite, choisissez Utilisateur simple comme rôle.
Entrez une adresse e-mail dans le champ Nom d’utilisateur et entrez un mot de passe. »
Dans l’écran suivant, vous pouvez éventuellement créer un alias pour cette adresse e-mail.
Après avoir cliqué sur le bouton Soumettre, l’adresse e-mail est créée

*Etape 9 – Sécurisez votre l’accès à votre serveur VPS :*

Nous avons déjà modifié le port d’accès au serveur VPS qui était 22 en 34067 via une connexion SSH. Nous allons désormais installer une double authentification lorsque vous vous connectez à votre serveur VPS.

L’authentification en deux étapes permet d’ajouter une sécurité en plus du mot de passe, à savoir un code généré par une application spécifique sur votre smartphone.

Une fois connecté à votre serveur VPS avec le logiciel Putty sous le nouveau port d’accès 34067 (et non plus 22), exécutez les commandes suivantes :

sudo apt-get install libpam-google-authenticatorCopier

Puis exécutez la commande :

google-authenticatorCopier

Le logiciel vous demande si vous voulez des codes limités dans le temps.

➡️ Répondez oui en appuyant sur la touche ‘y’.

Ensuite, le logiciel Google Authenticator générera un QR Code.

➡️ Vous devez prendre votre smartphone installer l’application Authenticator (iOS ou Android).

➡️ Puis vous devez flasher le QR Code qui s’est affiché sur votre écran d’ordinateur.

Vous pouvez aussi y accéder via l’URL fournie dans le terminal.

Une série de codes d’urgences va s’afficher dans le terminal :

➡️ Vous devez impérativement copier ces codes dans un fichier que vous conserverez (ou les écrire sur un papier). Cela vous permettra de vous connecter quand même à votre serveur même si votre téléphone vous a lâché ou que vous l’avez formaté.

➡️ Appuyez ensuite sur la touche « y » pour mettre à jour la configuration Google Authenticator.

Le logiciel vous posera 3 questions relatives à la configuration.

La première conserne l’utilisation multiple du même code.

➡️ Appuyez sur la touche « y » pour désactiver cette possibilité (en cas d’attaques Mitm (man in the middle))

Le logiciel vous demandera également la durée de péremption des codes. Par défaut, un code est valide 1min30 après qu’il soit passé. Cela permet d’absorber les latences qu’elles soient réseau ou humaines (si vous avez tendance à taper sur votre clavier lentement, une touche / un doigt à la fois).

➡️ Appuyez sur la touche ‘n’ sauf si vous voulez passer cette durée à 4 min.

Le logiciel vous demandera enfin d’activer une limite maximum de codes erronés (contre les attaques de type bruteforce.

➡️ Appuyez sur la touche ‘y’.

Il faut désormais configurer le logiciel ssh-server pour qu’il prenne en compte ce nouveau module.

Ouvrez et éditez le fichier /etc/pam.d/sshd

sudo nano /etc/pam.d/sshdCopier
et ajoutez y la ligne :

auth required pam_google_authenticator.so
Copier
Photo d'un smartphone utilisé pour l'authentification en 2 étapes
https://korben.info/activer-lauthentification-2-etapes-serveur-ssh.html
Puis éditez le fichier :

sudo nano /etc/ssh/sshd_configCopier
Et mettez à « yes », la ligne :

ChallengeResponseAuthentication yes

Puis relancez ssh :

sudo /etc/init.d/ssh restartCopier
➡️ Faites un essai en lançant une nouvelle connexion SSH en ouvrant de nouveau le logiciel Putty.

Ne quittez pas votre connexion en cours, car si vous avez fait une erreur quelque part, vous ne pourrez plus vous connecter via SSH à votre serveur…

Votre serveur va vous demander votre mot de passe, puis votre code généré par l’application installée sur votre smartphone.

Félicitations ! vous venez de sécuriser votre accès SSH à votre serveur VPS.
