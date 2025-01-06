using KafkaExample.RawDataConsumer.Data;
using KafkaExample.RawDataConsumer.Repositories;
using KafkaExample.Shared.Contracts;
using MassTransit;
using NodaTime;

namespace KafkaExample.RawDataConsumer.Services;

public sealed class ProcessedMessageProducer(
    ILogger<ProcessedMessageProducer> logger,
    IBusControl busControl,
    IServiceScopeFactory serviceScopeFactory) : BackgroundService
{
    private static readonly Duration s_sleepTime = Duration.FromSeconds(60);

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
                    IRawDataRepository repository =
                        scope.ServiceProvider.GetRequiredService<IRawDataRepository>();
                    ITopicProducer<ProcessedMessage> producer =
                        scope.ServiceProvider.GetRequiredService<ITopicProducer<ProcessedMessage>>();

                    IList<RawData> rawData = await repository.GetAll(stoppingToken);

                    float aggregatedTemperature = rawData.Average(d => d.Message.Temperature);
                    List<RawMessage> filteredDataList = rawData
                        .Select(data => data.Message)
                        .Where(data => data.Status != RawMessage.OkStatus || data.Temperature > 100f)
                        .ToList();

                    ProcessedMessage processedMessage = new()
                    {
                        Timestamp = DateTimeOffset.UtcNow,
                        AggregatedTemperature = aggregatedTemperature,
                        FilteredDataList = filteredDataList
                    };

                    await producer.Produce(processedMessage, stoppingToken);

                    int maxRowId = rawData.Max(d => d.Id);
                    await repository.DeleteOldRows(maxRowId, stoppingToken);
                }

                Instant end = SystemClock.Instance.GetCurrentInstant();
                Duration duration = end - start;

                if (duration > s_sleepTime)
                {
                    continue;
                }

                Duration remainingSleepTime = s_sleepTime - duration;
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
