var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var uploadPath = "/mnt/afs/uploads";

// Ensure upload path exists
Directory.CreateDirectory(uploadPath);

app.MapPost("/upload", async (HttpRequest request) =>
{
    if (!request.HasFormContentType)
        return Results.BadRequest("Form content required");

    var form = await request.ReadFormAsync();
    var file = form.Files.GetFile("file");

    if (file == null || file.Length == 0)
        return Results.BadRequest("No file uploaded");

    var filePath = Path.Combine(uploadPath, Path.GetFileName(file.FileName));

    using (var stream = File.Create(filePath))
    {
        await file.CopyToAsync(stream);
    }

    return Results.Ok("File uploaded");
});

app.Run();
