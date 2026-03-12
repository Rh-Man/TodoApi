using Microsoft.Extensions.Options;
using MongoDB.Driver;
using TodoApi.Models;

namespace TodoApi.Services;

public class TodoService
{
    private readonly IMongoCollection<TodoItem> _todosCollection;

    public TodoService(IOptions<TodoDatabaseSettings> todoDbSettings)
    {
        var mongoClient = new MongoClient(todoDbSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(todoDbSettings.Value.DatabaseName);
        _todosCollection = mongoDatabase.GetCollection<TodoItem>(todoDbSettings.Value.TodosCollectionName);
    }

    public async Task<List<TodoItem>> GetAsync() =>
        await _todosCollection.Find(_ => true).ToListAsync();

    public async Task<TodoItem?> GetAsync(string id) =>
        await _todosCollection.Find(x => x.Id == id).FirstOrDefaultAsync();

    public async Task CreateAsync(TodoItem newTodo) =>
        await _todosCollection.InsertOneAsync(newTodo);

    public async Task UpdateAsync(string id, TodoItem updatedTodo) =>
        await _todosCollection.ReplaceOneAsync(x => x.Id == id, updatedTodo);

    public async Task RemoveAsync(string id) =>
        await _todosCollection.DeleteOneAsync(x => x.Id == id);
}
