using KafkaExample.Shared.Contracts;
using NodaTime;

namespace KafkaExample.ProcessedDataConsumer.Data;

public sealed class FilteredData
{
    public int Id { get; init; }

    public List<RawMessage> List { get; set; } = [];

    public Instant Timestamp { get; init; }
}
