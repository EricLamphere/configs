oh-my-posh init pwsh --config "C:\Users\ericj\AppData\Local\Programs\oh-my-posh\themes\robbyrussel.omp.json" | Invoke-Expression


# Color directories blue
$PSStyle.FileInfo.Directory = "`e[36m"


# Aliases
Set-Alias -Name c -Value clear
