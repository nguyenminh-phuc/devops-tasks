using KafkaExample.Shared.Contracts;
using NodaTime;

namespace KafkaExample.RawDataConsumer.Data;

public sealed class ProcessedData
{
    public int Id { get; init; }

    public float AggregatedTemperature { get; set; }

    public List<RawMessage> FilteredData { get; init; } = [];

    public Instant Timestamp { get; init; }
}
