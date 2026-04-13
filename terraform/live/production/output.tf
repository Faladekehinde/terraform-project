output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
output "db_endpoint" {
  value = module.webserver_cluster.db_endpoint
}
