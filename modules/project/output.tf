# output "project_services" {
#   value = local.project_services
# }

# output "project_objects" {
#  value = local.project_objects
# }

output "created_project_list" {
  value = [for k, v in google_project.self: {
    project_id = split("/",v.id)[1] 
    project_number = v.number
  }]
}