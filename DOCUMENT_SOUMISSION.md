# Document de Soumission - Projet API Todo

## Informations Générales

**Projet**: API Todo avec ASP.NET Core et MongoDB  
**Date**: 12 Mars 2026  
**Cours**: ASP.NET Core - Sécurité des Applications

---

## 1. Lien GitHub (Repository Public)

**URL**: https://github.com/Rh-Man/TodoApi.git

Le repository contient l'intégralité du code source, la documentation, les Dockerfiles et les scripts de test.

---

## 2. Instructions d'Exécution

### Méthode 1: Docker Compose (Recommandée)

```bash
# Cloner le repository
git clone https://github.com/Rh-Man/TodoApi.git
cd TodoApi

# Lancer avec Docker Compose
docker-compose up --build

# Accéder à l'API
# Swagger UI: http://localhost:5000/swagger
# API: http://localhost:5000
```

### Méthode 2: Exécution Locale

```bash
# Démarrer MongoDB
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Lancer l'API
cd TodoApi
dotnet run

# Accéder à l'API
# Swagger UI: http://localhost:5110/swagger
# API: http://localhost:5110
```

---

## 3. Objectifs Réalisés

### ✅ Objectif 1: Créer une API web avec ASP.NET Core et MongoDB

- API RESTful complète avec opérations CRUD
- Utilisation de MongoDB comme base de données
- Architecture en couches (Controllers, Services, Models)
- MongoDB.Driver 3.7.0 pour l'accès aux données

**Fichiers clés**:

- `TodoApi/Controllers/TodosController.cs`
- `TodoApi/Services/TodoService.cs`
- `TodoApi/Models/TodoItem.cs`

### ✅ Objectif 2: Sécuriser les Endpoints

**Règles de sécurité implémentées**:

- Seuls les utilisateurs avec le rôle **Admin** peuvent créer, modifier ou supprimer des Todos
- Tous les utilisateurs **authentifiés** peuvent lire les Todos
- Authentification via JWT (JSON Web Tokens)
- Mots de passe hachés avec BCrypt

**Implémentation**:

```csharp
[Authorize]  // Tous les endpoints nécessitent l'authentification
public class TodosController : ControllerBase
{
    [HttpGet]  // Lecture: tous les utilisateurs authentifiés
    public async Task<List<TodoItem>> Get() { ... }

    [HttpPost]
    [Authorize(Roles = "Admin")]  // Création: Admin uniquement
    public async Task<IActionResult> Post(TodoItem newTodo) { ... }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]  // Modification: Admin uniquement
    public async Task<IActionResult> Update(...) { ... }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]  // Suppression: Admin uniquement
    public async Task<IActionResult> Delete(string id) { ... }
}
```

### ✅ Objectif 3: Déploiement avec Docker

**Dockerfile multi-stage** pour optimiser la taille de l'image:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
# Build stage...

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
# Runtime stage...
```

**Docker Compose** pour orchestrer l'API et MongoDB:

```yaml
services:
  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"

  todoapi:
    build: ./TodoApi
    ports:
      - "5000:8080"
    depends_on:
      - mongodb
```

---

## 4. Tests et Validation

### Tests Réalisés avec Succès

| Test                  | Endpoint                | Résultat           |
| --------------------- | ----------------------- | ------------------ |
| Inscription Admin     | POST /api/auth/register | ✅ Succès          |
| Connexion Admin       | POST /api/auth/login    | ✅ Token JWT reçu  |
| Création Todo (Admin) | POST /api/todos         | ✅ Todo créé       |
| Lecture Todos (User)  | GET /api/todos          | ✅ Liste récupérée |
| Mise à jour (Admin)   | PUT /api/todos/{id}     | ✅ 204 No Content  |
| Suppression (Admin)   | DELETE /api/todos/{id}  | ✅ 204 No Content  |
| Création par User     | POST /api/todos         | ✅ 403 Forbidden   |

### Résultat du Script de Test

```
=== Test de l'API Todo ===

1. Inscription Admin...
Admin enregistre: 69b2ef5fa1541d84d8f14bb3

2. Connexion Admin...
Token recu

3. Creation Todo (Admin)...
Todo cree: 69b2ef60a1541d84d8f14bb4

4. Lecture Todos...
Nombre de todos: 1

5. Mise a jour Todo...
Todo mis a jour

6. Suppression Todo...
Todo supprime

