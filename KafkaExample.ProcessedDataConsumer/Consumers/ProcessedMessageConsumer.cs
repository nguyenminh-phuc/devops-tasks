using KafkaExample.ProcessedDataConsumer.Repositories;
using KafkaExample.Shared.Contracts;
using MassTransit;

namespace KafkaExample.ProcessedDataConsumer.Consumers;

public sealed class ProcessedMessageConsumer(
    IAggregatedTemperatureRepository temperatureRepository,
    IFilteredDataRepository dataRepository) : IConsumer<ProcessedMessage>
{
    public async Task Consume(ConsumeContext<ProcessedMessage> context)
    {
        await temperatureRepository.Add(context.Message, context.CancellationToken);
        await dataRepository.Add(context.Message, context.CancellationToken);
    }
}
