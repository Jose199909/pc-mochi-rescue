$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = [System.Windows.Forms.Form]@{
    Text = 'PC Mochi Rescue 0.3'
    StartPosition = 'CenterScreen'
    ClientSize = [System.Drawing.Size]::new(900, 580)
    MinimumSize = [System.Drawing.Size]::new(780, 490)
    Font = [System.Drawing.Font]::new('Segoe UI', 10)
}

$layout = [System.Windows.Forms.TableLayoutPanel]@{
    Dock = 'Fill'
    ColumnCount = 1
    RowCount = 5
    Padding = [System.Windows.Forms.Padding]::new(16)
}
[void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 38))
[void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 43))
[void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 43))
[void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
[void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 34))
$form.Controls.Add($layout)

$title = [System.Windows.Forms.Label]@{
    Text = 'PC Mochi Rescue 0.3'
    Font = [System.Drawing.Font]::new('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
    Dock = 'Fill'
}
$layout.Controls.Add($title, 0, 0)

$profileRow = [System.Windows.Forms.FlowLayoutPanel]@{ Dock = 'Fill'; WrapContents = $false }
$profileLabel = [System.Windows.Forms.Label]@{ Text = 'Síntoma'; AutoSize = $true; Margin = [System.Windows.Forms.Padding]::new(0, 7, 4, 0) }
$profiles = [ordered]@{ 'Revisión general' = 'General'; 'PC lento' = 'Rendimiento'; 'Se reinicia' = 'Reinicios'; 'Sin Internet' = 'Internet' }
$profile = [System.Windows.Forms.ComboBox]@{ Width = 155; DropDownStyle = 'DropDownList' }
$profile.Items.AddRange(@($profiles.Keys))
$profile.SelectedIndex = 0
$timeLabel = [System.Windows.Forms.Label]@{ Text = 'Hora aprox. del reinicio (opcional)'; AutoSize = $true; Visible = $false; Margin = [System.Windows.Forms.Padding]::new(10, 7, 4, 0) }
$symptomTime = [System.Windows.Forms.DateTimePicker]@{ Width = 185; Format = 'Custom'; CustomFormat = 'dd/MM/yyyy HH:mm'; ShowCheckBox = $true; Checked = $false; Visible = $false }
$profileRow.Controls.AddRange(@($profileLabel, $profile, $timeLabel, $symptomTime))
$layout.Controls.Add($profileRow, 0, 1)
$profile.Add_SelectedIndexChanged({
    $showTime = $profiles[$profile.Text] -eq 'Reinicios'
    $timeLabel.Visible = $showTime
    $symptomTime.Visible = $showTime
})

$actions = [System.Windows.Forms.FlowLayoutPanel]@{ Dock = 'Fill'; WrapContents = $false }
$caseLabel = [System.Windows.Forms.Label]@{
    Text = 'Caso opcional'
    AutoSize = $true
    Margin = [System.Windows.Forms.Padding]::new(0, 9, 4, 0)
}
$caseInput = [System.Windows.Forms.TextBox]@{ Width = 135; MaxLength = 60 }
$scan = [System.Windows.Forms.Button]@{ Text = 'Analizar PC'; AutoSize = $true }
$cancel = [System.Windows.Forms.Button]@{ Text = 'Cancelar'; AutoSize = $true; Enabled = $false }
$copy = [System.Windows.Forms.Button]@{ Text = 'Copiar'; AutoSize = $true; Enabled = $false }
$save = [System.Windows.Forms.Button]@{ Text = 'Guardar informe'; AutoSize = $true; Enabled = $false }
$actions.Controls.AddRange(@($caseLabel, $caseInput, $scan, $cancel, $copy, $save))
$layout.Controls.Add($actions, 0, 2)

$output = [System.Windows.Forms.TextBox]@{
    Dock = 'Fill'
    Multiline = $true
    ReadOnly = $true
    ScrollBars = 'Vertical'
    BackColor = [System.Drawing.Color]::White
    Font = [System.Drawing.Font]::new('Consolas', 10)
    Text = 'Introduce un número de caso si lo necesitas y pulsa Analizar PC.'
}
$tabs = [System.Windows.Forms.TabControl]@{ Dock = 'Fill' }
$summaryTab = [System.Windows.Forms.TabPage]@{ Text = 'Resumen'; BackColor = [System.Drawing.Color]::White }
$summaryLayout = [System.Windows.Forms.TableLayoutPanel]@{ Dock = 'Fill'; RowCount = 2; ColumnCount = 1; Padding = [System.Windows.Forms.Padding]::new(12) }
[void]$summaryLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$summaryLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
$summaryHeader = [System.Windows.Forms.Label]@{ Text = 'Elige el síntoma y pulsa Analizar PC.'; AutoSize = $true; Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 10) }
$summaryScroll = [System.Windows.Forms.Panel]@{ Dock = 'Fill'; AutoScroll = $true }
$cards = [System.Windows.Forms.TableLayoutPanel]@{ Dock = 'Top'; AutoSize = $true; AutoSizeMode = 'GrowAndShrink'; ColumnCount = 1 }
[void]$cards.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new('Percent', 100))
$summaryScroll.Controls.Add($cards)
$summaryLayout.Controls.Add($summaryHeader, 0, 0)
$summaryLayout.Controls.Add($summaryScroll, 0, 1)
$summaryTab.Controls.Add($summaryLayout)

