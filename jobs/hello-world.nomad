job "hello-world" {
  datacenters = ["dc1"]
  type = "service"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "hello-world" {
  count=3
    task "hello-world" {

      service {
        name = "hello-world"
        port="http"
        tags = ["urlprefix-hello-world.service/"]
        check {
          type     = "http"
          port     = "8080"
          interval = "15s"
          timeout  = "5s"
          path="http://127.0.0.1:8080"
        }
      }
        driver = "docker"
        config {
            image = "hashicorp/http-echo"
            network_mode = "host"
            args = [
              "-listen", ":8080",
              "-text","Hello World !"
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
