using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using TodoApi.Models;

namespace TodoApi.Services;

public class AuthService
{
    private readonly IConfiguration _configuration;
    private readonly UserService _userService;

    public AuthService(IConfiguration configuration, UserService userService)
    {
        _configuration = configuration;
        _userService = userService;
    }

    public async Task<User?> RegisterAsync(RegisterRequest request)
    {
        var existingUser = await _userService.GetByUsernameAsync(request.Username);
        if (existingUser != null)
            return null;

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = request.Role == "Admin" ? "Admin" : "User"
        };

        await _userService.CreateAsync(user);
        return user;
    }

    public async Task<string?> LoginAsync(LoginRequest request)
    {
        var user = await _userService.GetByUsernameAsync(request.Username);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return null;

        return GenerateJwtToken(user);
    }

    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var key = Encoding.ASCII.GetBytes(jwtSettings["Secret"]!);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id!),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role)
            }),
            Expires = DateTime.UtcNow.AddDays(7),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}