$diagnosticTab = [System.Windows.Forms.TabPage]@{ Text = 'Informe completo' }
$diagnosticTab.Controls.Add($output)
$assistantTab = [System.Windows.Forms.TabPage]@{ Text = 'IA local' }
$toolsTab = [System.Windows.Forms.TabPage]@{ Text = 'Herramientas' }
$tabs.TabPages.AddRange(@($summaryTab, $diagnosticTab, $assistantTab, $toolsTab))
$layout.Controls.Add($tabs, 0, 3)

$assistantLayout = [System.Windows.Forms.TableLayoutPanel]@{ Dock = 'Fill'; RowCount = 3; ColumnCount = 1; Padding = [System.Windows.Forms.Padding]::new(10) }
[void]$assistantLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 31))
[void]$assistantLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Absolute', 45))
[void]$assistantLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
$assistantTab.Controls.Add($assistantLayout)
$assistantLabel = [System.Windows.Forms.Label]@{ Text = 'Describe el síntoma. Mochi usa el último informe y responde en este equipo.'; Dock = 'Fill' }
$question = [System.Windows.Forms.TextBox]@{ MaxLength = 600; Dock = 'Fill' }
$ask = [System.Windows.Forms.Button]@{ Text = 'Consultar IA'; AutoSize = $true; Enabled = $false }
$questionRow = [System.Windows.Forms.TableLayoutPanel]@{ Dock = 'Fill'; RowCount = 1; ColumnCount = 2 }
[void]$questionRow.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new('Percent', 100))
[void]$questionRow.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new('AutoSize'))
$questionRow.Controls.Add($question, 0, 0)
$questionRow.Controls.Add($ask, 1, 0)
$answer = [System.Windows.Forms.TextBox]@{
    Text = 'Analiza el equipo primero. La IA ofrece sugerencias que el técnico puede validar.'
    Dock = 'Fill'; Multiline = $true; ReadOnly = $true; ScrollBars = 'Vertical'
}
$assistantLayout.Controls.Add($assistantLabel, 0, 0)
$assistantLayout.Controls.Add($questionRow, 0, 1)
$assistantLayout.Controls.Add($answer, 0, 2)

