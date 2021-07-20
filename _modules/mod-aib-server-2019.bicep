param imageTemplateName string
param location string = 'westeurope'
param userAssignedIdentityId string
param imageGalleryName string
param resourceTags object = {}
param datetime string = utcNow()

resource sharedimagegallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: imageGalleryName
}

resource imagetemplatedef 'Microsoft.Compute/galleries/images@2020-09-30' = {
  name: '${sharedimagegallery.name}/${imageTemplateName}'
  location: location
  tags: resourceTags
  properties: {
    osState: 'Generalized'
    osType: 'Windows'
    description: 'Server 2019 DevOps Agent'
    purchasePlan: {
      publisher: ''
    }
    identifier: {
      offer: imageTemplateName
      sku: 'default'
      publisher: 'rbnmk'
    }
    recommended: {
      vCPUs: {
        max: 32
        min: 8
      }
      memory: {
        min: 8
        max: 64
      }
    }
  }
}

resource imageTemplateName_resource 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: '${imageTemplateName}-${datetime}'
  location: location
  tags: resourceTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 300
    vmProfile: {
      vmSize: 'Standard_D8_v4'
      osDiskSizeGB: 127
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'Install Choco'
        runAsSystem: true
        runElevated: true
        inline: [
          'Invoke-Expression ((New-Object -TypeName net.webclient).DownloadString("https://chocolatey.org/install.ps1"))'
          'choco feature enable -n allowGlobalConfirmation'
          'Write-Host "Chocolatey Installed"'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install Tools'
        runAsSystem: true
        runElevated: true
        inline: [
          'choco install pwsh git az.powershell azure-cli bicep azcopy10 dotnetcore choco dotnetcore-sdk dotnet4.7 azure-functions-core-tools-3 --yes --no-progress'
          'Write-Host "Choco tool install completed!"'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install PowerShell Modules'
        runAsSystem: true
        runElevated: true
        inline: [
          'Install-Module Pester -Force'
          'Install-Module MarkdownPS -Force'
          'Install-Module SqlServer -Force'
          'Install-Module VSSetup -Force'
        ]
      }
      {
        type: 'WindowsRestart'
        restartTimeout: '10m'
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude: $_.Title -like "*Preview*"'
          'include: $true'
        ]
      }
      {
        type: 'PowerShell'
        runElevated: true
        name: 'DeprovisioningScript'
        inline: [
          '((Get-Content -path C:\\DeprovisioningScript.ps1 -Raw) -replace "Sysprep.exe /oobe /generalize /quiet /quit","Sysprep.exe /oobe /generalize /quit /mode:vm" ) | Set-Content -Path C:\\DeprovisioningScript.ps1'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imagetemplatedef.id
        runOutputName: 'win10Client'
        artifactTags: {}
        replicationRegions: []
      }
    ]
  }
  dependsOn: []
}
