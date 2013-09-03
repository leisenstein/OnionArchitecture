Param(
  [string]$pathToSearch = $env:TF_BUILD_SOURCESDIRECTORY,
  [string]$buildNumber = $env:TF_BUILD_BUILDNUMBER,
  [string]$searchFilter = "AssemblyInfo.*",
  [regex]$pattern = "\d+\.\d+\.\d+\.\d+"
)

if ($buildNumber -match $pattern -ne $true) {
    Write-Host "Could not extract a version from [$buildNumber] using pattern [$pattern]"
} else {
    $extractedBuildNumber = $Matches[0]
    Write-Host "Using version $extractedBuildNumber"

    gci -Path $pathToSearch -Filter $searchFilter -Recurse | %{
        Write-Host "  -> Changing $($_.FullName)" 
		
		# remove the read-only bit on the file
		sp $_.FullName IsReadOnly $false

		# run the regex replace
        (gc $_.FullName) | % { $_ -replace $pattern, $extractedBuildNumber } | sc $_.FullName
    }

    Write-Host "Done!"
}