var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

var key = builder.Configuration["Syncfusion:LicenseKey"];

Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(key);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseExceptionHandler("/error-development");
}
else
{
    app.UseHttpsRedirection();
    app.UseExceptionHandler("/error");
}

app.MapControllers();

app.Run();
