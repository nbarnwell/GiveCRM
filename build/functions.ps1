#------------------------------------------------------------------------------------------------------------------#
#----------------------------------------Global Functions----------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------#
$path = Resolve-Path .
. $path\psake\teamcity.psm1

function global:run_msbuild ($solutionPath, $configuration)
{
    try 
    {
        switch ($configuration)
        {
            "release" 
            { 
                exec { msbuild $solutionPath "/t:rebuild" "/p:Configuration=$configuration;DeployOnBuild=true;DeployTarget=Package" } 
            }
            
            default 
            { 
                exec { msbuild $solutionPath "/t:rebuild" "/p:Configuration=$configuration" } 
            }
        }
    }
    catch 
    {
        TeamCity-ReportBuildStatus "ERROR" "MSBuild Compiler Error - see build log for details"
    }
}

function global:move_package ($source_dir, $destination_dir)
{
    try 
    {
        Copy-Item "$source_dir\*" $destination_dir -recurse
    } 
    catch 
    {
        TeamCity-ReportBuildStatus "ERROR" "Failed to move package $source_dir to $destination_dir."
    }
}

function global:clean_up_pdb_files($package_dir)
{
    try
    {
        Remove-Item "$package_dir\bin\*" -include "*.pdb"
    }
    catch
    {
        TeamCity-ReportBuildStatus "ERROR" "Failed cleaning up PDB files from $package_dir\bin."
    }
}

function global:clean_directory ($package_dir)
{
    if (Test-Path $package_dir) 
    {
        try 
        {
            Remove-Item "$package_dir\*" -recurse
        }
        catch
        {
            TeamCity-ReportBuildStatus "ERROR" "Failed to clean up $package_dir"
        }
    }
}