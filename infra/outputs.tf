output "ssh_port_forward_command" {
  description = "Use this command to activate a SSH tunnel via which you can reach PostgreSQL."
  value = format(
    "ssh -N -L 5432:%s:5432 %s@%s",
    aws_rds_cluster.aurora.endpoint,
    var.instance_user,
    aws_eip.vpn_instance_eip.public_ip,
  )
}