$toolLayout = [System.Windows.Forms.FlowLayoutPanel]@{
    Dock = 'Fill'; FlowDirection = 'TopDown'; WrapContents = $false; AutoScroll = $true
    Padding = [System.Windows.Forms.Padding]::new(12)
}
$toolsTab.Controls.Add($toolLayout)
$toolLayout.Controls.Add([System.Windows.Forms.Label]@{
    Text = 'Abre una herramienta de Windows para comprobar el hallazgo.'; AutoSize = $true
})
$systemFolder = [Environment]::SystemDirectory
$windowsTools = [ordered]@{
    'Administrador de tareas' = @{ File = Join-Path $systemFolder 'Taskmgr.exe' }
    'Administrador de dispositivos' = @{ File = Join-Path $systemFolder 'mmc.exe'; Arguments = 'devmgmt.msc' }
    'Visor de eventos' = @{ File = Join-Path $systemFolder 'mmc.exe'; Arguments = 'eventvwr.msc' }
    'Almacenamiento' = @{ File = 'ms-settings:storagesense' }
    'Windows Update' = @{ File = 'ms-settings:windowsupdate' }
    'Estado de red' = @{ File = 'ms-settings:network-status' }
}

$openWindowsTool = {
    param($sender, $eventArgs)
    try {
        $tool = $sender.Tag
        if ($tool.Arguments) { Start-Process -FilePath $tool.File -ArgumentList $tool.Arguments }
        else { Start-Process -FilePath $tool.File }
    } catch { $status.Text = 'Windows no pudo abrir esa herramienta.' }
}
foreach ($name in $windowsTools.Keys) {
    $button = [System.Windows.Forms.Button]@{ Text = $name; AutoSize = $true; Tag = $windowsTools[$name] }
    $button.Add_Click($openWindowsTool)
    $toolLayout.Controls.Add($button)
}
$flush = [System.Windows.Forms.Button]@{ Text = 'Vaciar caché DNS'; AutoSize = $true }
$toolLayout.Controls.Add($flush)
$status = [System.Windows.Forms.Label]@{
    Dock = 'Fill'
    TextAlign = 'MiddleLeft'
    Text = 'Listo. El análisis solo lee información del equipo.'
}
$layout.Controls.Add($status, 0, 4)

$timer = [System.Windows.Forms.Timer]@{ Interval = 200 }
$state = @{ Worker = $null; Pending = $null; Job = ''; Report = ''; Cancel = $null; Progress = $null }
$diagnosticPath = Join-Path $PSScriptRoot 'Diagnostico.ps1'
$assistantPath = Join-Path $PSScriptRoot 'Asistente.ps1'
$reportFolder = $PSScriptRoot

function Show-Findings($Result) {
    $cards.SuspendLayout()
    try {
        while ($cards.Controls.Count) { $cards.Controls[0].Dispose() }
        $summaryHeader.Text = 'Hallazgos prioritarios · consulta todos los detalles en Informe completo.'
        $findings = @($Result.Findings | Select-Object -First 3)
        if (!$findings.Count) {
            $summaryHeader.Text = 'El análisis no registró hallazgos prioritarios. Consulta el Informe completo.'
        }
        if ($Result.Unavailable) {
            $summaryHeader.Text += " Secciones sin comprobar: $($Result.Unavailable)."
        }
        foreach ($finding in $findings) {
            $card = [System.Windows.Forms.TableLayoutPanel]@{
                Dock = 'Top'; AutoSize = $true; AutoSizeMode = 'GrowAndShrink'; ColumnCount = 1
                BackColor = [System.Drawing.Color]::FromArgb(240, 245, 250)
                Padding = [System.Windows.Forms.Padding]::new(10)
                Margin = [System.Windows.Forms.Padding]::new(0, 0, 8, 8)
            }
            $prefix = if ($finding.Priority -eq 1) { 'Prioridad alta · ' } else { '' }
            $heading = [System.Windows.Forms.Label]@{
                AutoSize = $true; Text = $prefix + $finding.Title
                Font = [System.Drawing.Font]::new($form.Font, [System.Drawing.FontStyle]::Bold)
            }
            $evidence = [System.Windows.Forms.Label]@{ AutoSize = $true; Text = $finding.Evidence }
            $step = [System.Windows.Forms.Label]@{ AutoSize = $true; Text = $finding.NextStep }
            $card.Controls.AddRange(@($heading, $evidence, $step))
            if ($finding.Tool) {
                $open = [System.Windows.Forms.Button]@{ Text = "Abrir $($finding.Tool)"; AutoSize = $true; Tag = $windowsTools[$finding.Tool] }
                $open.Add_Click($openWindowsTool)
                $card.Controls.Add($open)
            }
            $cards.Controls.Add($card)
        }
    } finally {
        $cards.ResumeLayout()
    }
    Resize-Summary
}

