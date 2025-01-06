using NodaTime;

namespace KafkaExample.ProcessedDataConsumer.Data;

public sealed class AggregatedTemperature
{
    public int Id { get; init; }

    public float Temperature { get; init; }

    public Instant Timestamp { get; init; }
}
