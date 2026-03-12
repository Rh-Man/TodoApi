# Guide de Déploiement - API Todo

## 📦 Options de Déploiement

### Option 1 : Déploiement avec Docker (Recommandé)

#### Prérequis

- Docker Desktop installé
- Docker Compose installé

#### Étapes

1. **Cloner le repository**

```bash
git clone <votre-repo-url>
cd TodoApiMongoDB
```

2. **Construire et lancer les conteneurs**

```bash
docker-compose up --build -d
```

3. **Vérifier que les conteneurs sont en cours d'exécution**

```bash
docker-compose ps
```

4. **Accéder à l'API**

- API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger

5. **Voir les logs**

```bash
docker-compose logs -f todoapi
```

6. **Arrêter l'application**

```bash
docker-compose down
```

### Option 2 : Déploiement sur GitLab avec GitLab CI/CD

#### 1. Créer un fichier `.gitlab-ci.yml`

```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $DOCKER_IMAGE ./TodoApi
    - docker push $DOCKER_IMAGE

deploy:
  stage: deploy
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker-compose up -d
  only:
    - main
```

#### 2. Configurer les variables d'environnement dans GitLab

- Aller dans Settings > CI/CD > Variables
- Ajouter les variables nécessaires

### Option 3 : Déploiement sur Azure Container Instances

#### 1. Installer Azure CLI

```bash
# Windows
winget install Microsoft.AzureCLI

# Ou télécharger depuis https://aka.ms/installazurecliwindows
```

#### 2. Se connecter à Azure

```bash
az login
```

#### 3. Créer un groupe de ressources

```bash
az group create --name TodoApiResourceGroup --location eastus
```

#### 4. Créer une instance MongoDB (Azure Cosmos DB)

```bash
az cosmosdb create \
  --name todoapi-cosmosdb \
  --resource-group TodoApiResourceGroup \
  --kind MongoDB \
  --server-version 4.2
```

#### 5. Construire et pousser l'image Docker vers Azure Container Registry

```bash
# Créer un registre
az acr create --resource-group TodoApiResourceGroup \
  --name todoapiacr --sku Basic

# Se connecter au registre
az acr login --name todoapiacr

# Construire et pousser l'image
docker build -t todoapiacr.azurecr.io/todoapi:v1 ./TodoApi
docker push todoapiacr.azurecr.io/todoapi:v1
```

#### 6. Déployer sur Azure Container Instances

```bash
az container create \
  --resource-group TodoApiResourceGroup \
  --name todoapi-container \
  --image todoapiacr.azurecr.io/todoapi:v1 \
  --dns-name-label todoapi-unique \
  --ports 8080 \
  --environment-variables \
    TodoDatabase__ConnectionString="<votre-connection-string>" \
    TodoDatabase__DatabaseName="TodoDb" \
    JwtSettings__Secret="YourSuperSecretKey"
```

### Option 4 : Déploiement sur Heroku

#### 1. Installer Heroku CLI

```bash
# Windows
winget install Heroku.HerokuCLI
```

#### 2. Se connecter à Heroku

```bash
heroku login
```

#### 3. Créer une application

```bash
heroku create todoapi-aspnet
```

#### 4. Ajouter MongoDB Atlas

```bash
heroku addons:create mongolab:sandbox
```

#### 5. Configurer les variables d'environnement

```bash
heroku config:set JwtSettings__Secret="YourSuperSecretKey"
```

#### 6. Déployer avec Docker

```bash
heroku container:login
heroku container:push web -a todoapi-aspnet
heroku container:release web -a todoapi-aspnet
```

### Option 5 : Déploiement sur un VPS (DigitalOcean, Linode, etc.)

#### 1. Se connecter au serveur

```bash
ssh root@votre-ip
```

#### 2. Installer Docker et Docker Compose

```bash
# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Installer Docker Compose
apt-get install docker-compose-plugin
```

#### 3. Cloner le repository

```bash
git clone <votre-repo-url>
cd TodoApiMongoDB
```

#### 4. Configurer les variables d'environnement

```bash
nano docker-compose.yml
# Modifier les variables selon vos besoins
```

#### 5. Lancer l'application

```bash
docker-compose up -d
```

#### 6. Configurer Nginx comme reverse proxy (optionnel)

```bash
apt-get install nginx

# Créer la configuration
nano /etc/nginx/sites-available/todoapi
```

Contenu du fichier :

```nginx
server {
    listen 80;
    server_name votre-domaine.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Activer le site
ln -s /etc/nginx/sites-available/todoapi /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## 🔒 Configuration de la Sécurité

### Changer la clé secrète JWT

Dans `appsettings.json` ou via variables d'environnement :

```json
{
  "JwtSettings": {
    "Secret": "VotreNouvelleCleSuperSecrete32CaracteresMinimum"
  }
}
```

### Utiliser HTTPS en production

1. Obtenir un certificat SSL (Let's Encrypt)
2. Configurer Kestrel pour HTTPS
3. Rediriger HTTP vers HTTPS

## 📊 Monitoring et Logs

### Voir les logs Docker

```bash
docker-compose logs -f
```

### Logs spécifiques à un service

```bash
docker-compose logs -f todoapi
docker-compose logs -f mongodb
```

## 🧪 Tests après déploiement

### Test de santé de l'API

```bash
curl http://votre-url/api/todos
```

### Test d'inscription

```bash
curl -X POST http://votre-url/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","email":"admin@example.com","password":"Admin123!","role":"Admin"}'
```

### Test de connexion

```bash
curl -X POST http://votre-url/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'
```

## 🔧 Dépannage

### Le conteneur ne démarre pas

```bash
docker-compose logs todoapi
```

### Problème de connexion à MongoDB

- Vérifier que MongoDB est en cours d'exécution
- Vérifier la chaîne de connexion
- Vérifier les règles de pare-feu

### Erreur 401 Unauthorized

- Vérifier que le token JWT est valide
- Vérifier que le header Authorization est correct
- Vérifier que la clé secrète est la même

## 📝 Checklist de déploiement

- [ ] Changer la clé secrète JWT
- [ ] Configurer la chaîne de connexion MongoDB
- [ ] Activer HTTPS
- [ ] Configurer les CORS si nécessaire
- [ ] Tester tous les endpoints
- [ ] Configurer les sauvegardes de la base de données
- [ ] Configurer le monitoring
- [ ] Documenter l'URL de l'API
