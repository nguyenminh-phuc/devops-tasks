using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace KafkaExample.RawDataProducer.Services;

public sealed class HealthCheck : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default) =>
        Task.FromResult(HealthCheckResult.Healthy());
}
