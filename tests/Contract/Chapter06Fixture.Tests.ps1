# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 6 synthetic request-plan fixture' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $path = Join-Path $root 'tests/Fixtures/Synthetic/chapter-06-api-client.json'
        $script:fixture = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -Depth 20
        $script:text = Get-Content -LiteralPath $path -Raw
    }

    It 'is explicitly synthetic and contains five scenarios' {
        $script:fixture.dataClassification | Should -Be 'Synthetic'
        @($script:fixture.requestPlan) | Should -HaveCount 5
    }

    It 'covers success retry forbidden and pagination planning' {
        $names = @($script:fixture.requestPlan.scenario)
        $names | Should -Contain 'success'
        $names | Should -Contain 'rate-limit-then-success'
        $names | Should -Contain 'service-unavailable-then-success'
        $names | Should -Contain 'forbidden'
        $names | Should -Contain 'two-pages'
    }

    It 'contains no common credential-shaped material' {
        $script:text | Should -Not -Match '(?i)bearer\s+[A-Za-z0-9._-]{16,}|BEGIN PRIVATE KEY|api.?secret'
    }
}
