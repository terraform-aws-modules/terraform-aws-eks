<powershell>
${pre_userdata}

[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
[string]$cfn_signal = "$env:ProgramFiles\Amazon\cfn-bootstrap\cfn-signal.exe"
& $EKSBootstrapScriptFile -EKSClusterName ${cluster_name} -KubeletExtraArgs '${kubelet_extra_args}' 3>&1 4>&1 5>&1 6>&1
$LastError = if ($?) { 0 } else { $Error[0].Exception.HResult }

${additional_userdata}
</powershell>
