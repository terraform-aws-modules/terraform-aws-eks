    %{ for map_role in map_roles }
    - rolearn: ${map_role.role_arn}
      username: ${map_role.username}
      groups:
        ${indent(8, yamlencode(map_role.groups))}
    %{ endfor }
