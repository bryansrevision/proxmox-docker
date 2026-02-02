# 🌐 MCP Connection Methods & Best Practices

**Complete Guide for GitHub Copilot Server Connections**

Proven and tested connection patterns for reliable API communication during
deployment.



## Connection Methods Overview

### 1. GitHub Connections (.github/connections)

**Best For:** Configuration-as-code, version control friendly

```yaml
# .github/connections/server.yaml
name: server-connection
type: rest
endpoint: https://api.example.com/v1
auth:
  type: bearer
  token_env: API_TOKEN
health_check:
  path: /health
  interval: 30s
timeout: 30s
retries: 3
```

**Advantages:**
- ✅ Version controlled
- ✅ Auditable
- ✅ Easy to review
- ✅ Portable across environments

**Disadvantages:**
- ❌ No dynamic configuration
- ❌ Requires repository access



### 2. MCP Hub Server (Recommended for Production)

**Best For:** Centralized connection management with service discovery

```bash
# Deploy MCP Hub
docker run -d \
  --name mcp-hub \
  -e MCP_SERVICE_DISCOVERY=consul \
  -e MCP_CONFIG_SYNC=true \
  -e MCP_ENABLE_METRICS=true \
  -p 50051:50051 \
  ghcr.io/microsoft/mcp-hub:latest

# Register service
curl -X POST http://mcp-hub:50051/api/services/register \
  -d '{"name":"api","endpoint":"https://api.example.com","auth":"bearer"}'

# Connect via client
from mcp_sdk import Client
client = MCP.Client("mcp-hub:50051", "api")
response = client.call("GET", "/api/v1/data")
```

**Advantages:**
- ✅ Centralized management
- ✅ Service discovery
- ✅ Automatic failover
- ✅ Load balancing
- ✅ Health monitoring
- ✅ Metrics/tracing

**Disadvantages:**
- ❌ Requires running hub service
- ❌ Additional complexity



### 3. WebSocket Real-Time Connection

**Best For:** Live events, streaming, real-time updates

```python
import websockets
import json

async def connect_realtime(uri, token):
    async with websockets.connect(uri) as ws:
        # Authenticate
        await ws.send(json.dumps({
            "type": "auth",
            "token": token
        }))
        
        # Listen for events
        async for message in ws:
            event = json.loads(message)
            print(f"Event: {event['type']}")
```

**Advantages:**
- ✅ Real-time push events
- ✅ Bidirectional communication
- ✅ Low latency
- ✅ Efficient for high-frequency updates

**Disadvantages:**
- ❌ Connection state management
- ❌ Reconnection handling needed
- ❌ Not suitable for request-response



### 4. gRPC Streaming (High Performance)

**Best For:** High-throughput, low-latency operations

```proto
syntax = "proto3";

service API {
  rpc GetData(Request) returns (stream Response);
  rpc StreamEvents(Empty) returns (stream Event);
  rpc Execute(Command) returns (Result);
}
```

```python
import grpc
from concurrent import futures

# Create channel
channel = grpc.secure_channel(
    'api.example.com:50051',
    grpc.ssl_channel_credentials()
)

# Make streaming call
stub = API.APIStub(channel)
responses = stub.StreamEvents(pb2.Empty())

for event in responses:
    print(f"Event: {event}")
```

**Advantages:**
- ✅ Binary protocol (compact)
- ✅ Streaming support
- ✅ Multiplexing
- ✅ Very fast
- ✅ Language agnostic

**Disadvantages:**
- ❌ Code generation required
- ❌ Protocol buffer learning curve
- ❌ Not as readable



### 5. SSH Tunnels (Secure Access)

**Best For:** Secure port forwarding to internal services

```bash
# Create SSH tunnel
ssh -i ~/.ssh/key.pem \
    -fN -L 8006:localhost:8006 \
    root@api.example.com

# Use tunnel
curl https://localhost:8006/api/v1/data

# Keep tunnel alive
ssh -i ~/.ssh/key.pem \
    -fN -L 8006:localhost:8006 \
    -o ServerAliveInterval=60 \
    root@api.example.com
```

**Advantages:**
- ✅ Very secure
- ✅ Key-based auth
- ✅ Port forwarding
- ✅ No firewall exposure

**Disadvantages:**
- ❌ SSH overhead
- ❌ Connection management
- ❌ Not easy to scale



### 6. Message Queue Connection (Async Operations)

**Best For:** Decoupled, asynchronous operations

```bash
# RabbitMQ
docker run -d \
  --name rabbitmq \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=password \
  -p 5672:5672 \
  rabbitmq:3-management
```

```python
import pika
import json

connection = pika.BlockingConnection(
    pika.ConnectionParameters('localhost')
)
channel = connection.channel()

# Declare queue
channel.queue_declare(queue='tasks', durable=True)

# Publish task
channel.basic_publish(
    exchange='',
    routing_key='tasks',
    body=json.dumps({'action': 'deploy', 'repo': 'proxmox'}),
    properties=pika.BasicProperties(delivery_mode=2)
)
```

**Advantages:**
- ✅ Decoupled services
- ✅ Reliable delivery
- ✅ Horizontal scaling
- ✅ Retry support

**Disadvantages:**
- ❌ Additional infrastructure
- ❌ Eventually consistent
- ❌ Complexity



### 7. API Gateway with Load Balancing

**Best For:** Multiple backend services, load distribution

