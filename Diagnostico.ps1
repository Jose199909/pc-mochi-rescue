param(
    [string]$Caso = '',
    [ValidateSet('General', 'Rendimiento', 'Reinicios', 'Internet')][string]$Sintoma = 'General',
    [Nullable[datetime]]$HoraSintoma,
    [switch]$Estructurado,
    [System.Collections.Concurrent.ConcurrentQueue[string]]$Progreso,
    [System.Threading.CancellationToken]$Cancelacion = [System.Threading.CancellationToken]::None
)

$ErrorActionPreference = 'Stop'
$findings = [System.Collections.Generic.List[object]]::new()
$report = [System.Collections.Generic.List[string]]::new()
function Add-Line([string]$Text = '') { $report.Add($Text) }

function Add-Finding(
    [int]$Priority, [string]$Category, [string]$Title, [string]$Evidence,
    [string]$NextStep, [string]$Tool
) {
    $findings.Add([pscustomobject]@{
        Priority = $Priority
        Category = $Category
        Title = $Title
        Evidence = $Evidence
        NextStep = $NextStep
        Tool = $Tool
    })
}

function Add-Section([string]$Title, [scriptblock]$Collect) {
    $Cancelacion.ThrowIfCancellationRequested()
    if ($null -ne $Progreso) { $Progreso.Enqueue($Title) }
    Add-Line
    Add-Line ('=== {0} ===' -f $Title)
    try {
        $lines = @(& $Collect)
        foreach ($line in $lines) { Add-Line ([string]$line) }
    } catch {
        Add-Line 'Sección no disponible. Windows no devolvió los datos o denegó el acceso.'
        Add-Finding 4 General "No se pudo comprobar: $Title" 'Windows no devolvió los datos o denegó el acceso.' 'Comprueba esta sección manualmente si está relacionada con el síntoma.'
    }
}

Add-Line 'PC MOCHI RESCUE | Informe técnico de solo lectura'
Add-Line ('Fecha local: {0:yyyy-MM-dd HH:mm zzz}' -f (Get-Date))
if ($Caso.Trim()) { Add-Line ('Caso: ' + $Caso.Trim()) }
$symptomLabels = @{ General = 'Revisión general'; Rendimiento = 'PC lento'; Reinicios = 'Se reinicia'; Internet = 'Sin Internet' }
Add-Line ('Síntoma: ' + $symptomLabels[$Sintoma])

Add-Section 'Windows y memoria' {
    $os = Get-CimInstance Win32_OperatingSystem -Property Caption,Version,BuildNumber,LastBootUpTime,TotalVisibleMemorySize,FreePhysicalMemory
    '{0} | Versión {1} | Compilación {2}' -f $os.Caption, $os.Version, $os.BuildNumber
    if ($os.TotalVisibleMemorySize -gt 0 -and $os.FreePhysicalMemory / $os.TotalVisibleMemorySize -lt 0.1) {
        $memory = 'RAM libre: {0:N1} de {1:N1} GiB al momento del análisis.' -f ($os.FreePhysicalMemory / 1MB), ($os.TotalVisibleMemorySize / 1MB)
        Add-Finding 2 Rendimiento 'Poca memoria disponible' $memory 'Revisa qué procesos consumen más memoria mientras ocurre el síntoma.' 'Administrador de tareas'
    }
    'Último arranque: {0:yyyy-MM-dd HH:mm}' -f $os.LastBootUpTime
    'RAM disponible en este momento: {0:N1} de {1:N1} GiB' -f ($os.FreePhysicalMemory / 1MB), ($os.TotalVisibleMemorySize / 1MB)
}

