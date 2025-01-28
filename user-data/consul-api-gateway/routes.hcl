Kind = "http-route"
Name = "fake-service-http-routes"

Parents = [
  {
    Kind = "api-gateway"
    Name = "consul-api-gateway"
    SectionName = "api-gw-listener"
  }
]

Rules = [
  {
    Matches = [
      {
        Path = {
          Match = "prefix"
          Value = "/service-a"
        } 
      }
    ]
    Services = [
      {
        Name = "fake-service-a"
      }
    ]
  },
  {
    Matches = [
      {
        Path = {
          Match = "prefix"
          Value = "/service-b"
        } 
      }
    ]
    Services = [
      {
        Name = "fake-service-b"
      }
    ]
  }
]
#Hostnames = ["*"]