function Resize-Summary {
    $summaryHeader.MaximumSize = [System.Drawing.Size]::new([Math]::Max(100, $summaryLayout.ClientSize.Width - 24), 0)
    $textWidth = [Math]::Max(100, $summaryScroll.ClientSize.Width - 55)
    foreach ($card in $cards.Controls) {
        foreach ($control in $card.Controls) {
            if ($control -is [System.Windows.Forms.Label]) {
                $control.MaximumSize = [System.Drawing.Size]::new($textWidth, 0)
            }
        }
    }
}
$summaryScroll.Add_SizeChanged({ Resize-Summary })

function Update-Controls {
    $idle = !$state.Worker
    $scan.Enabled = $idle
    $cancel.Enabled = !$idle -and !$state.Cancel.IsCancellationRequested
    $profile.Enabled = $idle
    $caseInput.Enabled = $idle
    $symptomTime.Enabled = $idle
    $flush.Enabled = $idle
    $copy.Enabled = $idle -and [bool]$state.Report
    $save.Enabled = $copy.Enabled
    $ask.Enabled = $copy.Enabled -and [bool]$question.Text.Trim()
}

function Start-MochiJob([string]$Job, [string]$Path, [hashtable]$Parameters) {
    try {
        $state.Job = $Job
        $state.Cancel = [System.Threading.CancellationTokenSource]::new()
        $Parameters.Cancelacion = $state.Cancel.Token
        $state.Worker = [powershell]::Create()
        [void]$state.Worker.AddCommand($Path).AddParameters($Parameters)
        $state.Pending = $state.Worker.BeginInvoke()
        Update-Controls
        $timer.Start()
    } catch {
        if ($state.Worker) { $state.Worker.Dispose(); $state.Worker = $null }
        if ($state.Cancel) { $state.Cancel.Dispose(); $state.Cancel = $null }
        $state.Progress = $null
        Update-Controls
        $status.Text = 'No se pudo iniciar la operación.'
    }
}

$scan.Add_Click({
    $symptom = $profiles[$profile.Text]
    $parameters = @{ Caso = $caseInput.Text; Sintoma = $symptom; Estructurado = $true }
    if ($symptom -eq 'Reinicios' -and $symptomTime.Checked) {
        if ($symptomTime.Value -gt (Get-Date)) {
            $status.Text = 'Indica una hora de reinicio que ya haya pasado.'
            return
        }
        $parameters.HoraSintoma = $symptomTime.Value
    }
    $tabs.SelectedTab = $summaryTab
    $state.Progress = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
    $parameters.Progreso = $state.Progress
    $status.Text = 'Analizando el equipo...'
    Start-MochiJob 'Scan' $diagnosticPath $parameters
})
$cancel.Add_Click({
    if (!$state.Worker) { return }
    $state.Cancel.Cancel()
    Update-Controls
    $status.Text = 'Cancelando. Si Windows está comprobando una sección, espera a que termine.'
})

$question.Add_TextChanged({ Update-Controls })
$ask.Add_Click({
    $answer.Text = 'Consultando el modelo local...'
    $status.Text = 'La IA puede tardar mientras carga el modelo desde la USB.'
    Start-MochiJob 'AI' $assistantPath @{ Pregunta = $question.Text.Trim(); Informe = $state.Report }
})

