import-module au
. $PSScriptRoot\..\_scripts\all.ps1

$GitHubRepositoryUrl = 'https://github.com/1Remote/PRemoteM'

function global:au_SearchReplace {
   @{

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"            = "`${1} $($Latest.URL32)"
          "(?i)(checksum32:).*"        = "`${1} $($Latest.Checksum32)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_GetLatest {
    $url = Get-GitHubReleaseUrl $GitHubRepositoryUrl '\.7z|\.zip$'
    $version = $url[0] -split '/' | select -Last 1 -Skip 1

    return @{
        Version      = $version -replace '^v'
        URL64        = $url -match 'x86' | Select-Object -First 1
        ReleaseNotes = "$GitHubRepositoryUrl/releases/tag/$version"
    }
}

update -ChecksumFor none
