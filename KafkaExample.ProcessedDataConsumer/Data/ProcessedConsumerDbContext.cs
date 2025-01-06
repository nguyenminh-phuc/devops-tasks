using Microsoft.EntityFrameworkCore;

namespace KafkaExample.ProcessedDataConsumer.Data;

public sealed class ProcessedConsumerDbContext(DbContextOptions<ProcessedConsumerDbContext> options)
    : DbContext(options)
{
    public DbSet<AggregatedTemperature> AggregatedTemperatures { get; set; }

    public DbSet<FilteredData> FilteredData { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AggregatedTemperature>().ToTable("AggregatedTemperature");
        modelBuilder.Entity<AggregatedTemperature>().HasKey(x => x.Id);
        modelBuilder.Entity<AggregatedTemperature>().Property(x => x.Id).ValueGeneratedOnAdd();
        modelBuilder.Entity<AggregatedTemperature>().Property(x => x.Timestamp).HasDefaultValueSql("NOW()");

        modelBuilder.Entity<FilteredData>().ToTable("FilteredData");
        modelBuilder.Entity<FilteredData>().HasKey(x => x.Id);
        modelBuilder.Entity<FilteredData>().Property(x => x.Id).ValueGeneratedOnAdd();
        modelBuilder.Entity<FilteredData>().OwnsMany(x => x.List, builder => { builder.ToJson(); });
        modelBuilder.Entity<FilteredData>().Property(x => x.Timestamp).HasDefaultValueSql("NOW()");
    }
}
