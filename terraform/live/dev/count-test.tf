#resource "null_resource" "servers" {
 # for_each = var.servers

  #triggers                  = {
    #name           = each.key
   # instance_type = each.value
  #}
#}