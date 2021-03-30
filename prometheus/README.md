# Prometheus Data Retention

| Environment | Scrape Interval | Retention period | Estimated storage requirements |
| - | - | - | - | 
| Prod | 10s | 180 days | 150 GB |
| Tool | 10s | 20 days | 30 GB |
| Stage | 10s | 20 days | 30 GB |

# Node Exported TCP port

Port is changed from tcp/9100 to tcp/19100 due to the another instance of Prometheus (managed by T-Mobile)