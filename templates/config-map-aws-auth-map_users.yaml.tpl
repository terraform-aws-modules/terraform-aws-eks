    %{ for map_user in map_users }
    - userarn: ${map_user.user_arn}
      username: ${map_user.username}
      groups:
      ${indent(8, yamlencode(map_user.groups))}
    %{ endfor }
