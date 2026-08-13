<!-- SPDX-FileCopyrightText: 2026 Paul Kell -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Chapter 3 Source Register

Chapter: **Objects, Pipelines, Logic, and Reusable Functions**

Access date: 2026-08-13

This chapter uses Microsoft PowerShell documentation and synthetic repository artifacts. It introduces no FortiCNAPP endpoint, request field, response property, permission, datasource, or LQL query.

## C3-S001: PowerShell objects

- Publisher: Microsoft
- Title: about_Objects
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_objects?view=powershell-7.6
- Supports: PowerShell data moves through commands as objects with types, properties, and methods.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: The project adopts a later PowerShell baseline.

## C3-S002: Object creation

- Publisher: Microsoft
- Title: about_Object_Creation
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_object_creation?view=powershell-7.6
- Supports: Custom objects can be created from ordered property definitions and used as predictable pipeline output.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Object-creation behavior changes materially.

## C3-S003: Arrays and collections

- Publisher: Microsoft
- Title: about_Arrays
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.6
- Supports: Arrays store collections, the array subexpression operator preserves zero-or-one results as a collection, and `Count` reports item count.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Collection semantics change materially.

## C3-S004: Pipelines

- Publisher: Microsoft
- Title: about_Pipelines
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.6
- Supports: PowerShell pipelines pass objects between commands rather than requiring display-text parsing.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Pipeline binding behavior changes materially.

## C3-S005: Object inspection

- Publisher: Microsoft
- Title: Get-Member
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-member?view=powershell-7.6
- Supports: `Get-Member` inspects object types, properties, and methods.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Command behavior changes materially.

## C3-S006: Property selection

- Publisher: Microsoft
- Title: Select-Object
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.6
- Supports: `Select-Object` selects objects or properties and can create calculated properties.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Command behavior changes materially.

## C3-S007: Object filtering

- Publisher: Microsoft
- Title: Where-Object
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.6
- Supports: `Where-Object` selects pipeline objects whose property tests evaluate as true.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Command behavior changes materially.

## C3-S008: Object sorting

- Publisher: Microsoft
- Title: Sort-Object
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.6
- Supports: `Sort-Object` orders objects by one or more property values.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Command behavior changes materially.

## C3-S009: Object grouping

- Publisher: Microsoft
- Title: Group-Object
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/group-object?view=powershell-7.6
- Supports: `Group-Object` groups objects that share a specified property value.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Command behavior changes materially.

## C3-S010: Conditional logic

- Publisher: Microsoft
- Title: about_If
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if?view=powershell-7.6
- Supports: `if`, `elseif`, and `else` run statement blocks according to boolean conditions.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Language behavior changes materially.

## C3-S011: Collection iteration

- Publisher: Microsoft
- Title: about_Foreach
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_foreach?view=powershell-7.6
- Supports: The `foreach` statement traverses items in a collection.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Language behavior changes materially.

## C3-S012: Functions

- Publisher: Microsoft
- Title: about_Functions
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7.6
- Supports: Named functions accept input and return output, including pipeline input through processing blocks.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Function behavior changes materially.

## C3-S013: Advanced functions

- Publisher: Microsoft
- Title: about_Functions_Advanced
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.6
- Supports: `[CmdletBinding()]` identifies script functions that follow cmdlet-style behavior.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Advanced-function behavior changes materially.

## C3-S014: Advanced parameters

- Publisher: Microsoft
- Title: about_Functions_Advanced_Parameters
- Version: PowerShell 7.6
- URL: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.6
- Supports: Parameter attributes define mandatory input, pipeline binding, and validation.
- Evidence class: `VERIFIED OFFICIAL`
- Revalidate when: Parameter binding or validation behavior changes materially.

## Source decision

Chapter 3 may use these language and cmdlet contracts as `VERIFIED OFFICIAL`. All security findings, accounts, resources, owners, dates, metrics, and outputs in the lab remain `SYNTHETIC`.

No tenant-verification item is closed by Chapter 3.
