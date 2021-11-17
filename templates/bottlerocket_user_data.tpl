%{ if length(ami_id) > 0 ~}
# https://github.com/bottlerocket-os/bottlerocket/blob/develop/README.md#description-of-settings
[settings.kubernetes]
"cluster-name" = "${cluster_name}"
"api-server" = "${cluster_endpoint}"
"cluster-certificate" = "${cluster_auth_base64}"
%{ endif ~}
%{ if length(cluster_dns_ip) > 0 && length(ami_id) > 0 ~}
"cluster-dns-ip" = "${cluster_dns_ip}"
%{ endif ~}

${bootstrap_extra_args}
