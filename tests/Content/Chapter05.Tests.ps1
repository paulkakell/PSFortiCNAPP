# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 5 public companion contract' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:Guide = Get-Content `
            -LiteralPath (Join-Path $script:RepositoryRoot 'docs/concepts/CHAPTER-05-AUTHENTICATION-SESSION-SAFETY.md') `
            -Raw `
            -Encoding utf8
        $script:Sources = Get-Content `
            -LiteralPath (Join-Path $script:RepositoryRoot 'docs/source-register/CHAPTER-05.md') `
            -Raw `
            -Encoding utf8
        $script:Notes = Get-Content `
            -LiteralPath (Join-Path $script:RepositoryRoot 'manuscript/chapters/05-AUTHENTICATION-SERVICE-USERS-AND-SESSION-SAFETY-PRODUCTION-NOTES.md') `
            -Raw `
            -Encoding utf8
    }

    It 'records ten source identifiers' {
        foreach ($number in 1..10) {
            $script:Sources |
                Should -Match ('C5-S{0:d3}' -f $number)
        }
    }

    It 'documents the verified token route and explicit expiry' {
        $script:Guide |
            Should -Match '/api/v2/access/tokens'
        $script:Guide |
            Should -Match 'expiryTime'
        $script:Sources |
            Should -Match 'POST /api/v2/access/tokens'
    }

    It 'preserves the tenant-dependent permission boundary' {
        $script:Guide | Should -Match 'VERIFY IN TENANT'
        $script:Notes |
            Should -Match 'Service-user availability and role names'
        $script:Notes |
            Should -Match 'FortiCloud authentication is not implemented'
    }

    It 'documents safe output and local-only disconnect' {
        $script:Guide |
            Should -Match 'module-private state'
        $script:Guide |
            Should -Match 'RemoteTokenRevoked = \$false'
        $script:Notes |
            Should -Match 'does not claim provider-side revocation'
    }

    It 'keeps the commercial manuscript outside the repository' {
        $script:Guide |
            Should -Match 'not the commercial chapter manuscript'
        $script:Notes |
            Should -Match 'complete commercial manuscript is maintained outside'
    }
}
