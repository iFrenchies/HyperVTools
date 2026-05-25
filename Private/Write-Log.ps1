function Write-Log {
    <#
    .SYNOPSIS
        Écrit un message de log standardisé.

    .DESCRIPTION
        Permet d’écrire des messages de log avec un niveau (Info, Warning, Error)
        et une couleur adaptée. Peut être utilisée par toutes les fonctions
        du module, et plus tard redirigée vers un fichier ou une GUI.

    .PARAMETER Message
        Texte du message à afficher.

    .PARAMETER Level
        Niveau de log : Info, Warning, Error, Success.

    .EXAMPLE
        Write-Log -Message "Création de la VM terminée." -Level Success
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info","Warning","Error","Success")]
        [string]$Level = "Info"
    )

    switch ($Level) {
        "Info" {
            Write-Host "[INFO]    $Message" -ForegroundColor Cyan
        }
        "Warning" {
            Write-Host "[WARNING] $Message" -ForegroundColor Yellow
        }
        "Error" {
            Write-Host "[ERROR]   $Message" -ForegroundColor Red
        }
        "Success" {
            Write-Host "[SUCCESS] $Message" -ForegroundColor Green
        }
    }
}
