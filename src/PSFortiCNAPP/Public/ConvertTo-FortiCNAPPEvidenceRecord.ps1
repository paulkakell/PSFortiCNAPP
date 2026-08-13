# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

function ConvertTo-FortiCNAPPEvidenceRecord {
    <#
    .SYNOPSIS
    Converts a finding-shaped object into a stable PSFortiCNAPP evidence record.

    .DESCRIPTION
    Accepts synthetic or sanitized input through the pipeline, validates required
    properties, normalizes supported values and UTC timestamps, and returns a
    predictable object for filtering, grouping, testing, and reporting.

    This command performs local transformation only. It makes no network request
    and does not retain the original input object.

    .PARAMETER InputObject
    Finding-shaped object to validate and normalize.

    .PARAMETER SourceSystem
    Name of the fixture or source that supplied the input object.

    .PARAMETER DataClassification
    Classification applied to the output. Chapter 3 permits SYNTHETIC and
    SANITIZED input only.

    .PARAMETER CollectedAtUtc
    UTC collection timestamp applied to the output objects.

    .EXAMPLE
    $fixture.findings |
        ConvertTo-FortiCNAPPEvidenceRecord `
            -SourceSystem 'Chapter03Fixture' `
            -DataClassification SYNTHETIC

    .OUTPUTS
    PSFortiCNAPP.EvidenceRecord
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [psobject]$InputObject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$SourceSystem = 'SyntheticFixture',

        [Parameter()]
        [ValidateSet('SYNTHETIC', 'SANITIZED')]
        [string]$DataClassification = 'SYNTHETIC',

        [Parameter()]
        [DateTimeOffset]$CollectedAtUtc = [DateTimeOffset]::UtcNow
    )

    process {
        $requiredPropertyNames = @(
            'sourceRecordId'
            'domain'
            'findingType'
            'title'
            'severity'
            'status'
            'resourceId'
            'resourceType'
            'cloudProvider'
            'observedAtUtc'
            'evidenceState'
        )

        $requiredValues = @{}
        foreach ($propertyName in $requiredPropertyNames) {
            $property = $InputObject.PSObject.Properties[$propertyName]
            $propertyIsMissing = $null -eq $property -or $null -eq $property.Value
            $propertyIsEmpty = -not $propertyIsMissing -and
                [string]::IsNullOrWhiteSpace([string]$property.Value)

            if ($propertyIsMissing -or $propertyIsEmpty) {
                Write-Error `
                    -Message "Input object property '$propertyName' is required and cannot be empty." `
                    -ErrorId 'PSFortiCNAPP.EvidenceRecord.RequiredPropertyMissing' `
                    -Category InvalidData `
                    -TargetObject $InputObject `
                    -ErrorAction Stop
            }

            $requiredValues[$propertyName] = ([string]$property.Value).Trim()
        }

        $optionalValues = @{}
        foreach ($propertyName in @('accountId', 'region', 'owner', 'businessService')) {
            $property = $InputObject.PSObject.Properties[$propertyName]
            if (
                $null -eq $property -or
                $null -eq $property.Value -or
                [string]::IsNullOrWhiteSpace([string]$property.Value)
            ) {
                $optionalValues[$propertyName] = $null
            }
            else {
                $optionalValues[$propertyName] = ([string]$property.Value).Trim()
            }
        }

        $severityMap = @{
            critical = 'Critical'
            high     = 'High'
            medium   = 'Medium'
            low      = 'Low'
            info     = 'Info'
        }
        $severityKey = $requiredValues['severity'].ToLowerInvariant()
        if (-not $severityMap.ContainsKey($severityKey)) {
            Write-Error `
                -Message "Severity '$($requiredValues['severity'])' is not supported." `
                -ErrorId 'PSFortiCNAPP.EvidenceRecord.InvalidSeverity' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }
        $severity = $severityMap[$severityKey]

        $statusMap = @{
            open         = 'Open'
            resolved     = 'Resolved'
            acceptedrisk = 'AcceptedRisk'
            suppressed   = 'Suppressed'
        }
        $statusKey = $requiredValues['status'].ToLowerInvariant()
        if (-not $statusMap.ContainsKey($statusKey)) {
            Write-Error `
                -Message "Status '$($requiredValues['status'])' is not supported." `
                -ErrorId 'PSFortiCNAPP.EvidenceRecord.InvalidStatus' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }
        $status = $statusMap[$statusKey]

        $evidenceStateMap = @{
            observed = 'Observed'
            stale    = 'Stale'
        }
        $evidenceStateKey = $requiredValues['evidenceState'].ToLowerInvariant()
        if (-not $evidenceStateMap.ContainsKey($evidenceStateKey)) {
            Write-Error `
                -Message "Evidence state '$($requiredValues['evidenceState'])' is not supported for a finding record." `
                -ErrorId 'PSFortiCNAPP.EvidenceRecord.InvalidEvidenceState' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }
        $evidenceState = $evidenceStateMap[$evidenceStateKey]

        $dateTimeStyles = (
            [System.Globalization.DateTimeStyles]::AssumeUniversal -bor
            [System.Globalization.DateTimeStyles]::AdjustToUniversal
        )
        $observedAtUtc = [DateTimeOffset]::MinValue
        $timestampIsValid = [DateTimeOffset]::TryParse(
            $requiredValues['observedAtUtc'],
            [System.Globalization.CultureInfo]::InvariantCulture,
            $dateTimeStyles,
            [ref]$observedAtUtc
        )
        if (-not $timestampIsValid) {
            Write-Error `
                -Message "Observed timestamp '$($requiredValues['observedAtUtc'])' is not a valid date and time." `
                -ErrorId 'PSFortiCNAPP.EvidenceRecord.InvalidObservedTimestamp' `
                -Category InvalidData `
                -TargetObject $InputObject `
                -ErrorAction Stop
        }

        $severityRank = switch ($severity) {
            'Critical' { 1 }
            'High' { 2 }
            'Medium' { 3 }
            'Low' { 4 }
            'Info' { 5 }
        }
        $isOpen = $status -eq 'Open'
        $isCurrentEvidence = $evidenceState -eq 'Observed'
        $isPriorityCandidate = $isOpen -and $severityRank -le 2

        $record = [pscustomobject][ordered]@{
            EvidenceId          = '{0}:{1}' -f $SourceSystem.Trim(), $requiredValues['sourceRecordId']
            SourceSystem        = $SourceSystem.Trim()
            SourceRecordId      = $requiredValues['sourceRecordId']
            DataClassification  = $DataClassification.ToUpperInvariant()
            CollectedAtUtc      = $CollectedAtUtc.ToUniversalTime()
            ObservedAtUtc       = $observedAtUtc.ToUniversalTime()
            EvidenceState       = $evidenceState
            Domain              = $requiredValues['domain']
            FindingType         = $requiredValues['findingType']
            Title               = $requiredValues['title']
            Severity            = $severity
            SeverityRank        = $severityRank
            Status              = $status
            IsOpen              = $isOpen
            IsCurrentEvidence   = $isCurrentEvidence
            IsPriorityCandidate = $isPriorityCandidate
            CloudProvider       = $requiredValues['cloudProvider']
            AccountId           = $optionalValues['accountId']
            Region              = $optionalValues['region']
            ResourceType        = $requiredValues['resourceType']
            ResourceId          = $requiredValues['resourceId']
            BusinessService     = $optionalValues['businessService']
            Owner               = $optionalValues['owner']
        }
        $record.PSObject.TypeNames.Insert(0, 'PSFortiCNAPP.EvidenceRecord')

        $record
    }
}
