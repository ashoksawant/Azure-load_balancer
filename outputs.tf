output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.pub1.ip_address
}

output "load_balancer_name" {
  description = "The name of the load balancer"
  value       = azurerm_lb.lb1.name
}

output "vmss_name" {
  description = "The name of the virtual machine scale set"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.name
}

output "vmss_instance_ids" {
  description = "The IDs of the virtual machine scale set instances"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.instances
}

