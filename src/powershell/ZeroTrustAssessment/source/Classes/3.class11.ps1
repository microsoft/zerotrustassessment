class Class11 : Class1
{
    [string]$Name = 'Class11'

    Class11 ()
    {
    }

    [String] ToString()
    {
        return ( 'This calss is {0}:{1}' -f $this.Name,'class1')
    }
}
