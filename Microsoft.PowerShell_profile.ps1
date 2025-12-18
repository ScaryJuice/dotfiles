# Initialize Starship prompt for PowerShell
Invoke-Expression (&starship init powershell)

# Bind TAB key to menu-style autocompletion
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Bind Ctrl+D to Vi-mode exit functionality
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

# Register tab completion for `winget`, Windows Package Manager
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    # Optional: Set UTF-8 encoding explicitly (modern PowerShell defaults to UTF-8)
    # [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()

    # Escape double quotes to ensure proper handling of completion arguments
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')

    # Fetch and return completions from the winget CLI
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

