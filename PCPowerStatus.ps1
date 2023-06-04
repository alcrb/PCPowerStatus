Import-Module ActiveDirectory
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

function Send-WOL
{

[CmdletBinding()]
param(
[Parameter(Mandatory=$True,Position=1)]
[string]$mac,
[string]$ip="255.255.255.255", 
[int]$port=7
)
$broadcast = [Net.IPAddress]::Parse($ip)

$mac=(($mac.replace(":","")).replace("-","")).replace(".","")
$target=0,2,4,6,8,10 | % {[convert]::ToByte($mac.substring($_,2),16)}
$packet = (,[byte]255 * 6) + ($target * 16)

$UDPclient = new-Object System.Net.Sockets.UdpClient
$UDPclient.Connect($broadcast,$port)
[void]$UDPclient.Send($packet, 102)

}

Add-Type -AssemblyName System.Windows.Forms

$FormObject = [System.Windows.Forms.Form]
$LabelObject = [System.Windows.Forms.Label]
$ButtonObject = [System.Windows.Forms.Button]

$PCPowerStatusForm=New-Object $FormObject
$PCPowerStatusForm.clientSize='329,266'
$PCPowerStatusForm.Text='PC Power Status'
$PCPowerStatusForm.BackColor="#3778bf"

#Form icon
$Icon = New-Object system.drawing.icon ("Images/icon.ico")
$PCPowerStatusForm.Icon = $Icon

$objImage = [system.drawing.image]::FromFile("Images/background.png")
$PCPowerStatusForm.BackgroundImage = $objImage
$PCPowerStatusForm.BackgroundImageLayout = "None"

#Add Button
$btnPC=New-Object $ButtonObject
$btnPC.Text ="GO"
$btnPC.ForeColor ="white"
$btnPC.BackColor ="#3778bf"
$btnPC.Location=New-Object System.Drawing.Point(125,230)
$btnPC.add_Click($handler_btnPC_Click)
$PCPowerStatusForm.Controls.Add($btnPC)

#Label
$objLabel = New-Object System.Windows.Forms.label
$objLabel.Location = New-Object System.Drawing.Size(20,120)
$objLabel.Size = New-Object System.Drawing.Size(130,15)
$objLabel.BackColor = "Transparent"
$objLabel.ForeColor = "white"
$objLabel.Text = "Nom du PC:"
$PCPowerStatusForm.Controls.Add($objLabel)

#Label2
$objLabel2 = New-Object System.Windows.Forms.label
$objLabel2.Location = New-Object System.Drawing.Size(180,120)
$objLabel2.Size = New-Object System.Drawing.Size(130,15)
$objLabel2.BackColor = "Transparent"
$objLabel2.ForeColor = "white"
$objLabel2.Text = "Wake on Lan (WoL):"
$PCPowerStatusForm.Controls.Add($objLabel2)

#Label3
$objLabel3 = New-Object System.Windows.Forms.label
$objLabel3.Location = New-Object System.Drawing.Size(180,145)
$objLabel3.Size = New-Object System.Drawing.Size(35,15)
$objLabel3.BackColor = "Transparent"
$objLabel3.ForeColor = "white"
$objLabel3.Text = "MAC:"
$PCPowerStatusForm.Controls.Add($objLabel3)

#Label4
$objLabel4 = New-Object System.Windows.Forms.label
$objLabel4.Location = New-Object System.Drawing.Size(180,182)
$objLabel4.Size = New-Object System.Drawing.Size(30,15)
$objLabel4.BackColor = "Transparent"
$objLabel4.ForeColor = "white"
$objLabel4.Text = "IP:"
$PCPowerStatusForm.Controls.Add($objLabel4)

#Add textBox 1 (Nom du PC)
$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = '20,140'
$textBox1.Size = '90,20'
$textBox1.ForeColor ="black"
$PCPowerStatusForm.Controls.Add($textBox1)

#Add textBox 2 (Adresse MAC)
$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = '220,140'
$textBox2.Size = '90,20'
$textBox2.ForeColor ="black"
$PCPowerStatusForm.Controls.Add($textBox2)

#Add textBox 3 (Adresse IP)
$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = '220,177'
$textBox3.Size = '90,20'
$textBox3.ForeColor ="black"
$PCPowerStatusForm.Controls.Add($textBox3)

#Add Checkbox 1
$checkBox1 = New-Object System.Windows.Forms.RadioButton
$checkBox1.Location = '180,200'
$checkBox1.Size = '90,20'
$checkBox1.Checked = $false
$checkBox1.Text = "WoL"
$checkBox1.ForeColor ="white"
$checkBox1.BackColor ="Transparent"
$PCPowerStatusForm.Controls.Add($checkBox1)

#Add Checkbox 2
$checkBox2 = New-Object System.Windows.Forms.RadioButton
$checkBox2.Location = '20,177'
$checkBox2.Size = '90,20'
$checkBox2.Checked = $false
$checkBox2.Text = "Eteindre"
$checkBox2.ForeColor ="white"
$checkBox2.BackColor ="Transparent"
$PCPowerStatusForm.Controls.Add($checkBox2)

#Add Checkbox 3
$checkBox3 = New-Object System.Windows.Forms.RadioButton
$checkBox3.Location = '20,200'
$checkBox3.Size = '90,20'
$checkBox3.Checked = $false
$checkBox3.Text = "Redemarrer"
$checkBox3.ForeColor ="white"
$checkBox3.BackColor ="Transparent"
$PCPowerStatusForm.Controls.Add($checkBox3)



#Add Button Event
$btnPC.Add_Click(
    {
    $IPAddress = $textBox1.Text
    $MacAddress = $textBox2.Text

         if ($checkBox2.checked)
         {
             Shutdown -s -t 0 -m \\$IPAddress
         }
   
         elseif ($checkbox1.checked)
         {
             Send-WOL \\$MacAddress
         }

         elseif($checkbox3.checked)
         {
             Shutdown -r -t 0 -m \\$IPAddress 
         }

         $PCPowerStatusForm.Close()
    }
)

#Save the initial state of the form
$InitialFormWindowState = $PCPowerStatusForm.WindowState
#Init the OnLoad event to correct the initial state of the form
$PCPowerStatusForm.add_Load($OnLoadForm_StateCorrection)

#Show the Form
$PCPowerStatusForm.ShowDialog()| Out-Null


$PCPowerStatusForm.Controls.AddRange(@($btnPC,$objLabel,$objLabel2,$objLabel3,$objLabel4,$textBox1,$textBox2,$textBox3,$checkBox1,$checkBox2,$checkBox3))

#Display the form
#$PCPowerStatusForm.ShowDialog()

#Cleans up the form
$PCPowerStatusForm.Dispose()