# Script de test de l'API Todo
$baseUrl = "http://localhost:5110"

Write-Host "=== Test de l'API Todo ==="
Write-Host ""

# Test 1: Inscription Admin
Write-Host "1. Inscription Admin..."
$registerAdmin = '{"username":"admin","email":"admin@example.com","password":"Admin123!","role":"Admin"}'
$response = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerAdmin -ContentType "application/json"
Write-Host "Admin enregistre: $($response.userId)"
Write-Host ""

# Test 2: Connexion Admin
Write-Host "2. Connexion Admin..."
$loginAdmin = '{"username":"admin","password":"Admin123!"}'
$response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginAdmin -ContentType "application/json"
$adminToken = $response.token
Write-Host "Token recu"
Write-Host ""

# Test 3: Creer un Todo
Write-Host "3. Creation Todo (Admin)..."
$newTodo = '{"title":"Apprendre ASP.NET Core","description":"API avec MongoDB","isComplete":false}'
$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}
$response = Invoke-RestMethod -Uri "$baseUrl/api/todos" -Method Post -Body $newTodo -Headers $headers
$todoId = $response.id
Write-Host "Todo cree: $todoId"
Write-Host ""

# Test 4: Lire tous les Todos
Write-Host "4. Lecture Todos..."
$headers = @{ "Authorization" = "Bearer $adminToken" }
$response = Invoke-RestMethod -Uri "$baseUrl/api/todos" -Method Get -Headers $headers
Write-Host "Nombre de todos: $($response.Count)"
Write-Host ""

# Test 5: Mettre a jour
Write-Host "5. Mise a jour Todo..."
$updateTodo = "{`"id`":`"$todoId`",`"title`":`"ASP.NET Core`",`"description`":`"Complete!`",`"isComplete`":true}"
$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}
Invoke-RestMethod -Uri "$baseUrl/api/todos/$todoId" -Method Put -Body $updateTodo -Headers $headers
Write-Host "Todo mis a jour"
Write-Host ""

# Test 6: Supprimer
Write-Host "6. Suppression Todo..."
$headers = @{ "Authorization" = "Bearer $adminToken" }
Invoke-RestMethod -Uri "$baseUrl/api/todos/$todoId" -Method Delete -Headers $headers
Write-Host "Todo supprime"
Write-Host ""

Write-Host "=== Tests termines avec succes ==="
