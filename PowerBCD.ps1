#Requires -RunAsAdministrator

# Constants
$REG_BASE_PATH = "HKLM:\BCD00000000"
$GUID_BOOT_MANAGER = "{9dea862c-5cdd-4e70-acc1-f32b344d4795}"
$GUID_BOOT_LOADER_PATH = "$REG_BASE_PATH\Objects\$GUID_BOOT_MANAGER\Elements\23000003"
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


function PowerBCD {
    param (
        [ValidateSet("On", "Off")][string]$TestSigning,
        [ValidateSet("Yes", "No")][string]$RecoveryEnabled,
        [ValidateSet("DisplayAllFailures", "IgnoreAllFailures")][string]$BootStatusPolicy,
        [ValidateSet("Minimal", "Network", "Off")][string]$SafeBoot
    )

    try {
       
        # Permit ACL
        $RegKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            $REG_BASE_PATH.Replace("HKLM:\", ""),
            [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
            [System.Security.AccessControl.RegistryRights]::ChangePermissions
        )
        $OriginalAcl = $RegKey.GetAccessControl()
        $Acl = $OriginalAcl
        $AdminRule = New-Object System.Security.AccessControl.RegistryAccessRule(
            "Administrators",                     # User or Group
            "FullControl",                        # Permissions
            "ContainerInherit,ObjectInherit",     # Inheritance settings
            "None",                               # Propagation settings
            "Allow"                               # Access type
        )
        $Acl.SetAccessRule($AdminRule)
        $RegKey.SetAccessControl($Acl)
       
        # Get active Boot Loader GID
        $ActiveLoaderGuid =  Get-ItemProperty -Path $GUID_BOOT_LOADER_PATH -Name Element | Select-Object -ExpandProperty Element
       
        # Change
        if ($PSBoundParameters.ContainsKey('TestSigning')) {
            $elementKeyPath = "$REG_BASE_PATH\Objects\$ActiveLoaderGuid\Elements\$ELEMENT_TESTSIGNING"
            $data = if ($TestSigning -eq "On") { $ELEMENTVALUE_TESTSIGNING_ON } else { $ELEMENTVALUE_TESTSIGNING_OFF }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('RecoveryEnabled')) {
            $elementKeyPath = "$REG_BASE_PATH\Objects\$ActiveLoaderGuid\Elements\$ELEMENT_RECOVERYENABLED"
            $data = if ($RecoveryEnabled -eq "Yes") { $ELEMENTVALUE_RECOVERYENABLED_YES } else { $ELEMENTVALUE_RECOVERYENABLED_NO }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('BootStatusPolicy')) {
            $elementKeyPath = "$REG_BASE_PATH\Objects\$ActiveLoaderGuid\Elements\$ELEMENT_BOOTSTATUSPOLICY"
            $data = if ($BootStatusPolicy -eq "DisplayAllFailures") { $ELEMENTVALUE_BOOTSTATUSPOLICY_DISPLAYALLFAILURES } else { $ELEMENTVALUE_BOOTSTATUSPOLICY_IGNOREALLFAILURES }
            New-Item -Path $elementKeyPath -Force | Out-Null
            New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('SafeBoot')) {
            $elementKeyPath = "$REG_BASE_PATH\Objects\$ActiveLoaderGuid\Elements\$ELEMENT_SAFEBOOT"
            if ($SafeBoot -eq "Off") {
                Remove-ItemProperty -Path $elementKeyPath -Name Element -Force
                Remove-Item -Path $elementKeyPath -Force
            } 
            else {
                $data = if ($SafeBoot -eq "Minimal") { $ELEMENTVALUE_SAFEBOOT_MINIMAL }
                    elseif ($SafeBoot -eq "Network") { $ELEMENTVALUE_SAFEBOOT_NETWORK }
                New-Item -Path $elementKeyPath -Force | Out-Null
                New-ItemProperty -Path $elementKeyPath -Name Element -PropertyType Binary -Value $data -Force | Out-Null
            }
        }

    } catch {
        Write-Error "An error occurred: $_"
    }

    finally {
        # Restore ACL
        $RegKey.SetAccessControl($OriginalAcl)
        $RegKey.Close()
    }
}