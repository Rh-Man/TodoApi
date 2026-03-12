using Microsoft.Extensions.Options;
using MongoDB.Driver;
using TodoApi.Models;

namespace TodoApi.Services;

public class UserService
{
    private readonly IMongoCollection<User> _usersCollection;

    public UserService(IOptions<TodoDatabaseSettings> todoDbSettings)
    {
        var mongoClient = new MongoClient(todoDbSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(todoDbSettings.Value.DatabaseName);
        _usersCollection = mongoDatabase.GetCollection<User>(todoDbSettings.Value.UsersCollectionName);
    }

    public async Task<User?> GetByUsernameAsync(string username) =>
        await _usersCollection.Find(x => x.Username == username).FirstOrDefaultAsync();

    public async Task<User?> GetByEmailAsync(string email) =>
        await _usersCollection.Find(x => x.Email == email).FirstOrDefaultAsync();

    public async Task CreateAsync(User newUser) =>
        await _usersCollection.InsertOneAsync(newUser);

    public async Task<List<User>> GetAsync() =>
        await _usersCollection.Find(_ => true).ToListAsync();
}
