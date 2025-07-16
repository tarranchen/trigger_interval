<#
.SYNOPSIS
    This script retrieves the creation time (down to the millisecond) for all files
    in its current directory, displays the results on screen, and exports them to a CSV file.

.DESCRIPTION
    1. Automatically gets the directory path where the script is running.
    2. Uses Get-ChildItem -File to retrieve all file objects.
    3. Iterates through each file, formatting its CreationTime property to "yyyy-MM-dd HH:mm:ss.fff".
    4. Stores the results (FileName, CreationTime) in an array of custom objects.
    5. Uses Format-Table to display the results in the console.
    6. Uses Export-Csv to save the results to a CSV file in the same directory.
    7. Includes a full try/catch block for robust error handling.

.VERSION
    1.0
#>

# Clear the host for a clean output interface
Clear-Host

# Main logic block, using Try...Catch to handle any potential errors
try {
    # --- 1. Get the script's containing folder location ---
    Write-Host "Initializing script..." -ForegroundColor Green
    # $PSScriptRoot is an automatic PowerShell variable that contains the directory of the currently running script.
    $scriptDirectory = $PSScriptRoot
    Write-Host "Successfully located the script's directory: $scriptDirectory" -ForegroundColor Cyan

    # Define the output path and name for the CSV file
    $csvOutputPath = Join-Path -Path $scriptDirectory -ChildPath "FileCreationTime_Report.csv"

    # --- 2. Get all files ---
    Write-Host "`nScanning for all files in the directory..." -ForegroundColor Green
    # The -File parameter ensures that only files are retrieved, not folders.
    $files = Get-ChildItem -Path $scriptDirectory -File

    # Check if any files were found
    if ($null -eq $files) {
        Write-Warning "No files found in this directory. Script stopped."
        # Exit gracefully, this is not considered an error.
        exit
    }

    # Create an empty array to store our results
    $results = @()

    Write-Host "Processing files and retrieving creation times (with milliseconds)..." -ForegroundColor Green
    # --- 3. Get the creation time (with milliseconds) for each file ---
    foreach ($file in $files) {
        # Use .ToString("yyyy-MM-dd HH:mm:ss.fff") to format the DateTime object.
        # "fff" represents the milliseconds.
        $creationTimeWithMs = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss.fff")

        # Create a custom object for clean display and export
        $fileInfo = [PSCustomObject]@{
            "FileName"               = $file.Name
            "CreationTime (with ms)" = $creationTimeWithMs
        }

        # Add this object to our results array
        $results += $fileInfo
    }

    # --- 4. Display the results on screen ---
    Write-Host "`n---------- Scan Results ----------" -ForegroundColor Yellow
    $results | Format-Table -AutoSize

    # --- 5. Export the results to a CSV file ---
    Write-Host "`nExporting results to CSV file..." -ForegroundColor Green
    # -NoTypeInformation prevents the #TYPE header from being added to the CSV file.
    # -Encoding UTF8 ensures compatibility and prevents issues with special characters in filenames.
    $results | Export-Csv -Path $csvOutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Success! Report saved to: $csvOutputPath" -ForegroundColor Cyan
    Write-Host "`nScript finished successfully." -ForegroundColor Green

}
catch {
    # --- 6. Error Handling ---
    # The catch block executes if any "terminating error" occurs in the try block.
    Write-Host "`n!!!!!!!!!!!!!!!!!!!! AN ERROR OCCURRED !!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    Write-Host "The script encountered a critical error and could not continue." -ForegroundColor Red

    Write-Host "`n[Error Message]" -ForegroundColor Yellow
    # $_.Exception.Message provides the most direct explanation of the error.
    Write-Host $_.Exception.Message

    Write-Host "`n[Detailed Error Information]" -ForegroundColor Yellow
    # Display the full error object for advanced debugging.
    Write-Error -ErrorRecord $_ -RecommendedAction "Please check the recommended steps below."
    
    Write-Host "`n[Recommended Troubleshooting Steps]" -ForegroundColor Yellow
    Write-Host "1. Permissions Issue: Ensure you have permissions to read files in this directory `($scriptDirectory)` and to write a new file here."
    Write-Host "2. File Locked: Check if another program is currently using a file in this directory, preventing access."
    Write-Host "3. Path Issues: Verify the script path does not contain invalid characters or exceed the maximum path length for your system."
    Write-Host "4. PowerShell Version: In case of rare errors, try updating your PowerShell to the latest version."
}