# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 1 synthetic scope-register fixture' {
    BeforeAll {
        $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:FixturePath = Join-Path -Path $script:RepositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-01-scope-register.json'
        $script:FixtureText = Get-Content -LiteralPath $script:FixturePath -Raw -Encoding utf8
        $script:Fixture = $script:FixtureText | ConvertFrom-Json -Depth 20
    }

    It 'is explicitly classified and licensed' {
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
        $script:Fixture.spdxLicenseIdentifier | Should -Be 'Apache-2.0'
        $script:Fixture.organization | Should -Be 'Kestrel Vale Health Services'
    }

    It 'contains unique scope identifiers' {
        $scopeIds = @($script:Fixture.scopes.scopeId)
        $uniqueScopeIds = @($scopeIds | Sort-Object -Unique)

        $scopeIds | Should -HaveCount $uniqueScopeIds.Count
    }

    It 'covers the planned foundational platforms' {
        $platforms = @($script:Fixture.scopes.platform | Sort-Object -Unique)

        $platforms | Should -Contain 'AWS'
        $platforms | Should -Contain 'Azure'
        $platforms | Should -Contain 'GoogleCloud'
        $platforms | Should -Contain 'Kubernetes'
        $platforms | Should -Contain 'ContainerRegistry'
    }

    It 'distinguishes missing, stale, observed, and excluded evidence' {
        $states = @($script:Fixture.scopes.evidenceState | Sort-Object -Unique)

        $states | Should -Contain 'Observed'
        $states | Should -Contain 'Missing'
        $states | Should -Contain 'Stale'
        $states | Should -Contain 'Excluded'
    }

    It 'uses timestamps only where evidence was observed' {
        foreach ($scope in $script:Fixture.scopes) {
            if ($scope.evidenceState -in @('Observed', 'Stale')) {
                $scope.lastObservedUtc | Should -Not -BeNullOrEmpty
                { [DateTimeOffset]::Parse($scope.lastObservedUtc) } | Should -Not -Throw
            }
            else {
                $scope.lastObservedUtc | Should -BeNullOrEmpty
            }
        }
    }

    It 'contains no common credential or production-account patterns' {
        $script:FixtureText | Should -Not -Match '\b(?:AKIA|ASIA)[0-9A-Z]{16}\b'
        $script:FixtureText | Should -Not -Match '\b[0-9]{12}\b'
        $script:FixtureText | Should -Not -Match '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    }
}
