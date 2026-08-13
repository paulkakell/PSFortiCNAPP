# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 2 settings template contract' {
    BeforeAll {
        $script:RepositoryRoot = (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '../..'
            )
        ).Path
        $script:TemplatePath = Join-Path `
            -Path $script:RepositoryRoot `
            -ChildPath 'examples/config/psforticnapp.settings.example.json'
        $script:Template = Get-Content `
            -LiteralPath $script:TemplatePath `
            -Raw `
            -Encoding utf8 |
            ConvertFrom-Json -Depth 20
    }

    It 'has project metadata' {
        $script:Template.spdxFileCopyrightText | Should -Be '2026 Paul Kell'
        $script:Template.spdxLicenseIdentifier | Should -Be 'Apache-2.0'
        $script:Template.schemaVersion | Should -Be '1.0'
    }

    It 'is explicitly synthetic' {
        $script:Template.dataClassification | Should -Be 'SyntheticTemplate'
    }

    It 'uses relative workspace directory names' {
        $script:Template.workspace.evidenceDirectory | Should -Be 'evidence'
        $script:Template.workspace.logDirectory | Should -Be 'logs'
        $script:Template.workspace.temporaryDirectory | Should -Be 'tmp'
    }

    It 'does not claim a configured connection' {
        $script:Template.authentication.source | Should -Be 'NotConfigured'
        $script:Template.authentication.sensitiveValuesIncluded | Should -BeFalse
    }

    It 'uses UTC and object output defaults' {
        $script:Template.reporting.timeZone | Should -Be 'UTC'
        $script:Template.reporting.defaultFormat | Should -Be 'Object'
    }
}
