using KafkaExample.ProcessedDataConsumer.Data;
using KafkaExample.Shared.Contracts;
using Microsoft.EntityFrameworkCore;

namespace KafkaExample.ProcessedDataConsumer.Repositories;

public interface IFilteredDataRepository
{
    Task<int> Add(ProcessedMessage message, CancellationToken cancellationToken);

    Task<IList<FilteredData>> GetAll(CancellationToken cancellationToken);

    Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken);
}

public sealed class FilteredDataRepository(ProcessedConsumerDbContext context) : IFilteredDataRepository
{
    public async Task<int> Add(ProcessedMessage message, CancellationToken cancellationToken)
    {
        FilteredData data = new() {List = message.FilteredDataList};
        context.FilteredData.Add(data);
        await context.SaveChangesAsync(cancellationToken);

        return data.Id;
    }

    public async Task<IList<FilteredData>> GetAll(CancellationToken cancellationToken) =>
        await context.FilteredData.ToListAsync(cancellationToken);

    public async Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken) =>
        await context.FilteredData
            .Where(data => data.Id <= maxRowId)
            .ExecuteDeleteAsync(cancellationToken);
}
