# ===========================
# 1. Entry Parameter
# ===========================


param (
    [string]$cmd = "help"
)

$TerraformExe = "terraform"
$Modules = @(
    "Terraform/terraform/resource_manager",
    "Terraform/terraform/log_collector",
    "Terraform/terraform/usage_cost_monitor",
    "Terraform/terraform/provision"
)


# ===========================
# 2. All Function Definitions
# ===========================

function Show-Help {
    @"
Available commands:
- help                      : Show this help message
- zip-all                  : Zip all Lambda functions
- zip-one                  : Zip one Lambda function
- init                     : Initialize all Terraform modules
- plan                     : Run terraform plan in all modules
- apply                    : Select and apply a Terraform module
- destroy                  : Select and destroy a Terraform module
- destroy-all              : Destroy all Terraform modules
- validate                 : Validate all Terraform modules
- create                   : Run terraform apply for provision module
- check-provision          : Ensure provision module is applied
- deploy-resource_manager  : Deploy resource_manager module
- deploy-log_collector     : Deploy log_collector module
- deploy-usage_cost_monitor: Deploy usage_cost_monitor module
- deploy-all               : Deploy all modules
- clean                    : Remove zipped Lambda packages
- test                     : Run usage_cost_monitor test script
"@
}

function Zip-All {
    $LambdaDirs = Get-ChildItem terraform/lambda -Directory | Where-Object { $_.Name -ne "utils" }
    New-Item -ItemType Directory -Force -Path terraform/packages | Out-Null
    foreach ($dir in $LambdaDirs) {
        Write-Host "Zipping $($dir.Name)..."
        Compress-Archive -Path "terraform/lambda/$($dir.Name)", "terraform/lambda/utils" -DestinationPath "terraform/packages/$($dir.Name).zip" -Force
    }
    Write-Host "All Lambda functions zipped."
}

function Zip-One {
    $LambdaDirs = Get-ChildItem terraform/lambda -Directory | Where-Object { $_.Name -ne "utils" }
    $i = 1
    foreach ($d in $LambdaDirs) {
        Write-Host "$i) $($d.Name)"
        $i++
    }
    $choice = Read-Host "Select a Lambda function by number"
    $selected = $LambdaDirs[$choice - 1]
    if ($selected) {
        Compress-Archive -Path "terraform/lambda/$($selected.Name)", "terraform/lambda/utils" -DestinationPath "terraform/packages/$($selected.Name).zip" -Force
        Write-Host "$($selected.Name) zipped."
    }
}

function Init-All {
    foreach ($module in $Modules) {
        Write-Host "Initializing $module..."
        Push-Location $module
        & $TerraformExe init
        Pop-Location
    }
}

function Plan-All {
    Zip-All
    foreach ($module in $Modules) {
        Write-Host "Planning $module..."
        Push-Location $module
        & $TerraformExe plan
        Pop-Location
    }
}

function Apply-Select {
    $i = 1
    foreach ($m in $Modules) {
        Write-Host "$i) $m"
        $i++
    }
    $choice = Read-Host "Select a module by number"
    $target = $Modules[$choice - 1]
    if ($target) {
        Push-Location $target
        & $TerraformExe init -input=false
        & $TerraformExe apply -auto-approve
        Pop-Location
    }
}

function Destroy-Select {
    $i = 1
    foreach ($m in $Modules) {
        Write-Host "$i) $m"
        $i++
    }
    $choice = Read-Host "Select a module to destroy by number"
    $target = $Modules[$choice - 1]
    if ($target) {
        Push-Location $target
        & $TerraformExe init -input=false
        & $TerraformExe plan -destroy
        $confirm = Read-Host "Really destroy $target? (yes/no)"
        if ($confirm -eq "yes") {
            & $TerraformExe destroy -auto-approve
        }
        else {
            Write-Host "Destroy cancelled."
        }
        Pop-Location
    }
}

function Destroy-All {
    foreach ($module in $Modules) {
        Push-Location $module
        & $TerraformExe init -input=false
        & $TerraformExe plan -destroy
        Pop-Location
    }
    $confirm = Read-Host "Really destroy ALL modules? (yes/no)"
    if ($confirm -eq "yes") {
        foreach ($module in $Modules) {
            Push-Location $module
            & $TerraformExe destroy -auto-approve
            Pop-Location
        }
        Write-Host "All modules destroyed."
    }
    else {
        Write-Host "Destroy-all cancelled."
    }
}

function Validate-All {
    foreach ($module in $Modules) {
        Write-Host "Validating $module..."
        Push-Location $module
        & $TerraformExe validate
        Pop-Location
    }
}

function Create-Provision {
    Push-Location terraform/Terraform/provision
    & $TerraformExe init -input=false
    & $TerraformExe apply -auto-approve
    Pop-Location
}

function Check-Provision {
    if (-Not (Test-Path terraform/Terraform/provision/terraform.tfstate)) {
        Write-Host "Infrastructure is not provisioned. Run 'make.ps1 create' first."
        exit 1
    }
}

function Deploy-ResourceManager {
    Check-Provision
    Push-Location terraform/Terraform/resource_manager
    & $TerraformExe init -input=false
    & $TerraformExe apply -auto-approve
    Pop-Location
}

function Deploy-LogCollector {
    Check-Provision
    Push-Location terraform/Terraform/log_collector
    & $TerraformExe init -input=false
    & $TerraformExe apply -auto-approve
    Pop-Location
}

function Deploy-UsageCostMonitor {
    Check-Provision
    Push-Location terraform/Terraform/usage_cost_monitor
    & $TerraformExe init -input=false
    & $TerraformExe apply -auto-approve
    Pop-Location
}

function Deploy-All {
    Zip-All
    foreach ($module in $Modules) {
        Write-Host "Deploying $module..."
        Push-Location $module
        & $TerraformExe init -input=false
        & $TerraformExe apply -auto-approve
        Pop-Location
    }
}

function Clean-Packages {
    Remove-Item terraform/packages/*.zip -Force -ErrorAction SilentlyContinue
    Write-Host "Zipped packages cleaned."
}

function Run-Test {
    python terraform/lambda/usage_cost_monitor/handler.py
}

# ===========================
# Dispatch Entry Point
# ===========================

switch ($cmd.ToLower()) {
    "help" { Show-Help }
    "zip-all" { Zip-All }
    "zip-one" { Zip-One }
    "init" { Init-All }
    "plan" { Plan-All }
    "apply" { Apply-Select }
    "destroy" { Destroy-Select }
    "destroy-all" { Destroy-All }
    "validate" { Validate-All }
    "create" { Create-Provision }
    "check-provision" { Check-Provision }
    "deploy-resource_manager" { Deploy-ResourceManager }
    "deploy-log_collector" { Deploy-LogCollector }
    "deploy-usage_cost_monitor" { Deploy-UsageCostMonitor }
    "deploy-all" { Deploy-All }
    "clean" { Clean-Packages }
    "test" { Run-Test }
    default { Write-Host "Unknown command. Use 'help' for list." }
}