using KafkaExample.ProcessedDataConsumer.Data;
using ParquetSharp;

namespace KafkaExample.ProcessedDataConsumer.Services;

public interface IParquetService
{
    void WriteAggregatedTemperatureFile(string filePath, IList<AggregatedTemperature> temperatureList);

    void WriteFilteredDataFile(string filePath, IList<FilteredData> dataList);
}

public sealed class ParquetService : IParquetService
{
    public void WriteAggregatedTemperatureFile(string filePath, IList<AggregatedTemperature> temperatureList)
    {
        Column[] columns =
        [
            new Column<DateTime>("Timestamp"),
            new Column<float>("Temperature")
        ];

        using ParquetFileWriter file = new(filePath, columns);
        using RowGroupWriter rowGroup = file.AppendRowGroup();

        using (LogicalColumnWriter<DateTime> writer = rowGroup.NextColumn().LogicalWriter<DateTime>())
        {
            DateTime[] timestamps = temperatureList.Select(t => t.Timestamp.ToDateTimeUtc()).ToArray();
            writer.WriteBatch(timestamps);
        }

        using (LogicalColumnWriter<float> writer = rowGroup.NextColumn().LogicalWriter<float>())
        {
            float[] temperatures = temperatureList.Select(t => t.Temperature).ToArray();
            writer.WriteBatch(temperatures);
        }

        file.Close();
    }

    public void WriteFilteredDataFile(string filePath, IList<FilteredData> dataList)
    {
        Column[] columns =
        [
            new Column<string>("DeviceId"),
            new Column<DateTime>("Timestamp"),
            new Column<float>("Temperature"),
            new Column<float>("Humidity"),
            new Column<string>("Status")
        ];

        using ParquetFileWriter file = new(filePath, columns);
        using RowGroupWriter rowGroup = file.AppendRowGroup();

        using (LogicalColumnWriter<string> writer = rowGroup.NextColumn().LogicalWriter<string>())
        {
            List<string> deviceIds = [];
            foreach (FilteredData data in dataList)
            {
                deviceIds.AddRange(data.List.Select(d => d.DeviceId));
            }

            writer.WriteBatch(deviceIds.ToArray());
        }

        using (LogicalColumnWriter<DateTime> writer = rowGroup.NextColumn().LogicalWriter<DateTime>())
        {
            List<DateTime> timestamps = [];
            foreach (FilteredData data in dataList)
            {
                timestamps.AddRange(data.List.Select(d => d.Timestamp.DateTime));
            }

            writer.WriteBatch(timestamps.ToArray());
        }

        using (LogicalColumnWriter<float> writer = rowGroup.NextColumn().LogicalWriter<float>())
        {
            List<float> temperatures = [];
            foreach (FilteredData data in dataList)
            {
                temperatures.AddRange(data.List.Select(d => d.Temperature));
            }

            writer.WriteBatch(temperatures.ToArray());
        }

        using (LogicalColumnWriter<float> writer = rowGroup.NextColumn().LogicalWriter<float>())
        {
            List<float> humidityList = [];
            foreach (FilteredData data in dataList)
            {
                humidityList.AddRange(data.List.Select(d => d.Humidity));
            }

            writer.WriteBatch(humidityList.ToArray());
        }

        using (LogicalColumnWriter<string> writer = rowGroup.NextColumn().LogicalWriter<string>())
        {
            List<string> statuses = [];
            foreach (FilteredData data in dataList)
            {
                statuses.AddRange(data.List.Select(d => d.Status));
            }

            writer.WriteBatch(statuses.ToArray());
        }

        file.Close();
    }
}
