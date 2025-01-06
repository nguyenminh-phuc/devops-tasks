using System.Net;
using Amazon.S3;
using Amazon.S3.Model;
using KafkaExample.ProcessedDataConsumer.Data;
using KafkaExample.ProcessedDataConsumer.Repositories;
using NodaTime;

namespace KafkaExample.ProcessedDataConsumer.Services;

public sealed class ObjectStoreService : BackgroundService
{
    private static readonly Duration s_sleepTime = Duration.FromMinutes(60);
    private readonly string _bucket;
    private readonly IAmazonS3 _client;

    private readonly ILogger<ObjectStoreService> _logger;
    private readonly IParquetService _parquetService;
    private readonly IServiceScopeFactory _serviceScopeFactory;

    public ObjectStoreService(
        ILogger<ObjectStoreService> logger,
        IConfiguration configuration,
        IServiceScopeFactory serviceScopeFactory,
        IParquetService parquetService,
        IAmazonS3 client)
    {
        _logger = logger;
        _serviceScopeFactory = serviceScopeFactory;
        _parquetService = parquetService;
        _client = client;
        _bucket = configuration["BUCKET"]!;
        if (string.IsNullOrEmpty(_bucket))
        {
            throw new Exception("BUCKET is required");
        }
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                Instant start = SystemClock.Instance.GetCurrentInstant();

                {
                    DateTimeOffset now = start.ToDateTimeOffset();
                    string s3Prefix = $"{now.Year}/{now.Month}/{now.Day}";
                    string temperatureFile = $"aggregated_temperature_{now}.parquet";
                    string filteredDataFile = $"filtered_data_{now}.parquet";

                    await using AsyncServiceScope scope = _serviceScopeFactory.CreateAsyncScope();
                    IAggregatedTemperatureRepository temperatureRepository =
                        scope.ServiceProvider.GetRequiredService<IAggregatedTemperatureRepository>();
                    IFilteredDataRepository dataRepository =
                        scope.ServiceProvider.GetRequiredService<IFilteredDataRepository>();

                    IList<AggregatedTemperature> temperatures = await temperatureRepository.GetAll(stoppingToken);
                    int maxTemperatureRowId = temperatures.Max(d => d.Id);
                    _parquetService.WriteAggregatedTemperatureFile(temperatureFile, temperatures);

                    IList<FilteredData> dataList = await dataRepository.GetAll(stoppingToken);
                    int maxFilteredDataRowId = dataList.Max(d => d.Id);
                    _parquetService.WriteFilteredDataFile(filteredDataFile, dataList);

                    await Upload(temperatureFile, s3Prefix, stoppingToken);
                    File.Delete(temperatureFile);
                    await temperatureRepository.DeleteOldRows(maxTemperatureRowId, stoppingToken);

                    await Upload(filteredDataFile, s3Prefix, stoppingToken);
                    File.Delete(filteredDataFile);
                    await dataRepository.DeleteOldRows(maxFilteredDataRowId, stoppingToken);
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
                _logger.LogError(ex, "{Exception}", ex);
            }
        }
    }

    private async Task<bool> Upload(string filePath, string s3Prefix, CancellationToken stoppingToken)
    {
        await using FileStream file = File.OpenRead(filePath);
        PutObjectRequest request = new() {BucketName = _bucket, Key = $"{s3Prefix}/{filePath}", InputStream = file};
        request.Metadata.Add("Content-Type", "application/vnd.apache.parquet");

        PutObjectResponse? response = await _client.PutObjectAsync(request, stoppingToken);
        return response.HttpStatusCode == HttpStatusCode.OK;
    }
}
