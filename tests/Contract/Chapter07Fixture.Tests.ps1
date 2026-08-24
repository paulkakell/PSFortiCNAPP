# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 7 synthetic fixture contract' {
    BeforeAll {
        $script:RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:FixturePath = Join-Path -Path $script:RepositoryRoot -ChildPath 'tests/Fixtures/Synthetic/chapter-07-asset-coverage.json'
        $script:FixtureText = Get-Content -LiteralPath $script:FixturePath -Raw -Encoding utf8
        $script:Fixture = $script:FixtureText | ConvertFrom-Json -Depth 30
    }

    It 'is explicitly synthetic and carries the Apache license marker' {
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
        $script:Fixture.spdxLicenseIdentifier | Should -Be 'Apache-2.0'
    }

    It 'uses the continuing fictional organization' {
        $script:Fixture.organization | Should -Be 'Kestrel Vale Health Services'
    }

    It 'contains the intended denominator and observation quality cases' {
        @($script:Fixture.scopeRegister | Where-Object included).Count | Should -Be 8
        @($script:Fixture.scopeRegister | Where-Object { -not $_.included }).Count | Should -Be 1
        $script:Fixture.observedAssets.Count | Should -Be 9
        @($script:Fixture.observedAssets | Group-Object assetId | Where-Object Count -GT 1).Count | Should -Be 1
    }

    It 'contains no credential-shaped property names' {
        $script:FixtureText | Should -Not -Match '(?i)"(?:secret|password|token|authorization|api.?key)"\s*:'
    }

    It 'contains no Unicode U+2014 character' {
        $script:FixtureText.Contains([char]0x2014) | Should -BeFalse
    }
}
