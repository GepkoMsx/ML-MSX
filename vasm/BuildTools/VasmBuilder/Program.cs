using VasmBuilder;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

// check the args first
Console.WriteLine("VasmBuilder");
if (args.Length < 2)
{
    Console.WriteLine("Usage: VasmBuilder <file> <folder>");
    return;
}


// this sets up the host for dependency injection, configuration, logging, etc.
// we use configuration to read the settings from the appsettings.json file.
HostApplicationBuilder builder = Host.CreateApplicationBuilder(args);
builder.Logging.SetMinimumLevel(LogLevel.Warning);

builder.Services.AddSingleton(args);
builder.Services.Configure<BuildSettings>(builder.Configuration);
builder.Services.AddHostedService<VasmWorker>();

using IHost host = builder.Build();
await host.RunAsync();
