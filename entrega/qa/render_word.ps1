$ErrorActionPreference='Stop'
Set-Location -LiteralPath 'D:\heezl\Documents\misjuegos\boing_game'
$word=New-Object -ComObject Word.Application
$word.Visible=$false
$word.DisplayAlerts=0
try {
 $file=Join-Path (Get-Location) 'entrega/Proyecto_Parcial_2_BOING_JuanPablo_GarciaHernandez.docx'
 $doc=$word.Documents.Open($file)
 $doc.Repaginate()
 Write-Output ('PAGES '+$doc.ComputeStatistics(2))
 $doc.Save()
 $pdf=[System.IO.Path]::ChangeExtension($file,'.pdf')
 $doc.ExportAsFixedFormat($pdf,17)
 $doc.Close(0)
 Write-Output $pdf
} finally {$word.Quit()}
