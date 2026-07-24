$TestKsyTemplate = @'
meta:
  id: $KsId
  imports:
    - ../../nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: v
    type: $KsType
'@ -replace "`r`n", "`n"

$KstTemplate = @'
id: $KsId
data: $KstSource
asserts:
$KsAsserts
'@ -replace "`r`n", "`n"

function ConvertTo-SnakeCase {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$InputString
  )

  process {
    if ([string]::IsNullOrWhiteSpace($InputString)) {
      return [PSCustomObject]@{
        Original  = $InputString
        Detected  = "Unknown"
        SnakeCase = $InputString
      }
    }

    $detectedType = "Unknown"
    
    # Like snake case
    if ($InputString -like '*_*') {
      if ($InputString -cmatch '^[a-z0-9_]+$') {
        $detectedType = "SnakeCase (Lower)"
      }
      else {
        $detectedType = "SnakeCase (Modified/Upper)"
      }
    }
    # Camel case, includes single upper word
    elseif ($InputString -cmatch '^[a-z][a-zA-Z0-9]*$') {
      $detectedType = "CamelCase"
    }
    # Pascal case
    elseif ($InputString -cmatch '^[A-Z][a-zA-Z0-9]*$') {
      $detectedType = "PascalCase"
    }
    # single lower word
    elseif ($InputString -cmatch '^[a-z0-9]+$') {
      $detectedType = "Single Word (Lower)"
    }

    if ($detectedType -like "SnakeCase*" -or $detectedType -eq "Single Word (Lower)") {
      $snakeResult = $InputString.ToLower()
    } 
    else {
      $snakeResult = [regex]::Replace($InputString, '(?<=.)([A-Z])', '_$1').ToLower()
    }

    [PSCustomObject]@{
      Original  = $InputString
      Detected  = $detectedType
      SnakeCase = $snakeResult
    }
  }
}

function New-KstAsserts {
  param(
    $Indent = ' ' * 2,
    $Key = 'v',
    $Obj
  )

  $Key = (ConvertTo-SnakeCase -InputString $Key).SnakeCase

  switch ($obj.GetType().Name) {
    "PSCustomObject" {
      foreach ($p in $Obj.psobject.Properties) {
        $propKey = (ConvertTo-SnakeCase -InputString $p.Name).SnakeCase
        New-KstAsserts -Indent $Indent -Key "$Key.$propKey" -Obj $p.Value
      }
      break
    }
    "Object[]" {
      $i = 0
      foreach ($p in $Obj) {
        New-KstAsserts -Indent $Indent -Key "$Key.v[$i]" -Obj $p
        $i++
      }
      break
    }
    default {
      @"
${Indent}- actual: $($Key[-1] -eq ']' ? $Key : "$Key.v")
${Indent}  expected: $(switch($Obj) {
  { $_ -is [string] } {
    "'`"$_`"'"
  }
  { $_ -is [bool] } {
    $_.ToString().ToLower()
  }
  default {
    $_
  }
})
"@
      break
    }
  }
}

function New-Kst {
  $testvars = & "$PSScriptRoot/testvars.ps1"
  $ksyDir = "$PSScriptRoot/ksy"
  $kstDir = "$PSScriptRoot/kst"
  foreach ($p in @($ksyDir, $kstDir)) {
    if (Test-Path -Path $p) {
      Remove-Item -Path $p -Recurse > $null
    }
    New-Item -Path $p -ItemType Directory > $null
  }
  $encoding = [System.Text.UTF8Encoding]::new($false)
  foreach ($t in $testvars) {
    if (-not $t.KsType) { continue }

    $isPrimitive = $t.KsType -like '*nj*'
    $json = "[$($t.Json)]" | ConvertFrom-Json -Depth 8
    $isArray = $json -is [array]

    $KsId = $t.KsId
    $KsType = $t.KsType
    $KstSource = "$($t.Key).bin"
    $KsAsserts = (New-KstAsserts `
        -Indent (' ' * 2) `
        -Key ($isPrimitive ? 'v' : 'v') `
        -Obj $json) `
      -Join "`n"
    $kst = $ExecutionContext.InvokeCommand.ExpandString($KstTemplate)
    $TestKsy = $ExecutionContext.InvokeCommand.ExpandString($TestKsyTemplate)

    [System.IO.File]::WriteAllText("$ksyDir/$ksId.ksy", $TestKsy, $encoding)
    [System.IO.File]::WriteAllText("$kstDir/$ksId.kst", $kst, $encoding)
  }
}

New-Kst
