<powershell>
${pre_bootstrap_user_data ~}
[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
& $EKSBootstrapScriptFile -EKSClusterName ${cluster_name} -APIServerEndpoint ${cluster_endpoint} -Base64ClusterCA ${cluster_auth_base64} ${bootstrap_extra_args} 3>&1 4>&1 5>&1 6>&1
$LastError = if ($?) { 0 } else { $Error[0].Exception.HResult }
${post_bootstrap_user_data ~}
</powershell>
