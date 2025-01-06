using KafkaExample.Shared;
using KafkaExample.Shared.Contracts;
using MassTransit;
using NodaTime;

namespace KafkaExample.RawDataProducer.Services;

public sealed class RawMessageProducer(
    ILogger<RawMessageProducer> logger,
    IConfiguration configuration,
    IServiceScopeFactory serviceScopeFactory,
    IBusControl busControl,
    Telemetry telemetry) : BackgroundService
{
    private const float MinTemperature = 50f;
    private const float MaxTemperature = 150f;
    private const float MinHumidity = 0f;
    private const float MaxHumidity = 100f;

    private readonly Duration _sleepTime =
        Duration.FromMilliseconds(configuration.GetValue("KAFKA_SLEEP_TIME_IN_MS", 1000));

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await busControl.StartAsync(stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                Instant start = SystemClock.Instance.GetCurrentInstant();

                {
                    await using AsyncServiceScope scope = serviceScopeFactory.CreateAsyncScope();
                    ITopicProducer<RawMessage> producer =
                        scope.ServiceProvider.GetRequiredService<ITopicProducer<RawMessage>>();

                    RawMessage message = new()
                    {
                        DeviceId = $"device{telemetry.UniqueId}",
                        Timestamp = DateTimeOffset.Now,
                        Temperature =
                            (float)(Random.Shared.NextDouble() * (MaxTemperature - MinTemperature) + MinTemperature),
                        Humidity = (float)(Random.Shared.NextDouble() * (MaxHumidity - MinHumidity) + MinHumidity),
                        Status = Random.Shared.Next(2) == 0 ? RawMessage.OkStatus : RawMessage.ErrorStatus
                    };

                    await producer.Produce(message, stoppingToken);
                }

                Instant end = SystemClock.Instance.GetCurrentInstant();
                Duration duration = end - start;

                if (duration > _sleepTime)
                {
                    continue;
                }

                Duration remainingSleepTime = _sleepTime - duration;
                await Task.Delay(remainingSleepTime.ToTimeSpan(), stoppingToken);
            }
            catch (OperationCanceledException)
            {
                // Prevent throwing if stoppingToken was signaled
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "{Exception}", ex);
            }
        }

        await busControl.StopAsync(CancellationToken.None);
    }
}
