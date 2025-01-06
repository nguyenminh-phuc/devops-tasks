namespace KafkaExample.Shared.Contracts;

public sealed class ProcessedMessage
{
    public DateTimeOffset Timestamp { get; set; }

    public float AggregatedTemperature { get; set; }

    public List<RawMessage> FilteredDataList { get; set; } = [];
}
