data "aws_autoscaling_group" "autoscaling_groups_of_node_groups_with_asg_tag" {
  for_each = data.aws_eks_node_group.node_groups_with_asg_tag

  name = each.value["name"]
}


resource "aws_autoscaling_group_tag" "tag" {
  # TODO(wgj): Initial idea was to accept an arbitrary amount of asg tags, using a list of maps of
  # asg names, tag and value. This was a bit hard to read, and wasn't immediately clear how to best
  # add it to existing resources.
  # However, the underlying resource `aws_autoscaling_group_tag` doesn't accept a list of `tag`s,
  # and maintainability was a concern with this PR, I opted to only accept and create one tag,
  # better reflecting the provider's resource, and improving clarity.
  for_each = { for k, v in local.node_groups_expanded : k => v if v["autoscaling_group_tag"] }

  # TODO(wgj): Implies that `aws_eks_node_group`s have one and only one resource and asg, even
  # though they're lists. If this is incorrect (or likely to be) I think this gets harder to read
  # and write.
  autoscaling_group_name = aws_eks_node_group.workers[local.node_groups_names[each.key]].resources[0].autoscaling_groups[0].name

  tag {
    key                 = each.value["autoscaling_group_tag"]["key"]
    value               = each.value["autoscaling_group_tag"]["value"]
    propagate_at_launch = each.value["autoscaling_group_tag"]["propagate_at_launch"]
  }
}
