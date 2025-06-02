<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database
    )

    # Maybe optimize in future to run tests in parallel, show better progress etc.
    # We could also run all the cmdlets in this folder that start with Test-
    # For now, just run all tests sequentially

    Test-InactiveAppDontHaveHighPrivGraphPerm -Database $Database
    Test-InactiveAppDontHaveHighPrivEntraRole -Database $Database
    Test-AppDontHaveSecrets -Database $Database
    Test-AppDontHaveCertsWithLongExpiry -Database $Database
    ## Test-PrivilegedUsersSignInPhishResistant (Blocked by lack of sign in log filter)
    Test-PrivilegedUsersCaAuthStrengthPhishResistant
    Test-PrivilegedUsersPhishResistantMethodRegistered -Database $Database
    Test-UsersPhishResistantMethodRegistered -Database $Database
    Test-GuestCantInviteGuests
    Test-GuestHaveRestrictedAccess
    Test-BlockLegacyAuthCaPolicy
    Test-CreatingNewAppsRestrictedToPrivilegedUsers
    ## Test-GuestStrongAuthMethod # Not implemented - Blocked by lack of sign in log filter
    Test-DiagnosticSettingsConfiguredEntraLogs
    Test-HighPriorityEntraRecommendationsAddressed

    Test-Assessment-21795
    Test-Assessment-21797
    Test-Assessment-21800
    Test-Assessment-21808
    Test-Assessment-21815 -Database $Database
    Test-Assessment-21829
    Test-Assessment-21861
    Test-Assessment-21863
    Test-Assessment-21864
    Test-Assessment-21866
    Test-Assessment-21872
    Test-Assessment-21774 -Database $Database
    Test-Assessment-21775
    Test-Assessment-21776
    Test-Assessment-21777 -Database $Database
    Test-Assessment-21778
    Test-Assessment-21779
    Test-Assessment-21780
    Test-Assessment-21784
    Test-Assessment-21786
    Test-Assessment-21787
    Test-Assessment-21788
    Test-Assessment-21789
    Test-Assessment-21790
    Test-Assessment-21793
    Test-Assessment-21798
    Test-Assessment-21799
    Test-Assessment-21802
    Test-Assessment-21803
    Test-Assessment-21804
    Test-Assessment-21806
    Test-Assessment-21809
    Test-Assessment-21810
    Test-Assessment-21811
    Test-Assessment-21812
    Test-Assessment-21813
    Test-Assessment-21816
    Test-Assessment-21817
    Test-Assessment-21818
    Test-Assessment-21819
    Test-Assessment-21820
    Test-Assessment-21821
    Test-Assessment-21822
    Test-Assessment-21823
    Test-Assessment-21824
    Test-Assessment-21825
    Test-Assessment-21828
    Test-Assessment-21830
    Test-Assessment-21831
    Test-Assessment-21832
    Test-Assessment-21833
    Test-Assessment-21834
    Test-Assessment-21835
    Test-Assessment-21836
    Test-Assessment-21837
    Test-Assessment-21838
    Test-Assessment-21839
    Test-Assessment-21840
    Test-Assessment-21841
    Test-Assessment-21842
    Test-Assessment-21843
    Test-Assessment-21844
    Test-Assessment-21845
    Test-Assessment-21846
    Test-Assessment-21847
    Test-Assessment-21848
    Test-Assessment-21849
    Test-Assessment-21850
    Test-Assessment-21854
    Test-Assessment-21855
    Test-Assessment-21857
    Test-Assessment-21858
    Test-Assessment-21859
    Test-Assessment-21862
    Test-Assessment-21865
    Test-Assessment-21867
    Test-Assessment-21868
    Test-Assessment-21869
    Test-Assessment-21870
    Test-Assessment-21874
    Test-Assessment-21875
    Test-Assessment-21876
    Test-Assessment-21877
    Test-Assessment-21878
    Test-Assessment-21879
    Test-Assessment-21881
    Test-Assessment-21882
    Test-Assessment-21883
    Test-Assessment-21884
    Test-Assessment-21885 -Database $Database
    Test-Assessment-21886
    Test-Assessment-21887
    Test-Assessment-21888 -Database $Database
    Test-Assessment-21889
    Test-Assessment-21890
    Test-Assessment-21891
    Test-Assessment-21892
    Test-Assessment-21893
    Test-Assessment-21894
    Test-Assessment-21895
    Test-Assessment-21896
    Test-Assessment-21897
    Test-Assessment-21898
    Test-Assessment-21899
    Test-Assessment-21912
    Test-Assessment-21929
    Test-Assessment-21941
    Test-Assessment-21953
    Test-Assessment-21954
    Test-Assessment-21955
    Test-Assessment-21964
    Test-Assessment-21983
    Test-Assessment-21984
    Test-Assessment-21985
    Test-Assessment-21992 -Database $Database
    Test-Assessment-22072
    Test-Assessment-22098
    Test-Assessment-22099
    Test-Assessment-22100
    Test-Assessment-22101
    Test-Assessment-22102
    Test-Assessment-22128 -Database $Database
    Test-Assessment-22659
    Test-Assessment-23183 -Database $Database
}
