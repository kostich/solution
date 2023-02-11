region      = "eu-central-1"
environment = "dev"

# networking
vpc_cidr = "10.0.0.0/16"

# subnets
data_primary_cidr   = "10.0.0.0/20"
data_secondary_cidr = "10.0.16.0/20"
data_tertiary_cidr  = "10.0.32.0/20"

app_primary_cidr   = "10.0.96.0/20"
app_secondary_cidr = "10.0.112.0/20"

public_primary_cidr   = "10.0.250.0/24"
public_secondary_cidr = "10.0.251.0/24"

# database
aurora_instances      = 3
aurora_engine_version = "13.8"
aurora_min_capacity = 0.5
aurora_max_capacity = 8

# app
app_name      = "test-app"
desired_count = "2"
cpu           = 256
memory        = 512
image         = "registry.hub.docker.com/kostic/test-app:1efd55a"
http_port     = 80
grpc_port     = 9000