$timer.Add_Tick({
    if ($null -ne $state.Progress -and !$state.Cancel.IsCancellationRequested) {
        $phase = ''
        while ($state.Progress.TryDequeue([ref]$phase)) { $status.Text = "Revisando: $phase..." }
    }
    if (!$state.Pending.IsCompleted) { return }
    $timer.Stop()
    try {
        if ($state.Cancel.IsCancellationRequested) {
            if ($state.Job -eq 'AI') { $answer.Text = 'Consulta cancelada.' }
            $status.Text = 'Operación cancelada.'
            return
        }
        $result = $state.Worker.EndInvoke($state.Pending)
        if ($state.Worker.Streams.Error.Count) { throw $state.Worker.Streams.Error[0] }
        if (!$result.Count) { throw 'La operación no devolvió resultados.' }
        if ($state.Job -eq 'Scan') {
            $scanResult = $result[0]
            Show-Findings $scanResult
            $state.Report = $scanResult.Report
            $output.Text = $state.Report
            $answer.Text = 'Describe el síntoma para consultar la IA con el último informe.'
            $status.Text = 'Análisis terminado. Consulta el resumen y el informe completo.'
        } else {
            $answer.Text = ($result -join [Environment]::NewLine) -replace '\r?\n', [Environment]::NewLine
            $status.Text = 'Respuesta generada. Valida las sugerencias antes de aplicarlas.'
        }
    } catch {
        if ($state.Job -eq 'AI') {
            $workerError = $state.Worker.Streams.Error | Select-Object -First 1
            $detail = if ($workerError) { $workerError.Exception.Message } else { $_.Exception.Message }
            $answer.Text = ($detail -replace '^Exception calling "EndInvoke" with "1" argument\(s\): "(.*)"$', '$1')
        }
        $status.Text = 'La operación falló. Puedes volver a intentarla.'
    } finally {
        $state.Worker.Dispose()
        $state.Worker = $null
        $state.Pending = $null
        $state.Cancel.Dispose()
        $state.Cancel = $null
        $state.Progress = $null
        Update-Controls
    }
})

$flush.Add_Click({
    $choice = [System.Windows.Forms.MessageBox]::Show($form,
        'Se vaciará la caché de nombres DNS. Úsalo si estás revisando un problema de resolución de nombres. ¿Aplicar ahora?',
        'Confirmar vaciado de caché DNS', 'YesNo', 'Question', 'Button2')
    if ($choice -ne 'Yes') { return }
    try {
        $ipconfig = Join-Path $systemFolder 'ipconfig.exe'
        $run = Start-Process -FilePath $ipconfig -ArgumentList '/flushdns' -PassThru -Wait -WindowStyle Hidden
        if ($run.ExitCode -ne 0) { throw 'No se pudo vaciar la caché.' }
        $status.Text = 'Caché DNS vaciada.'
        if ($state.Report) {
            $state.Report += [Environment]::NewLine + ('Acción confirmada ({0:yyyy-MM-dd HH:mm}): se vació la caché DNS.' -f (Get-Date))
            $output.Text = $state.Report
        }
    } catch {
        $status.Text = 'Windows no pudo vaciar la caché DNS. Comprueba tus permisos.'
    }
})

$copy.Add_Click({
    try {
        [System.Windows.Forms.Clipboard]::SetText($output.Text)
        $status.Text = 'Informe copiado.'
    } catch {
        $status.Text = 'El portapapeles está ocupado. Intenta copiar de nuevo.'
    }
})

$save.Add_Click({
    $dialog = [System.Windows.Forms.SaveFileDialog]@{
        InitialDirectory = $reportFolder
        Filter = 'Informe de texto (*.txt)|*.txt'
        DefaultExt = 'txt'
        FileName = 'Mochi-{0:yyyyMMdd-HHmmss}.txt' -f (Get-Date)
    }
    try {
        if ($dialog.ShowDialog($form) -eq 'OK') {
            [System.IO.File]::WriteAllText($dialog.FileName, $output.Text, [System.Text.UTF8Encoding]::new($true))
            $status.Text = 'Informe guardado.'
        }
    } catch {
        $status.Text = 'No se pudo guardar el informe. Prueba otra carpeta.'
    } finally {
        $dialog.Dispose()
    }
})

$form.Add_FormClosing({ param($sender, $e) if ($state.Worker) { $e.Cancel = $true; $status.Text = 'Espera a que termine la operación o pulsa Cancelar.' } })
try {
    [void]$form.ShowDialog()
} finally {
    $timer.Stop()
    if ($state.Worker) { $state.Worker.Dispose() }
    $timer.Dispose()
    $form.Dispose()
}