=== Tests termines avec succes ===
```

---

## 5. Technologies et Packages

### Backend

- **ASP.NET Core**: 10.0
- **C#**: 13

### Base de Données

- **MongoDB**: 7.0 (latest)
- **MongoDB.Driver**: 3.7.0

### Sécurité

- **JWT Authentication**: Microsoft.AspNetCore.Authentication.JwtBearer 10.0.4
- **Hachage**: BCrypt.Net-Next 4.1.0
- **Tokens**: System.IdentityModel.Tokens.Jwt 8.16.0

### Documentation

- **Swagger/OpenAPI**: Swashbuckle.AspNetCore 10.1.5

### Déploiement

- **Docker**
- **Docker Compose**

---

## 6. Architecture du Projet

```
TodoApi/
├── Controllers/
│   ├── AuthController.cs       # Authentification (register/login)
│   └── TodosController.cs      # CRUD Todos avec autorisation
├── Models/
│   ├── User.cs                 # Modèle utilisateur avec rôle
│   ├── TodoItem.cs             # Modèle Todo
│   ├── LoginRequest.cs         # DTO pour login
│   ├── RegisterRequest.cs      # DTO pour inscription
│   └── TodoDatabaseSettings.cs # Configuration MongoDB
├── Services/
│   ├── AuthService.cs          # Logique authentification + JWT
│   ├── UserService.cs          # Accès données utilisateurs
│   └── TodoService.cs          # Accès données todos
├── Program.cs                  # Configuration (JWT, MongoDB, Swagger)
├── appsettings.json           # Configuration application
├── Dockerfile                 # Image Docker
└── TodoApi.csproj             # Dépendances NuGet
```

---

## 7. Endpoints de l'API

### Authentification (Public)

| Méthode | Endpoint           | Description | Autorisation |
| ------- | ------------------ | ----------- | ------------ |
| POST    | /api/auth/register | Inscription | Public       |
| POST    | /api/auth/login    | Connexion   | Public       |

### Gestion des Todos (Authentifié)

| Méthode | Endpoint        | Description         | Autorisation |
| ------- | --------------- | ------------------- | ------------ |
| GET     | /api/todos      | Lire tous les todos | Authentifié  |
| GET     | /api/todos/{id} | Lire un todo        | Authentifié  |
| POST    | /api/todos      | Créer un todo       | Admin        |
| PUT     | /api/todos/{id} | Modifier un todo    | Admin        |
| DELETE  | /api/todos/{id} | Supprimer un todo   | Admin        |

---

## 8. Sécurité Implémentée

### 1. Authentification JWT

- Tokens signés avec HMAC-SHA256
- Expiration de 7 jours
- Claims: ID utilisateur, nom, email, rôle

### 2. Hachage des Mots de Passe

- BCrypt avec salt automatique
- Pas de stockage en clair

### 3. Autorisation par Rôles

- Attribut `[Authorize]` sur les endpoints protégés
- Attribut `[Authorize(Roles = "Admin")]` pour les opérations sensibles

### 4. Validation

- Validation des tokens sur chaque requête
- Vérification des rôles avant l'exécution

### 5. Configuration Sécurisée

- Secrets dans `appsettings.json` (à externaliser en production)
- Variables d'environnement pour Docker
- HTTPS en production

---

## 9. Documentation Fournie

### Fichiers de Documentation

1. **README.md**: Instructions complètes d'installation et d'utilisation
2. **PREUVE_REUSSITE.md**: Preuves des tests et captures
3. **DEPLOYMENT_GUIDE.md**: Guide de déploiement multi-plateformes
4. **INSTRUCTIONS_FINALES.md**: Checklist et conseils
5. **SOUMISSION.txt**: Document de soumission texte
6. **TodoApi.postman_collection.json**: Collection Postman pour tests
7. **test-api-simple.ps1**: Script PowerShell de test automatisé

### Swagger UI

Interface interactive disponible sur `/swagger`:

- Documentation automatique de tous les endpoints
- Test des endpoints directement depuis le navigateur
- Support de l'authentification JWT

---

## 10. Démonstration de la Sécurité

### Scénario 1: Utilisateur Admin

```bash
# 1. Inscription
POST /api/auth/register
{
  "username": "admin",
  "email": "admin@example.com",
  "password": "Admin123!",
  "role": "Admin"
}
→ Succès: Utilisateur créé

# 2. Connexion
POST /api/auth/login
{
  "username": "admin",
  "password": "Admin123!"
}
→ Succès: Token JWT reçu

# 3. Création d'un Todo
POST /api/todos
Authorization: Bearer <token>
{
  "title": "Ma tâche",
  "description": "Description",
  "isComplete": false
}
→ Succès: Todo créé
```

### Scénario 2: Utilisateur Normal (User)

```bash
# 1. Inscription
POST /api/auth/register
{
  "username": "user1",
  "email": "user1@example.com",
  "password": "User123!",
  "role": "User"
}
→ Succès: Utilisateur créé

# 2. Connexion
POST /api/auth/login
{
  "username": "user1",
  "password": "User123!"
}
→ Succès: Token JWT reçu

# 3. Lecture des Todos
GET /api/todos
Authorization: Bearer <token>
→ Succès: Liste des todos

# 4. Tentative de création (devrait échouer)
POST /api/todos
Authorization: Bearer <token>
{
  "title": "Test",
  "description": "Test",
  "isComplete": false
}
→ Échec: 403 Forbidden (comme attendu)
```

---

## 11. Cours "Sécurisez votre application .NET"

Ce projet démontre la maîtrise des concepts suivants:

✅ **Authentification sécurisée**: Implémentation de JWT  
✅ **Autorisation**: Contrôle d'accès basé sur les rôles  
✅ **Cryptographie**: Hachage BCrypt des mots de passe  
✅ **Protection des endpoints**: Attributs [Authorize]  
✅ **Validation**: Vérification des tokens et des rôles  
✅ **Gestion des secrets**: Configuration sécurisée  
✅ **Bonnes pratiques**: Architecture propre et maintenable

---

## 12. Conclusion

### Objectifs Atteints

✅ API web créée avec ASP.NET Core 10.0 et MongoDB  
✅ Endpoints sécurisés avec JWT et autorisation par rôles  
✅ Déploiement avec Docker et Docker Compose  
✅ Documentation complète et tests réussis  
✅ Code source disponible sur GitHub (public)

### Liens Importants

- **Repository GitHub**: https://github.com/Rh-Man/TodoApi.git
- **Documentation**: Voir README.md dans le repository
- **Preuves**: Voir PREUVE_REUSSITE.md dans le repository

### Prêt pour la Production

Le projet est complet, testé et prêt à être déployé sur n'importe quelle plateforme supportant Docker (Azure, AWS, Heroku, GitLab CI/CD, etc.).

---

**Merci!**