Add-Section 'Espacio en discos locales' {
    $disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType = 3' -Property DeviceID,Size,FreeSpace)
    if (!$disks.Count) { 'Windows no enumeró unidades locales.' }
    foreach ($disk in $disks) {
        if ($disk.Size -gt 0 -and $null -ne $disk.FreeSpace) {
            $free = 100 * $disk.FreeSpace / $disk.Size
            if ($free -lt 10) {
                $space = '{0:N1} GiB libres ({1:N1} %).' -f ($disk.FreeSpace / 1GB), $free
                Add-Finding 2 Rendimiento "Poco espacio en $($disk.DeviceID)" $space 'Revisa las categorías más grandes con el cliente antes de borrar o mover archivos.' 'Almacenamiento'
            }
            $note = if ($free -lt 10) { ' | Revisar espacio (menos del 10 % libre)' } else { '' }
            '{0}  {1:N1} de {2:N1} GiB libres ({3:N1} %){4}' -f $disk.DeviceID, ($disk.FreeSpace / 1GB), ($disk.Size / 1GB), $free, $note
        } else {
            '{0}  Espacio no disponible.' -f $disk.DeviceID
        }
    }
}

Add-Section 'Programas de inicio detectados' {
    $startup = @(Get-CimInstance Win32_StartupCommand -Property Name |
        Where-Object { $_.Name } | Select-Object -ExpandProperty Name | Sort-Object -Unique)
    if (!$startup.Count) { 'Windows no devolvió entradas de inicio en esta consulta.' }
    if ($startup.Count -and $Sintoma -eq 'Rendimiento') {
        Add-Finding 3 Rendimiento 'Aplicaciones de inicio' "Windows enumeró $($startup.Count) nombres de programas de inicio." 'Si la lentitud ocurre al encender, compara su impacto en Aplicaciones de inicio.' 'Administrador de tareas'
    }
    foreach ($entry in $startup) { '- ' + $entry }
    'Esta lista no mide el impacto de cada programa en el arranque.'
}

Add-Section 'Dispositivos con errores reportados por Windows' {
    $devices = @(Get-CimInstance Win32_PnPEntity -Filter 'ConfigManagerErrorCode > 0' -Property Name,ConfigManagerErrorCode)
    if (!$devices.Count) { 'No se detectaron dispositivos con códigos de error en esta consulta.' }
    foreach ($device in ($devices | Sort-Object Name)) {
        if ($device.ConfigManagerErrorCode -ne 22) {
            Add-Finding 2 General 'Windows reporta un problema de dispositivo' "$($device.Name) · Código $($device.ConfigManagerErrorCode)" 'Abre las propiedades del dispositivo y confirma el código.' 'Administrador de dispositivos'
        }
        $note = if ($device.ConfigManagerErrorCode -eq 22) { ' (deshabilitado)' } else { '' }
        '- {0} | Código {1}{2}' -f $device.Name, $device.ConfigManagerErrorCode, $note
    }
}

$eventFilter = @{ LogName = 'System'; Level = 1, 2; StartTime = (Get-Date).AddDays(-7) }
$eventTitle = 'Eventos críticos y de error del sistema (últimos 7 días)'
if ($Sintoma -eq 'Reinicios' -and $null -ne $HoraSintoma) {
    $eventFilter.StartTime = $HoraSintoma.AddMinutes(-30)
    $eventFilter.EndTime = $HoraSintoma.AddMinutes(30)
    $eventTitle = 'Eventos del sistema cerca del reinicio indicado'
}
Add-Section $eventTitle {
    if ($eventFilter.ContainsKey('EndTime')) {
        'Intervalo consultado: {0:dd/MM/yyyy HH:mm} a {1:dd/MM/yyyy HH:mm} (hora local).' -f $eventFilter.StartTime, $eventFilter.EndTime
    }
    $events = @()
    try {
        $events = @(Get-WinEvent -FilterHashtable $eventFilter -MaxEvents 50)
    } catch {
        if ($_.FullyQualifiedErrorId -notlike 'NoMatchingEventsFound*') { throw }
    }
    if (!$events.Count) {
        'No se encontraron eventos de estos niveles durante el período.'
    } else {
        'Se muestran los grupos de los últimos {0} eventos encontrados (máximo 50).' -f $events.Count
        foreach ($group in ($events | Group-Object -Property ProviderName,Id | Sort-Object Count -Descending)) {
            $latest = $group.Group[0]
            '- {0} | ID {1} | {2} registro(s) | Último: {3:yyyy-MM-dd HH:mm}' -f $latest.ProviderName, $latest.Id, $group.Count, $latest.TimeCreated
        }
        $latestEvent = $events[0]
        $evidence = 'Evento más reciente de la consulta: {0} · ID {1} · {2:dd/MM HH:mm}.' -f $latestEvent.ProviderName, $latestEvent.Id, $latestEvent.TimeCreated
        Add-Finding 3 Reinicios 'Eventos del sistema para revisar' $evidence 'Compara las horas con el síntoma. Un evento por sí solo no identifica la causa.' 'Visor de eventos'
        'Los eventos son pistas de diagnóstico. Por sí solos no identifican la causa.'
    }
}

