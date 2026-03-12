# Script de test de l'API Todo
$baseUrl = "http://localhost:5110"

Write-Host "=== Test de l'API Todo ===" -ForegroundColor Green
Write-Host ""

# Test 1: Inscription d'un admin
Write-Host "1. Inscription d'un utilisateur Admin..." -ForegroundColor Yellow
$registerAdmin = @{
    username = "admin"
    email = "admin@example.com"
    password = "Admin123!"
    role = "Admin"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerAdmin -ContentType "application/json"
    Write-Host "✓ Admin enregistré avec succès: $($response.userId)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Test 2: Inscription d'un utilisateur normal
Write-Host "2. Inscription d'un utilisateur normal..." -ForegroundColor Yellow
$registerUser = @{
    username = "user1"
    email = "user1@example.com"
    password = "User123!"
    role = "User"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerUser -ContentType "application/json"
    Write-Host "✓ Utilisateur enregistré avec succès: $($response.userId)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Test 3: Connexion Admin
Write-Host "3. Connexion en tant qu'Admin..." -ForegroundColor Yellow
$loginAdmin = @{
    username = "admin"
    password = "Admin123!"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginAdmin -ContentType "application/json"
    $adminToken = $response.token
    Write-Host "✓ Connexion réussie! Token reçu." -ForegroundColor Green
    Write-Host "Token: $($adminToken.Substring(0, 50))..." -ForegroundColor Cyan
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
    exit
}

Write-Host ""

# Test 4: Connexion User
Write-Host "4. Connexion en tant qu'User..." -ForegroundColor Yellow
$loginUser = @{
    username = "user1"
    password = "User123!"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginUser -ContentType "application/json"
    $userToken = $response.token
    Write-Host "✓ Connexion réussie! Token reçu." -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Test 5: Créer un Todo (Admin)
Write-Host "5. Création d'un Todo (Admin)..." -ForegroundColor Yellow
$newTodo = @{
    title = "Apprendre ASP.NET Core"
    description = "Créer une API avec MongoDB et JWT"
    isComplete = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/todos" -Method Post -Body $newTodo -Headers $headers
    $todoId = $response.id
    Write-Host "✓ Todo créé avec succès!" -ForegroundColor Green
    Write-Host "  ID: $todoId" -ForegroundColor Cyan
    Write-Host "  Titre: $($response.title)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Test 6: Lire tous les Todos (User)
Write-Host "6. Lecture de tous les Todos (User)..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $userToken"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/todos" -Method Get -Headers $headers
    Write-Host "✓ Todos récupérés avec succès!" -ForegroundColor Green
    Write-Host "  Nombre de todos: $($response.Count)" -ForegroundColor Cyan
    foreach ($todo in $response) {
        Write-Host "  - $($todo.title) (Complete: $($todo.isComplete))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Test 7: Tenter de créer un Todo (User - devrait échouer)
Write-Host "7. Tentative de création d'un Todo (User - devrait échouer)..." -ForegroundColor Yellow
$newTodo2 = @{
    title = "Test non autorisé"
    description = "Ceci ne devrait pas fonctionner"
    isComplete = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $userToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/todos" -Method Post -Body $newTodo2 -Headers $headers
    Write-Host "✗ ERREUR: L'utilisateur a pu créer un Todo!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✓ Accès refusé comme prévu (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "✗ Erreur inattendue: $_" -ForegroundColor Red
    }
}

Write-Host ""

# Test 8: Mettre à jour un Todo (Admin)
if ($todoId) {
    Write-Host "8. Mise à jour du Todo (Admin)..." -ForegroundColor Yellow
    $updateTodo = @{
        id = $todoId
        title = "Apprendre ASP.NET Core"
        description = "API complétée avec succès!"
        isComplete = $true
    } | ConvertTo-Json

    $headers = @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
    }

    try {
        Invoke-RestMethod -Uri "$baseUrl/api/todos/$todoId" -Method Put -Body $updateTodo -Headers $headers
        Write-Host "✓ Todo mis à jour avec succès!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur: $_" -ForegroundColor Red
    }
}

Write-Host ""

# Test 9: Supprimer un Todo (Admin)
if ($todoId) {
    Write-Host "9. Suppression du Todo (Admin)..." -ForegroundColor Yellow
    $headers = @{
        "Authorization" = "Bearer $adminToken"
    }

    try {
        Invoke-RestMethod -Uri "$baseUrl/api/todos/$todoId" -Method Delete -Headers $headers
        Write-Host "✓ Todo supprimé avec succès!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Tests terminés ===" -ForegroundColor Green
