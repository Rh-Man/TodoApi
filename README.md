# API Todo avec ASP.NET Core et MongoDB

Une API RESTful sécurisée construite avec ASP.NET Core 10.0, MongoDB et JWT Authentication.

## 🎯 Fonctionnalités

- ✅ CRUD complet pour les Todos
- 🔐 Authentification JWT
- 👥 Gestion des utilisateurs avec rôles (Admin/User)
- 🛡️ Endpoints sécurisés avec autorisation basée sur les rôles
- 🐳 Déploiement Docker et Docker Compose
- 📦 Base de données MongoDB

## 🔒 Règles de sécurité

- **Lecture des Todos** : Tous les utilisateurs authentifiés
- **Création/Modification/Suppression** : Uniquement les utilisateurs avec le rôle Admin

## 📋 Prérequis

- .NET 10.0 SDK
- Docker et Docker Compose
- MongoDB (si exécution locale sans Docker)

## 🚀 Installation et Exécution

### Option 1 : Avec Docker Compose (Recommandé)

1. Clonez le repository :

```bash
git clone <votre-repo-url>
cd TodoApiMongoDB
```

2. Lancez l'application avec Docker Compose :

```bash
docker-compose up --build
```

3. L'API sera accessible sur :
   - HTTP: http://localhost:5000
   - HTTPS: https://localhost:5001
   - Swagger UI: http://localhost:5000/swagger

### Option 2 : Exécution locale

1. Assurez-vous que MongoDB est en cours d'exécution sur `mongodb://localhost:27017`

2. Naviguez vers le dossier du projet :

```bash
cd TodoApi
```

3. Restaurez les packages :

```bash
dotnet restore
```

4. Exécutez l'application :

```bash
dotnet run
```

## 📚 Utilisation de l'API

### 1. Inscription d'un utilisateur

```bash
POST /api/auth/register
Content-Type: application/json

{
  "username": "admin",
  "email": "admin@example.com",
  "password": "Admin123!",
  "role": "Admin"
}
```

### 2. Connexion

```bash
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "Admin123!"
}
```

Réponse :

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 3. Lire tous les Todos (Authentification requise)

```bash
GET /api/todos
Authorization: Bearer <votre-token>
```

### 4. Créer un Todo (Admin uniquement)

```bash
POST /api/todos
Authorization: Bearer <votre-token>
Content-Type: application/json

{
  "title": "Apprendre ASP.NET Core",
  "description": "Créer une API avec MongoDB",
  "isComplete": false
}
```

### 5. Mettre à jour un Todo (Admin uniquement)

```bash
PUT /api/todos/{id}
Authorization: Bearer <votre-token>
Content-Type: application/json

{
  "title": "Apprendre ASP.NET Core",
  "description": "Créer une API avec MongoDB",
  "isComplete": true
}
```

### 6. Supprimer un Todo (Admin uniquement)

```bash
DELETE /api/todos/{id}
Authorization: Bearer <votre-token>
```

## 🧪 Tests avec cURL

### Inscription d'un admin

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"email\":\"admin@example.com\",\"password\":\"Admin123!\",\"role\":\"Admin\"}"
```

### Connexion

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"Admin123!\"}"
```

### Créer un Todo (remplacez YOUR_TOKEN)

```bash
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d "{\"title\":\"Ma première tâche\",\"description\":\"Description de la tâche\",\"isComplete\":false}"
```

### Lire tous les Todos

```bash
curl -X GET http://localhost:5000/api/todos \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🏗️ Structure du projet

```
TodoApi/
├── Controllers/
│   ├── AuthController.cs      # Authentification (register/login)
│   └── TodosController.cs     # CRUD Todos
├── Models/
│   ├── TodoItem.cs            # Modèle Todo
│   ├── User.cs                # Modèle Utilisateur
│   ├── LoginRequest.cs        # DTO Login
│   ├── RegisterRequest.cs     # DTO Register
│   └── TodoDatabaseSettings.cs # Configuration MongoDB
├── Services/
│   ├── TodoService.cs         # Service Todo
│   ├── UserService.cs         # Service Utilisateur
│   └── AuthService.cs         # Service Authentification
├── Program.cs                 # Configuration de l'application
├── appsettings.json          # Configuration
└── Dockerfile                # Configuration Docker
```

## 🔧 Configuration

Modifiez `appsettings.json` pour personnaliser :

```json
{
  "TodoDatabase": {
    "ConnectionString": "mongodb://localhost:27017",
    "DatabaseName": "TodoDb",
    "TodosCollectionName": "Todos",
    "UsersCollectionName": "Users"
  },
  "JwtSettings": {
    "Secret": "VotreCléSecrète32CaractèresMinimum"
  }
}
```

## 🐳 Commandes Docker utiles

```bash
# Construire et démarrer
docker-compose up --build

# Démarrer en arrière-plan
docker-compose up -d

# Arrêter les conteneurs
docker-compose down

# Voir les logs
docker-compose logs -f

# Supprimer les volumes (réinitialiser la base de données)
docker-compose down -v
```

## 📦 Packages NuGet utilisés

- MongoDB.Driver
- Microsoft.AspNetCore.Authentication.JwtBearer
- System.IdentityModel.Tokens.Jwt
- BCrypt.Net-Next

## 🎓 Ressources

- [Documentation ASP.NET Core](https://docs.microsoft.com/aspnet/core)
- [MongoDB .NET Driver](https://docs.mongodb.com/drivers/csharp/)
- [JWT Authentication](https://jwt.io/)

## 📝 Licence

Ce projet est créé à des fins éducatives.

## 👨‍💻 Auteur

Projet réalisé dans le cadre du cours ASP.NET Core avec MongoDB.
