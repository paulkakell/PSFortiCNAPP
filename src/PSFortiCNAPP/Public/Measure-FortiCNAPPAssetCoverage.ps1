# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function Measure-FortiCNAPPAssetCoverage {
    <#
    .SYNOPSIS
    Measures current asset observation coverage against an explicit scope register.

    .DESCRIPTION
    Compares synthetic or sanitized asset observations with an intended scope
    register. It retains current, stale, missing, duplicate, excluded, and
    unexpected records as separate collections and states the coverage
    denominator.

    This function performs local calculation only. It does not call FortiCNAPP.

    .PARAMETER ScopeRegister
    Intended asset scope. Each object requires scopeId, assetId, platform, and included.

    .PARAMETER ObservedAsset
    Collected observations. Each object requires sourceRecordId, assetId,
    platform, and observedAtUtc.

    .PARAMETER AsOfUtc
    UTC assessment time.

    .PARAMETER FreshnessThresholdHours
    Maximum observation age in hours.

    .PARAMETER DataClassification
    SYNTHETIC or SANITIZED.

    .OUTPUTS
    PSFortiCNAPP.AssetCoverage
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$ScopeRegister,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$ObservedAsset,

        [Parameter()]
        [DateTimeOffset]$AsOfUtc = [DateTimeOffset]::UtcNow,

        [Parameter()]
        [ValidateRange(1, 8760)]
        [int]$FreshnessThresholdHours = 24,

        [Parameter()]
        [ValidateSet('SYNTHETIC', 'SANITIZED')]
        [string]$DataClassification = 'SYNTHETIC'
    )

    $asOf = $AsOfUtc.ToUniversalTime()
    $freshnessBoundary = $asOf.AddHours(-1 * $FreshnessThresholdHours)
    $requiredScopeProperties = @('scopeId', 'assetId', 'platform', 'included')
    $requiredObservationProperties = @('sourceRecordId', 'assetId', 'platform', 'observedAtUtc')

    foreach ($scope in $ScopeRegister) {
        foreach ($propertyName in $requiredScopeProperties) {
            $property = $scope.PSObject.Properties[$propertyName]
            if ($null -eq $property -or $null -eq $property.Value) {
                Write-Error `
                    -Message "Scope register property '$propertyName' is required." `
                    -ErrorId 'PSFortiCNAPP.AssetCoverage.InvalidScopeRecord' `
                    -Category InvalidData `
                    -TargetObject $scope `
                    -ErrorAction Stop
            }
        }
    }

    $normalizedObservations = [System.Collections.Generic.List[object]]::new()
    foreach ($observation in $ObservedAsset) {
        foreach ($propertyName in $requiredObservationProperties) {
            $property = $observation.PSObject.Properties[$propertyName]
            if ($null -eq $property -or $null -eq $property.Value) {
                Write-Error `
                    -Message "Observation property '$propertyName' is required." `
                    -ErrorId 'PSFortiCNAPP.AssetCoverage.InvalidObservation' `
                    -Category InvalidData `
                    -TargetObject $observation `
                    -ErrorAction Stop
            }
        }

        $observedText = ([string]$observation.observedAtUtc).Trim()
        if ($observedText -notmatch '(?i)(Z|[+-]\d{2}:\d{2})$') {
            Write-Error `
                -Message 'Observation timestamps must include Z or an explicit UTC offset.' `
                -ErrorId 'PSFortiCNAPP.AssetCoverage.InvalidTimestamp' `
                -Category InvalidData `
                -TargetObject $observation `
                -ErrorAction Stop
        }

        $observedAtUtc = [DateTimeOffset]::MinValue
        if (
            -not [DateTimeOffset]::TryParse(
                $observedText,
                [System.Globalization.CultureInfo]::InvariantCulture,
                ([System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal),
                [ref]$observedAtUtc
            )
        ) {
            Write-Error `
                -Message 'Observation timestamp could not be parsed.' `
                -ErrorId 'PSFortiCNAPP.AssetCoverage.InvalidTimestamp' `
                -Category InvalidData `
                -TargetObject $observation `
                -ErrorAction Stop
        }

        $normalizedObservations.Add(
            [pscustomobject][ordered]@{
                SourceRecordId = ([string]$observation.sourceRecordId).Trim()
                AssetId        = ([string]$observation.assetId).Trim()
                Platform       = ([string]$observation.platform).Trim()
                ObservedAtUtc  = $observedAtUtc.ToUniversalTime()
            }
        )
    }

    $includedScope = @($ScopeRegister | Where-Object -FilterScript { [bool]$_.included })
    $excludedScope = @($ScopeRegister | Where-Object -FilterScript { -not [bool]$_.included })

    $duplicateGroups = @(
        $normalizedObservations |
            Group-Object -Property AssetId |
            Where-Object -FilterScript { $_.Count -gt 1 }
    )
    $duplicateRecords = @(
        foreach ($group in $duplicateGroups) {
            [pscustomobject][ordered]@{
                AssetId          = $group.Name
                ObservationCount = $group.Count
                SourceRecordIds  = @($group.Group.SourceRecordId)
            }
        }
    )

    $latestByAsset = @{}
    foreach ($group in ($normalizedObservations | Group-Object -Property AssetId)) {
        $latestByAsset[$group.Name] = $group.Group |
            Sort-Object -Property ObservedAtUtc -Descending |
            Select-Object -First 1
    }

    $currentAssets = [System.Collections.Generic.List[object]]::new()
    $staleAssets = [System.Collections.Generic.List[object]]::new()
    $missingAssets = [System.Collections.Generic.List[object]]::new()

    foreach ($scope in $includedScope) {
        $assetId = ([string]$scope.assetId).Trim()
        if (-not $latestByAsset.ContainsKey($assetId)) {
            $missingAssets.Add($scope)
            continue
        }

        $latest = $latestByAsset[$assetId]
        $assessmentRecord = [pscustomobject][ordered]@{
            ScopeId        = ([string]$scope.scopeId).Trim()
            AssetId        = $assetId
            Platform       = ([string]$scope.platform).Trim()
            ObservedAtUtc  = $latest.ObservedAtUtc
            SourceRecordId = $latest.SourceRecordId
            AgeHours       = [math]::Round(($asOf - $latest.ObservedAtUtc).TotalHours, 2)
        }

        if ($latest.ObservedAtUtc -ge $freshnessBoundary) {
            $currentAssets.Add($assessmentRecord)
        }
        else {
            $staleAssets.Add($assessmentRecord)
        }
    }

    $includedIds = @($includedScope | ForEach-Object { ([string]$_.assetId).Trim() })
    $unexpectedAssets = @(
        $latestByAsset.Values |
            Where-Object -FilterScript { $_.AssetId -notin $includedIds } |
            Sort-Object -Property AssetId
    )

    $coveragePercent = if ($includedScope.Count -eq 0) {
        $null
    }
    else {
        [math]::Round(($currentAssets.Count / $includedScope.Count) * 100, 2)
    }

    $result = [pscustomobject][ordered]@{
        DataClassification      = $DataClassification
        AsOfUtc                 = $asOf
        FreshnessThresholdHours = $FreshnessThresholdHours
        CoverageDenominator     = 'Included scope assets'
        IntendedAssetCount      = $includedScope.Count
        CurrentAssetCount       = $currentAssets.Count
        StaleAssetCount         = $staleAssets.Count
        MissingAssetCount       = $missingAssets.Count
        ExcludedAssetCount      = $excludedScope.Count
        UnexpectedAssetCount    = $unexpectedAssets.Count
        DuplicateAssetCount     = $duplicateRecords.Count
        CoveragePercent         = $coveragePercent
        CurrentAssets           = $currentAssets.ToArray()
        StaleAssets             = $staleAssets.ToArray()
        MissingAssets           = $missingAssets.ToArray()
        ExcludedAssets          = $excludedScope
        UnexpectedAssets       = $unexpectedAssets
        DuplicateAssets        = $duplicateRecords
        TenantValidationState   = 'NOT APPLICABLE'
        CalculationAuthority    = 'PowerShellDerived'
    }
    $result.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.AssetCoverage')

    return $result
}
