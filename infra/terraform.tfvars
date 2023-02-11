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
aurora_min_capacity   = 0.5
aurora_max_capacity   = 8

# vpn
instance_type = "t4g.micro"
# TODO: use Terraform features to dynamically search for the instance_ami
# instead of hard-coding it
instance_ami  = "ami-01bba9fb00fc55866" # Amazon Linux 2 - kernel 5.10, SSD, aarch64
instance_user = "vpn"

# TODO: Note that this won't scale as the amount of users grows. Refactor it.
# The keys are added to the EC2 instance userdata script but userdata is limited in size
# and after we add a couple more users, we will reach that limit.
instance_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ1r2jsQC+ceTWVje02CZMZDduDqKafCLdlbJxVzJrd marko@skynet",
]

# app
app_name      = "test-app"
desired_count = "2"
cpu           = 256
memory        = 512
image         = "registry.hub.docker.com/kostic/test-app:1efd55a"
http_port     = 80
grpc_port     = 9000
