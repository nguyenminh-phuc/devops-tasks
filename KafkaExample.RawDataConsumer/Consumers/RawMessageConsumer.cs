using KafkaExample.RawDataConsumer.Repositories;
using KafkaExample.Shared.Contracts;
using MassTransit;

namespace KafkaExample.RawDataConsumer.Consumers;

public sealed class RawMessageConsumer(IRawDataRepository repository) : IConsumer<RawMessage>
{
    public async Task Consume(ConsumeContext<RawMessage> context) =>
        await repository.Add(context.Message, context.CancellationToken);
}
