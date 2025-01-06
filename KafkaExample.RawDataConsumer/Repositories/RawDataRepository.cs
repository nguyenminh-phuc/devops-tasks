using KafkaExample.RawDataConsumer.Data;
using KafkaExample.Shared.Contracts;
using Microsoft.EntityFrameworkCore;

namespace KafkaExample.RawDataConsumer.Repositories;

public interface IRawDataRepository
{
    Task<int> Add(RawMessage message, CancellationToken cancellationToken);

    Task<IList<RawData>> GetAll(CancellationToken cancellationToken);

    Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken);
}

public sealed class RawDataRepository(RawConsumerDbContext context) : IRawDataRepository
{
    public async Task<int> Add(RawMessage message, CancellationToken cancellationToken)
    {
        RawData data = new() {Message = message};
        context.RawData.Add(data);
        await context.SaveChangesAsync(cancellationToken);

        return data.Id;
    }

    public async Task<IList<RawData>> GetAll(CancellationToken cancellationToken) =>
        await context.RawData.ToListAsync(cancellationToken);

    public async Task<int> DeleteOldRows(int maxRowId, CancellationToken cancellationToken) =>
        await context.RawData
            .Where(data => data.Id <= maxRowId)
            .ExecuteDeleteAsync(cancellationToken);
}
