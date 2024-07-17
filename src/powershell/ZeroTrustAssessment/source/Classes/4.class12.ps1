class Class12 : Class1
{
    [string]$Name = 'Class12'

    Class12 ()
    {
    }

    [String] ToString()
    {
        return ( 'This calss is {0}:{1}' -f $this.Name,'class1')
    }
}
