class Class2
{
    [string]$Name = 'Class2'

    Class2()
    {
        #default constructor
    }

    [String] ToString()
    {
        return ( 'This calss is {0}' -f $this.Name)
    }
}
