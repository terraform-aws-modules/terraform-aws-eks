# Custom user data template provided for rendering
[settings.kubernetes]
"cluster-name" = "${cluster_name}"
"api-server" = "${cluster_endpoint}"
"cluster-certificate" = "${cluster_auth_base64}"

${bootstrap_extra_args~}
