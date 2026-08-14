# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 4 synthetic HTTP exchange fixture' {
    BeforeAll {
        $root = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:FixturePath = Join-Path `
            -Path $root `
            -ChildPath 'tests/Fixtures/Synthetic/chapter-04-http-exchanges.json'
        $script:Fixture = Get-Content `
            -LiteralPath $script:FixturePath `
            -Raw `
            -Encoding utf8 |
            ConvertFrom-Json -Depth 100
    }

    It 'is explicitly synthetic and licensed' {
        $script:Fixture.dataClassification | Should -Be 'Synthetic'
        $script:Fixture.spdxLicenseIdentifier | Should -Be 'Apache-2.0'
        $script:Fixture.organization |
            Should -Be 'Kestrel Vale Health Services'
    }

    It 'contains six unique exchange identifiers' {
        $exchanges = @($script:Fixture.exchanges)
        $exchanges | Should -HaveCount 6
        @(
            $exchanges.exchangeId |
                Sort-Object -Unique
        ) | Should -HaveCount 6
    }

    It 'uses only the reserved invalid domain' {
        foreach ($exchange in $script:Fixture.exchanges) {
            ([Uri]$exchange.requestUri).Host |
                Should -Be 'tenant.example.invalid'
        }
    }

    It 'covers success, empty, rate, HTML, malformed JSON, and text cases' {
        @($script:Fixture.exchanges.statusCode) | Should -Contain 200
        @($script:Fixture.exchanges.statusCode) | Should -Contain 204
        @($script:Fixture.exchanges.statusCode) | Should -Contain 429
        @($script:Fixture.exchanges.statusCode) | Should -Contain 503
        @($script:Fixture.exchanges.responseContentType) |
            Should -Contain 'text/html'
        $script:Fixture.exchanges.responseBody |
            Should -Contain '{"data":['
    }

    It 'contains no bearer token or production account pattern' {
        $raw = Get-Content `
            -LiteralPath $script:FixturePath `
            -Raw `
            -Encoding utf8

        $raw | Should -Not -Match '(?i)bearer\s+[a-z0-9._-]+'
        $raw | Should -Not -Match '\b\d{12}\b'
        $raw | Should -Not -Match '\b(?:AKIA|ASIA)[0-9A-Z]{16}\b'
    }
}
