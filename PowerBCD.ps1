$REG_BASE_PATH = "HKLM:\BCD00000000\Objects"
$GUID_BOOT_MANAGER = "{9dea862c-5cdd-4e70-acc1-f32b344d4795}"
$GUID_BOOT_LOADER_PATH = "$REG_BASE_PATH\$GUID_BOOT_MANAGER\Elements\23000003"
$ELEMENT_RECOVERYENABLED = "16000009"
$ELEMENTVALUE_RECOVERYENABLED_NO = [byte]0
$ELEMENTVALUE_RECOVERYENABLED_YES = [byte]1
$ELEMENT_BOOTSTATUSPOLICY = "250000e0"
$ELEMENTVALUE_BOOTSTATUSPOLICY_DISPLAYALLFAILURES = [long]0
$ELEMENTVALUE_BOOTSTATUSPOLICY_IGNOREALLFAILURES = [long]1
$ELEMENT_SAFEBOOT = "25000080"
$ELEMENTVALUE_SAFEBOOT_MINIMAL = [long]0
$ELEMENTVALUE_SAFEBOOT_NETWORK = [long]1
$ELEMENT_TESTSIGNING = "16000049"
$ELEMENTVALUE_TESTSIGNING_OFF = [byte]0
$ELEMENTVALUE_TESTSIGNING_ON = [byte]1

function Set-BCD {
    param (
        [ValidateSet("On", "Off")][string]$TestSigning,
        [ValidateSet("Yes", "No")][string]$RecoveryEnabled,
        [ValidateSet("DisplayAllFailures", "IgnoreAllFailures")][string]$BootStatusPolicy,
        [ValidateSet("Minimal", "Network", "Off")][string]$SafeBoot
    )

    try {
        $ActiveLoaderGuid =  Get-ItemProperty -Path $GUID_BOOT_LOADER_PATH -Name Element | Select-Object -ExpandProperty Element
        if ($PSBoundParameters.ContainsKey('TestSigning')) {
            $elementKeyPath = "$REG_BASE_PATH\$ActiveLoaderGuid\Elements\$ELEMENT_TESTSIGNING"
            $data = if ($TestSigning -eq "On") { $ELEMENTVALUE_TESTSIGNING_ON } else { $ELEMENTVALUE_TESTSIGNING_OFF }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        elseif ($PSBoundParameters.ContainsKey('RecoveryEnabled')) {
            $elementKeyPath = "$REG_BASE_PATH\$ActiveLoaderGuid\Elements\$ELEMENT_RECOVERYENABLED"
            $data = if ($RecoveryEnabled -eq "Yes") { $ELEMENTVALUE_RECOVERYENABLED_YES } else { $ELEMENTVALUE_RECOVERYENABLED_NO }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        elseif ($PSBoundParameters.ContainsKey('BootStatusPolicy')) {
            $elementKeyPath = "$REG_BASE_PATH\$ActiveLoaderGuid\Elements\$ELEMENT_BOOTSTATUSPOLICY"
            $data = if ($BootStatusPolicy -eq "DisplayAllFailures") { $ELEMENTVALUE_BOOTSTATUSPOLICY_DISPLAYALLFAILURES } else { $ELEMENTVALUE_BOOTSTATUSPOLICY_IGNOREALLFAILURES }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        elseif ($PSBoundParameters.ContainsKey('SafeBoot')) {
            $elementKeyPath = "$REG_BASE_PATH\$ActiveLoaderGuid\Elements\$ELEMENT_SAFEBOOT"
            $data = if ($SafeBoot -eq "Minimal") { $ELEMENTVALUE_SAFEBOOT_MINIMAL } 
                elseif ($SafeBoot -eq "Network") { $ELEMENTVALUE_SAFEBOOT_NETWORK }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
            if ($SafeBoot -eq "Off")
            {
                Remove-ItemProperty -Path $elementKeyPath -Name Element -Force
                Remove-Item -Path $elementKeyPath -Force
            }
        }

    } catch {
        Write-Error "An error occurred: $_"
    }
}