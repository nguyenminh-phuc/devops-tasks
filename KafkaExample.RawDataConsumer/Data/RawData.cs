using KafkaExample.Shared.Contracts;

namespace KafkaExample.RawDataConsumer.Data;

public sealed class RawData
{
    public int Id { get; init; }

    public RawMessage Message { get; init; } = null!;
}
