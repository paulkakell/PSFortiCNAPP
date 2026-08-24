# SPDX-FileCopyrightText: 2026 Paul Kell
# SPDX-License-Identifier: Apache-2.0

Describe 'Chapter 6 synthetic request-plan example' {
    BeforeAll {
        $root = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../..')).Path
        $script:path = Join-Path $root 'examples/chapter-06/Review-SyntheticRequestPlan.ps1'
        $script:result = & $script:path
    }

    It 'returns the expected typed summary' {
        $script:result.PSObject.TypeNames[0] | Should -Be 'PSFortiCNAPP.SyntheticRequestPlanSummary'
        $script:result.ScenarioCount | Should -Be 5
        $script:result.SuccessScenarioCount | Should -Be 4
        $script:result.ErrorScenarioCount | Should -Be 1
        $script:result.RetryScenarioCount | Should -Be 2
        $script:result.NetworkRequestCount | Should -Be 0
    }
}
