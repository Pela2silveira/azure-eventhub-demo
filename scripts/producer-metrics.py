import asyncio
import os
import psutil
import json
import time

from azure.eventhub import EventData
from azure.eventhub.aio import EventHubProducerClient

async def get_system_metrics():
    # Get CPU usage
    cpu_usage_percent = psutil.cpu_percent(interval=1, percpu=True)

    # Get memory usage
    memory_info = psutil.virtual_memory()

    # Get disk usage
    disk_info = psutil.disk_usage('/')

    # Get network usage
    network_info = psutil.net_io_counters()

    # Create a dictionary with the collected metrics
    metrics = {
        'cpu_usage_percent': cpu_usage_percent,
        'memory_percent': memory_info.percent,
        'disk_percent': disk_info.percent,
        'network_info': {
            'bytes_sent': network_info.bytes_sent,
            'bytes_received': network_info.bytes_recv
        }
    }

    return metrics

async def send_metrics_to_eventhub(metrics):
    EVENT_HUB_CONNECTION_STR = os.environ.get("producer_endpoint").strip('"')
    EVENT_HUB_NAME = "applogs"

    # Create a producer client to send messages to the event hub.
    producer = EventHubProducerClient.from_connection_string(
        conn_str=EVENT_HUB_CONNECTION_STR, eventhub_name=EVENT_HUB_NAME
    )
    async with producer:
        # Create a batch.
        event_data_batch = await producer.create_batch()

        # Add events to the batch.
        event_data_batch.add(EventData(json.dumps(metrics)))

        # Send the batch of events to the event hub.
        await producer.send_batch(event_data_batch)

async def run():
    # Get system metrics
    metrics_data = await get_system_metrics()

    # Send metrics data to Azure Event Hub
    await send_metrics_to_eventhub(metrics_data)

if __name__ == "__main__":
    while (True):
        asyncio.run(run())
        time.sleep(1)
        print("msg sent")
