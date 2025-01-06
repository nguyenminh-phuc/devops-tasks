namespace KafkaExample.Shared.Contracts;

public sealed class RawMessage
{
    public const string OkStatus = "OK";
    public const string ErrorStatus = "ERROR";

    public string DeviceId { get; set; } = null!;

    public DateTimeOffset Timestamp { get; set; }

    public float Temperature { get; set; }

    public float Humidity { get; set; }

    public string Status { get; set; } = null!;
}
