# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["TodoApi.csproj", "./"]
RUN dotnet restore "TodoApi.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "TodoApi.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "TodoApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TodoApi.dll"]
