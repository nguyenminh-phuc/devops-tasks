using System.Diagnostics;
using System.Diagnostics.Metrics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace KafkaExample.Shared;

public sealed class Telemetry : IDisposable
{
    public Telemetry(IConfiguration configuration, IHostEnvironment hostEnvironment)
    {
        bool containerMode = configuration.GetValue("CONTAINER_MODE", false);

        ServiceName = hostEnvironment.ApplicationName;
        ServiceVersion = configuration["SERVICE_VERSION"];

        UniqueId = Random.Shared.Next(1, 999);
        ServiceInstanceId = containerMode ? Environment.MachineName : $"instance_{UniqueId}";

        Meter = new Meter(ServiceName);
        ActivitySource = new ActivitySource(ServiceName);
    }

    public string ServiceName { get; }

    public string? ServiceVersion { get; }

    public string ServiceInstanceId { get; }

    public int UniqueId { get; }

    public Meter Meter { get; }

    public ActivitySource ActivitySource { get; }

    public void Dispose()
    {
        Meter.Dispose();
        ActivitySource.Dispose();
    }
}
