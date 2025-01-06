# PowerBCD
This tool allows you to modify a few common BCD (Boot Configuration Data) options in the current Windows Boot Loader directly through the Registry, eliminating the need for `bcdedit.exe`.

This small research was conducted to explore the following question: Why do ransomware developers consistently use highly detectable and incriminating command lines, such as `bcdedit.exe /set bootstatuspolicy ignoreallfailures` or `bcdedit.exe /set recoveryenabled no`, instead of adopting stealthier approaches by digging deeper into the system?

## Usage:
```
iex (iwr https://raw.githubusercontent.com/itaymigdal/PowerBCD/refs/heads/main/PowerBCD.ps1) 

PowerBCD [[-TestSigning] {On | Off}] [[-RecoveryEnabled] {Yes | No}] [[-BootStatusPolicy] {DisplayAllFailures | IgnoreAllFailures}] [[-SafeBoot] {Minimal | Network | Off}]
```

***Use at your own risk!***