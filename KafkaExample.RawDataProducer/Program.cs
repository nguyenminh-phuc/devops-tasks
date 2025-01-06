using KafkaExample.RawDataProducer.Services;
using KafkaExample.Shared;
using KafkaExample.Shared.Contracts;
using KafkaExample.Shared.Utils;
using MassTransit;
using MassTransit.Logging;
using MassTransit.Monitoring;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddEnvironmentVariables();

builder.Services.AddControllers();

builder.Services.AddMassTransit(x =>
{
    x.SetKebabCaseEndpointNameFormatter();

    x.UsingInMemory();

    x.AddRider(rider =>
    {
        rider.AddProducer<RawMessage>(builder.Configuration["KAFKA_RAW_TOPIC"]);

        rider.UsingKafka((_, configure) => { configure.Host(builder.Configuration["KAFKA_ENDPOINT"]); });
    });
});

builder.Services.AddHostedService<RawMessageProducer>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

AddTelemetry(builder);

WebApplication app = builder.Build();

MapHealthChecks(app);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.MapPrometheusScrapingEndpoint();

app.Run();
return;

static void AddTelemetry(WebApplicationBuilder builder)
{
    Telemetry telemetry = new(builder.Configuration, builder.Environment);
    builder.Services.AddSingleton(telemetry);

    string? otlpEndpoint = OtlpUtils.GetEndpoint(builder.Configuration);
    builder.Services.AddOpenTelemetry()
        .ConfigureResource(resource => resource.AddService(
            telemetry.ServiceName,
            serviceVersion: telemetry.ServiceVersion,
            serviceInstanceId: telemetry.ServiceInstanceId))
        .WithMetrics(metrics => metrics
            .AddMeter(telemetry.Meter.Name)
            .AddMeter(InstrumentationOptions.MeterName)
            .AddAspNetCoreInstrumentation()
            .AddPrometheusExporter())
        .WithTracing(tracing =>
        {
            tracing.AddAspNetCoreInstrumentation()
                .AddSource(telemetry.ActivitySource.Name)
                .AddSource(DiagnosticHeaders.DefaultListenerName);

            if (otlpEndpoint is not null)
            {
                tracing.AddOtlpExporter(otlpOptions => { otlpOptions.Endpoint = new Uri(otlpEndpoint); });
            }
            else
            {
                tracing.AddConsoleExporter();
            }
        })
        .WithLogging(logging => logging.AddConsoleExporter());
}

static void MapHealthChecks(WebApplication app)
{
    app.MapHealthChecks(
        "/healthz/ready",
        new HealthCheckOptions {Predicate = healthCheck => healthCheck.Tags.Contains("ready")});
    app.MapHealthChecks(
        "/healthz/live",
        new HealthCheckOptions {Predicate = _ => false});
}
