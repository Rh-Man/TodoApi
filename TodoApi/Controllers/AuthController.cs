using Microsoft.AspNetCore.Mvc;
using TodoApi.Models;
using TodoApi.Services;

namespace TodoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        var user = await _authService.RegisterAsync(request);
        if (user == null)
            return BadRequest(new { message = "Username already exists" });

        return Ok(new { message = "User registered successfully", userId = user.Id });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var token = await _authService.LoginAsync(request);
        if (token == null)
            return Unauthorized(new { message = "Invalid credentials" });

        return Ok(new { token });
    }
}
