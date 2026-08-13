# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

BeforeAll {
    $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
    $script:ManifestPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'src/PSFortiCNAPP/PSFortiCNAPP.psd1'
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
    Import-Module -Name $script:ManifestPath -Force -ErrorAction Stop

    function New-ValidSyntheticFinding {
        [pscustomobject]@{
            sourceRecordId  = 'syn-unit-001'
            domain          = 'Compliance'
            findingType     = 'Configuration'
            title           = 'Synthetic unit-test finding'
            severity        = 'High'
            status          = 'Open'
            resourceId      = 'synthetic-resource-001'
            resourceType    = 'ObjectStorage'
            cloudProvider   = 'AWS'
            accountId       = 'synthetic-account'
            region          = 'synthetic-region'
            observedAtUtc   = '2026-08-13T18:00:00-06:00'
            owner           = 'Synthetic Owner'
            businessService = 'Synthetic Service'
            evidenceState   = 'Observed'
        }
    }
}

AfterAll {
    Remove-Module -Name PSFortiCNAPP -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-FortiCNAPPEvidenceRecord' {
    It 'returns a stable typed record' {
        $collectedAtUtc = [DateTimeOffset]'2026-08-14T00:30:00Z'
        $result = New-ValidSyntheticFinding |
            ConvertTo-FortiCNAPPEvidenceRecord `
                -SourceSystem 'UnitFixture' `
                -DataClassification SYNTHETIC `
                -CollectedAtUtc $collectedAtUtc

        $result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.EvidenceRecord'
        $result.EvidenceId | Should -Be 'UnitFixture:syn-unit-001'
        $result.SourceRecordId | Should -Be 'syn-unit-001'
        $result.DataClassification | Should -Be 'SYNTHETIC'
        $result.CollectedAtUtc | Should -Be $collectedAtUtc
        $result.Severity | Should -Be 'High'
        $result.SeverityRank | Should -Be 2
        $result.IsOpen | Should -BeTrue
        $result.IsCurrentEvidence | Should -BeTrue
        $result.IsPriorityCandidate | Should -BeTrue
    }

    It 'normalizes an offset timestamp to UTC' {
        $result = New-ValidSyntheticFinding |
            ConvertTo-FortiCNAPPEvidenceRecord

        $result.ObservedAtUtc.Offset | Should -Be ([TimeSpan]::Zero)
        $result.ObservedAtUtc.ToString('o') |
            Should -Be '2026-08-14T00:00:00.0000000+00:00'
    }

    It 'accepts pipeline collections and preserves order' {
        $first = New-ValidSyntheticFinding
        $second = New-ValidSyntheticFinding
        $second.sourceRecordId = 'syn-unit-002'
        $second.severity = 'Medium'

        $results = @(
            @($first, $second) |
                ConvertTo-FortiCNAPPEvidenceRecord -SourceSystem 'UnitFixture'
        )

        $results | Should -HaveCount 2
        $results[0].SourceRecordId | Should -Be 'syn-unit-001'
        $results[1].SourceRecordId | Should -Be 'syn-unit-002'
        $results[1].SeverityRank | Should -Be 3
    }

    It 'returns null for omitted optional context' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.PSObject.Properties.Remove('accountId')
        $inputObject.PSObject.Properties.Remove('region')
        $inputObject.PSObject.Properties.Remove('owner')
        $inputObject.PSObject.Properties.Remove('businessService')

        $result = $inputObject | ConvertTo-FortiCNAPPEvidenceRecord

        $result.AccountId | Should -BeNullOrEmpty
        $result.Region | Should -BeNullOrEmpty
        $result.Owner | Should -BeNullOrEmpty
        $result.BusinessService | Should -BeNullOrEmpty
    }

    It 'does not treat a resolved critical finding as a priority candidate' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.severity = 'Critical'
        $inputObject.status = 'Resolved'

        $result = $inputObject | ConvertTo-FortiCNAPPEvidenceRecord

        $result.SeverityRank | Should -Be 1
        $result.IsOpen | Should -BeFalse
        $result.IsPriorityCandidate | Should -BeFalse
    }

    It 'marks stale evidence separately from priority logic' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.evidenceState = 'Stale'

        $result = $inputObject | ConvertTo-FortiCNAPPEvidenceRecord

        $result.IsPriorityCandidate | Should -BeTrue
        $result.IsCurrentEvidence | Should -BeFalse
    }

    It 'does not retain the raw input object' {
        $result = New-ValidSyntheticFinding |
            ConvertTo-FortiCNAPPEvidenceRecord

        $propertyNames = @(
            $result |
                Get-Member -MemberType NoteProperty |
                Select-Object -ExpandProperty Name
        )
        $propertyNames | Should -Not -Contain 'InputObject'
        $propertyNames | Should -Not -Contain 'Raw'
    }

    It 'rejects a missing required property with a stable error identifier' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.PSObject.Properties.Remove('resourceId')
        $caughtError = $null

        try {
            $inputObject | ConvertTo-FortiCNAPPEvidenceRecord
        }
        catch {
            $caughtError = $_
        }

        $caughtError | Should -Not -BeNullOrEmpty
        $caughtError.FullyQualifiedErrorId |
            Should -Match '^PSFortiCNAPP\.EvidenceRecord\.RequiredPropertyMissing'
    }

    It 'rejects an unsupported severity' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.severity = 'Urgent'

        { $inputObject | ConvertTo-FortiCNAPPEvidenceRecord } |
            Should -Throw -ExpectedMessage "*Severity 'Urgent' is not supported*"
    }

    It 'rejects an unsupported status' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.status = 'Maybe'

        { $inputObject | ConvertTo-FortiCNAPPEvidenceRecord } |
            Should -Throw -ExpectedMessage "*Status 'Maybe' is not supported*"
    }

    It 'rejects an unsupported evidence state' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.evidenceState = 'Missing'

        { $inputObject | ConvertTo-FortiCNAPPEvidenceRecord } |
            Should -Throw -ExpectedMessage "*Evidence state 'Missing' is not supported*"
    }

    It 'rejects an invalid observed timestamp' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.observedAtUtc = 'not-a-date'

        { $inputObject | ConvertTo-FortiCNAPPEvidenceRecord } |
            Should -Throw -ExpectedMessage '*is not a valid date and time*'
    }

    It 'canonicalizes supported values without changing descriptive fields' {
        $inputObject = New-ValidSyntheticFinding
        $inputObject.severity = 'critical'
        $inputObject.status = 'acceptedrisk'
        $inputObject.evidenceState = 'observed'

        $result = $inputObject | ConvertTo-FortiCNAPPEvidenceRecord

        $result.Severity | Should -Be 'Critical'
        $result.Status | Should -Be 'AcceptedRisk'
        $result.EvidenceState | Should -Be 'Observed'
        $result.Title | Should -Be 'Synthetic unit-test finding'
    }
}
