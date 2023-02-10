region      = "eu-central-1"
environment = "dev"

# networking
vpc_cidr    = "10.0.0.0/16"
data_cidr   = "10.0.0.0/20"
app_cidr    = "10.0.16.0/20"
public_cidr = "10.0.253.0/24"
mgmt_cidr   = "10.0.254.0/24"

# app
app_name      = "test-app"
desired_count = "2"
cpu           = 256
memory        = 512
image         = "registry.hub.docker.com/kostic/test-app:8dac3f1"
http_port     = 80
grpc_port     = 9000