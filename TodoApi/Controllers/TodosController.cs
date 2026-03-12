using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TodoApi.Models;
using TodoApi.Services;

namespace TodoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TodosController : ControllerBase
{
    private readonly TodoService _todoService;

    public TodosController(TodoService todoService)
    {
        _todoService = todoService;
    }

    [HttpGet]
    public async Task<List<TodoItem>> Get() =>
        await _todoService.GetAsync();

    [HttpGet("{id:length(24)}")]
    public async Task<ActionResult<TodoItem>> Get(string id)
    {
        var todo = await _todoService.GetAsync(id);
        if (todo is null)
            return NotFound();

        return todo;
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Post(TodoItem newTodo)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        newTodo.UserId = userId;
        await _todoService.CreateAsync(newTodo);
        return CreatedAtAction(nameof(Get), new { id = newTodo.Id }, newTodo);
    }

    [HttpPut("{id:length(24)}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(string id, TodoItem updatedTodo)
    {
        var todo = await _todoService.GetAsync(id);
        if (todo is null)
            return NotFound();

        updatedTodo.Id = todo.Id;
        await _todoService.UpdateAsync(id, updatedTodo);
        return NoContent();
    }

    [HttpDelete("{id:length(24)}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(string id)
    {
        var todo = await _todoService.GetAsync(id);
        if (todo is null)
            return NotFound();

        await _todoService.RemoveAsync(id);
        return NoContent();
    }
}
