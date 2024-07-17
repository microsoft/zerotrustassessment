$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch{$false}) }
    ).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe class2 {
        Context 'Type creation' {
            It 'Has created a type named class2' {
                'class2' -as [Type] | Should -BeOfType [Type]
            }
        }

        Context 'Constructors' {
            It 'Has a default constructor' {
                $instance = [class2]::new()
                $instance | Should -Not -BeNullOrEmpty
                $instance.GetType().Name | Should -Be 'class2'
            }
        }

        Context 'Methods' {
            BeforeEach {
                $instance = [class2]::new()
            }

            It 'Overrides the ToString method' {
                # Typo "calss" is inherited from definition. Preserved here as validation is demonstrative.
                $instance.ToString() | Should -Be 'This calss is class2'
            }
        }

        Context 'Properties' {
            BeforeEach {
                $instance = [class2]::new()
            }

            It 'Has a Name property' {
                $instance.Name | Should -Be 'Class2'
            }
        }
    }
}
