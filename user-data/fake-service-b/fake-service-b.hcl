service = {
  Name = "fake-service-b"
  Port = 9092
  check = {
    http = "http://localhost:9092/health"
    interval = "5s"
  }
  
  connect = { sidecar_service ={} }
}