Add-Line
Add-Section 'Estado informado por discos físicos' {
    $physical = @(Get-PhysicalDisk)
    if (!$physical.Count) { 'El proveedor de almacenamiento no devolvió discos físicos.' }
    foreach ($disk in $physical) {
        $health = [string]$disk.HealthStatus
        if ($health -in 'Warning', 'Unhealthy') {
            Add-Finding 1 General 'Disco físico con alerta' "$($disk.FriendlyName) · Estado informado: $health." 'Verifica el respaldo del cliente y confirma el estado con la herramienta del fabricante antes de reparar.' 'Almacenamiento'
        }
        '- {0} | Estado: {1} | Operación: {2}' -f $disk.FriendlyName, $health, ($disk.OperationalStatus -join ', ')
    }
    'Un estado saludable no descarta fallas. Algunas unidades no exponen información completa.'
}

Add-Section 'Reinicio pendiente' {
    $update = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    $servicing = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    if ($update -or $servicing) {
        'Windows registra un reinicio pendiente por actualizaciones o mantenimiento.'
        Add-Finding 3 General 'Windows tiene un reinicio pendiente' 'Windows Update o el mantenimiento de Windows registró un reinicio pendiente.' 'Guarda el trabajo del cliente y acuerda cuándo reiniciar si Windows lo solicita.' 'Windows Update'
    } else {
        'Sin indicadores de reinicio en Windows Update y Component Based Servicing.'
    }
}

if ($Sintoma -eq 'Internet') {
    Add-Section 'Configuración básica de red' {
        $adapters = @(Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = TRUE' -Property DefaultIPGateway,DNSServerSearchOrder)
        $withGateway = @($adapters | Where-Object { $_.DefaultIPGateway }).Count
        $withDns = @($adapters | Where-Object { $_.DNSServerSearchOrder }).Count
        $evidence = 'Adaptadores con IP habilitada: {0}. Con puerta de enlace: {1}. Con servidores DNS: {2}.' -f $adapters.Count, $withGateway, $withDns
        $evidence
        'Esta consulta no contacta a Internet ni comprueba si hay acceso.'
        Add-Finding 3 Internet 'Configuración de red para revisar' $evidence 'Comprueba el estado de Wi-Fi o Ethernet y verifica si otros equipos de la misma red tienen el mismo problema.' 'Estado de red'
    }
}

$ordered = @($findings | Sort-Object @{ Expression = { $_.Priority -ne 1 } },
    @{ Expression = { $_.Category -ne $Sintoma -or $Sintoma -eq 'General' -or $_.Priority -eq 4 } },
    @{ Expression = { $_.Priority } })
Add-Section 'Plan de revisión' {
    if (!$ordered.Count) { 'Registra el síntoma, intenta reproducirlo y vuelve a analizar el equipo mientras ocurre.' }
    $number = 0
    foreach ($finding in $ordered) {
        $label = if ($finding.Priority -eq 1) { 'Prioridad alta · ' } else { '' }
        '{0}. {1}{2}. {3} {4}' -f (++$number), $label, $finding.Title, $finding.Evidence, $finding.NextStep
    }
}

Add-Line 'Revisa el informe antes de compartirlo. Puede incluir nombres de software y dispositivos.'
$Cancelacion.ThrowIfCancellationRequested()
$reportText = $report -join [Environment]::NewLine
if ($Estructurado) {
    [pscustomobject]@{
        Report = $reportText
        Findings = $ordered
        Unavailable = @($ordered | Where-Object { $_.Priority -eq 4 }).Count
    }
} else {
    $reportText
}



