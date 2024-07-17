class Class1
{
    [string]$Name = 'Class1'

    Class1()
    {
        #default Constructor
    }

    [String] ToString()
    {
        # Typo "calss" is intentional
        return ( 'This calss is {0}' -f $this.Name)
    }
}
