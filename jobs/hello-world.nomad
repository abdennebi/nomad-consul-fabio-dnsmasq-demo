job "helloworld" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "helloworld" {
    task "helloworld" {
        driver = "docker"
        config {
            image = "hashicorp/http-echo"
            args = [
              "listen", ":8080",
              "text","Hello World !"
            ]
        }
        
      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 8080
          }
        }
      }
    }
  }
}
