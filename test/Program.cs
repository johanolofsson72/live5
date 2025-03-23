using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Upload API", Version = "v1" });
});
builder.Services.AddDirectoryBrowser();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseDefaultFiles();
app.UseStaticFiles();

var uploadPath = "/mnt/afs/uploads";
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
})
.WithName("UploadFile")
.WithOpenApi();

app.MapGet("/files", () =>
{
    var files = Directory.GetFiles(uploadPath)
        .Select(Path.GetFileName)
        .ToArray();

    return Results.Ok(files);
})
.WithName("ListFiles")
.WithOpenApi();

app.MapGet("/files/{filename}", (string filename) =>
{
    var filePath = Path.Combine(uploadPath, filename);
    if (!System.IO.File.Exists(filePath))
        return Results.NotFound();

    var contentType = "application/octet-stream";
    return Results.File(filePath, contentType, fileDownloadName: filename);
})
.WithName("DownloadFile")
.WithOpenApi();

app.Run();