```nginx
upstream backend {
    server api1.example.com:8006 weight=1;
    server api2.example.com:8006 weight=1;
    keepalive 32;
}

server {
    listen 8080 ssl;
    
    location /api/ {
        proxy_pass https://backend;
        proxy_set_header Authorization $http_authorization;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

**Advantages:**
- ✅ Load balancing
- ✅ Health checks
- ✅ SSL termination
- ✅ Single endpoint

**Disadvantages:**
- ❌ Gateway becomes SPOF
- ❌ Configuration complexity
- ❌ Potential latency



## 🎯 Decision Matrix

Choose your connection method based on requirements:

| Requirement | Method | Reason |
| --- | --- | --- |
| Version control | GitHub Connections | Auditable, reviewable |
| Production | MCP Hub | Managed, scalable |
| Real-time | WebSocket | Low latency, push events |
| High throughput | gRPC | Binary, streaming |
| Internal only | SSH Tunnel | Secure, key-based |
| Task queue | Message Queue | Async, reliable |
| Multi-backend | API Gateway | Load balancing |



## 🚀 Implementation Patterns

### Pattern 1: GitHub Connections Only

```
User Request
    ↓
Load .github/connections/config.yaml
    ↓
Parse endpoints
    ↓
Direct REST calls
    ↓
Complete
```

**Use when:** Simple deployments, single service



### Pattern 2: MCP Hub + WebSocket

```
User Request
    ↓
Start MCP Hub
    ↓
Register services
    ↓
Connect via gRPC
    ↓
Subscribe to WebSocket events
    ↓
Complete
```

**Use when:** Multi-service, real-time monitoring



### Pattern 3: SSH Tunnel + Gateway

```
User Request
    ↓
Establish SSH tunnel
    ↓
Start NGINX gateway
    ↓
Route through gateway
    ↓
Load balance to endpoints
    ↓
Complete
```

**Use when:** Internal networks, security-critical



### Pattern 4: Event-Driven (Kafka + gRPC)

```
User Request
    ↓
Publish task to Kafka
    ↓
Worker picks up task
    ↓
Execute via gRPC
    ↓
Stream results back
    ↓
Update UI via WebSocket
    ↓
Complete
```

**Use when:** High volume, distributed operations



## ✅ Connection Validation

**Always verify connection before deployment:**

```bash
# GitHub Connections
cat .github/connections/*.yaml | jsonschema validate

# MCP Hub
curl http://mcp-hub:50051/api/health

# WebSocket
wscat -c wss://api.example.com/ws --auth token

# gRPC
grpcurl -plaintext api.example.com:50051 list

# SSH Tunnel
ssh -T root@api.example.com "echo OK"

# Message Queue
curl http://rabbitmq:15672/api/overview -u admin:password

# API Gateway
curl -v https://gateway:8080/api/health
```



## 🔐 Security Best Practices

### For All Methods:
- ✅ Use HTTPS/TLS
- ✅ Validate certificates
- ✅ Encrypt in transit
- ✅ Use short-lived tokens
- ✅ Rotate credentials regularly
- ✅ Log access (without secrets)
- ✅ Monitor for anomalies

### GitHub Connections:
- ✅ Store endpoints not secrets
- ✅ Version control config
- ✅ Review changes

### MCP Hub:
- ✅ Secure hub entr point
- ✅ Enable authentication
- ✅ Use service mesh
- ✅ Enable audit logging

### WebSocket:
- ✅ Use WSS (TLS)
- ✅ Validate server cert
- ✅ Reauth on reconnect
- ✅ Rate limit connections

### gRPC:
- ✅ Use mTLS
- ✅ Client certificates
- ✅ Service mesh (Istio)
- ✅ Network policies

### SSH:
- ✅ SSH key-based
- ✅ Disable password auth
- ✅ Use key agent
- ✅ Audit connections



## 📊 Performance Comparison

| Method | Throughput | Latency | Scalability | Stability |
| --- | --- | --- | --- | --- |
| REST | Medium | Normal | Good | Good |
| gRPC | Very High | Very Low | Excellent | Excellent |
| WebSocket | Medium | Real-time | Good | Good |
| SSH | Low | Normal | OK | OK |
| Queue | Very High | Async | Excellent | Excellent |
| Gateway | High | Normal | Good | Good |



## 🔧 Recommended Configuration by Deployment Type

### Development:
```yaml
connections:
  type: rest
  endpoint: localhost:8080
  auth: none
  verify_ssl: false
```

### Staging:
```yaml
connections:
  type: github
  path: .github/connections/staging.yaml
  auth: bearer
  verify_ssl: true
  timeout: 30s
```

### Production:
```yaml
connections:
  type: mcp-hub
  endpoint: mcp-hub:50051
  auth: mcp-token
  verify_ssl: true
  timeout: 10s
  retries: 3
  circuit_breaker: true
```



## 📚 Integration with Copilot Deployment

When Copilot deploys:

1. **Read connection config** from `.github/connections/`
2. **Validate endpoints** are reachable
3. **Choose method** based on config type
4. **Establish connection** (REST, gRPC, WS, etc.)
5. **Verify health** before deployment
6. **Stream deployment** updates
7. **Monitor events** in real-time
8. **Complete gracefully** with status



## 🆘 Troubleshooting Connections

| Error | Cause | Fix |
| --- | --- | --- |
| Connection refused | Service not running | Start service, check port |
| SSL certificate error | Untrusted cert | Update CA bundle or disable verify |
| Timeout | Network issue | Increase timeout, check network |
| Authentication failed | Wrong credentials | Verify token/key, regenerate |
| Too many requests | Rate limiting | Use queues, add circuit breaker |
| Service unavailable | Overloaded | Load balance, scale horizontally |



**Last Updated:** February 2, 2026  
**Status:** ✅ Complete - All connection methods documented  
**Recommended:** MCP Hub for production deployments
