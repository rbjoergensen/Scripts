Function SQLQuery($ServerName, $DatabaseName, $Query)
{
    $IpAddress = [System.Net.Dns]::GetHostAddresses($ServerName)
    $FQDN = [System.Net.Dns]::GetHostEntry($IpAddress)
    invoke-command -ComputerName $FQDN.Hostname -ArgumentList $ServerName,$DatabaseName,$Query -ScriptBlock {
        $conn=New-Object System.Data.SqlClient.SQLConnection
        $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $args[0],$args[1],30
        $conn.ConnectionString=$ConnectionString
        $conn.Open()
        $cmd=New-Object system.Data.SqlClient.SqlCommand($args[2],$conn)
        $cmd.CommandTimeout=120
        $ds=New-Object system.Data.DataSet
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        [void]$da.fill($ds)
        $conn.Close()
        $ds.Tables
    }
}

$Query = SQLQuery "<serverName>" "<dbName>" "SELECT [something] FROM [Something].[dbo].[Something] order by Something"
$Query
