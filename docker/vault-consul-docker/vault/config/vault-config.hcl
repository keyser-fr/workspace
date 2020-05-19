ui = true

listener "tcp" {
  address     = "vault:8200"
  tls_disable = true
}

storage "consul" {
  address = "consul-server-bootstrap:8500"
  path    = "vault"
}

service_registration "consul" {
  address = "consul-server-bootstrap:8500"
}
