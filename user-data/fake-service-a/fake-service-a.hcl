service = {
  Name = "fake-service-a"
  Port = 9091
  check = {
    http = "http://localhost:9091/health"
    interval = "5s"
  }
  
  connect = { sidecar_service ={} }
}