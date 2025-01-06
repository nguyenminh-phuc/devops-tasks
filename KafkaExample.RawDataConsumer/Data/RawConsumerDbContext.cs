using Microsoft.EntityFrameworkCore;

namespace KafkaExample.RawDataConsumer.Data;

public sealed class RawConsumerDbContext(DbContextOptions<RawConsumerDbContext> options) : DbContext(options)
{
    public DbSet<RawData> RawData { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<RawData>().ToTable("RawData");
        modelBuilder.Entity<RawData>().HasKey(x => x.Id);
        modelBuilder.Entity<RawData>().Property(x => x.Id).ValueGeneratedOnAdd();
        modelBuilder.Entity<RawData>().OwnsOne(x => x.Message, builder => { builder.ToJson(); });
    }
}
