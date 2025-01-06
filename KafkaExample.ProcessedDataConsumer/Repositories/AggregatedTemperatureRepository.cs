using KafkaExample.ProcessedDataConsumer.Data;
using KafkaExample.Shared.Contracts;
using Microsoft.EntityFrameworkCore;

namespace KafkaExample.ProcessedDataConsumer.Repositories;

public interface IAggregatedTemperatureRepository
{
    Task<int> Add(ProcessedMessage message, CancellationToken cancellationToken);

    Task<IList<AggregatedTemperature>> GetAll(CancellationToken cancellationToken);

    Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken);
}

public sealed class AggregatedTemperatureRepository(ProcessedConsumerDbContext context)
    : IAggregatedTemperatureRepository
{
    public async Task<int> Add(ProcessedMessage message, CancellationToken cancellationToken)
    {
        AggregatedTemperature aggregatedTemperature = new() {Temperature = message.AggregatedTemperature};
        context.AggregatedTemperatures.Add(aggregatedTemperature);
        await context.SaveChangesAsync(cancellationToken);

        return aggregatedTemperature.Id;
    }

    public async Task<IList<AggregatedTemperature>> GetAll(CancellationToken cancellationToken) =>
        await context.AggregatedTemperatures.ToListAsync(cancellationToken);

    public async Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken) =>
        await context.AggregatedTemperatures
            .Where(data => data.Id <= maxRowId)
            .ExecuteDeleteAsync(cancellationToken);
}
