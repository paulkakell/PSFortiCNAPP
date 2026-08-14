# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 5 synthetic authentication fixture' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:FixturePath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'tests/Fixtures/Synthetic/chapter-05-authentication-profiles.json'
        $script:Fixture = Get-Content `
            -LiteralPath $script:FixturePath `
            -Raw `
            -Encoding utf8 |
            ConvertFrom-Json -Depth 20
    }

    It 'is explicitly synthetic and licensed' {
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
        $script:Fixture.spdxLicenseIdentifier | Should -Be 'Apache-2.0'
        $script:Fixture.organization |
            Should -Be 'Kestrel Vale Health Services'
    }

    It 'contains five unique profiles' {
        $profiles = @($script:Fixture.profiles)
        $profileIds = @($profiles.profileId)

        $profiles | Should -HaveCount 5
        @($profileIds | Sort-Object -Unique) |
            Should -HaveCount 5
    }

    It 'contains two valid and three invalid expectations' {
        @($script:Fixture.profiles | Where-Object expectedValid) |
            Should -HaveCount 2
        @($script:Fixture.profiles | Where-Object { -not $_.expectedValid }) |
            Should -HaveCount 3
    }

    It 'uses only HTTPS for profiles expected to be valid' {
        foreach ($profile in $script:Fixture.profiles | Where-Object expectedValid) {
            $profile.baseUri | Should -Match '^https://'
            $profile.tokenEndpoint | Should -Match '^https://'
        }
    }

    It 'contains no secret or bearer-token values' {
        $raw = Get-Content `
            -LiteralPath $script:FixturePath `
            -Raw `
            -Encoding utf8

        $raw | Should -Not -Match '(?i)"(?:secret|password|accessToken|bearerToken)"\s*:'
        $raw | Should -Not -Match '(?i)authorization\s*:'
        $raw | Should -Not -Match '-----BEGIN .*PRIVATE KEY-----'
    }
}
