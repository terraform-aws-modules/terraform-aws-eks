%{ if length(ami_id) > 0 ~}
[settings.kubernetes]
"cluster-name" = "${cluster_name}"
"api-server" = "${cluster_endpoint}"
"cluster-certificate" = "${cluster_auth_base64}"
%{ endif ~}

${bootstrap_extra_args}
