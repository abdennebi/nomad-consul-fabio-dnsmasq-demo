job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
        driver = "docker"
        config {
            image = "magiconair/fabio:1.5.0-go1.8.3"
            network_mode = "host"
            command = "/fabio"
            args = ["-proxy.addr",":80"]
        }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 80
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
