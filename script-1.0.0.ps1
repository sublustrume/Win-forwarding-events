				######################
				##Данные для скрипта##
				######################
				
$serverAddress = "wec.local.dom" #   Адрес Windows Event Collector. Необходим настройки для пересылки на WEC
$mp10collector = 'Администратор' #   Имя учетной записи для MP 10 Collector. ***
$refreshInterval = 600           # Интервал обновления подписки (в секундах)



$psversion =$PSVersionTable.PSVersion
Write-Host "Текущая версия PowerShell: $psversion"
$sendToWEC = Read-Host "Настройки для пересылки на WEC. Отправлять данные на $serverAddress? (Y/N)"
Write-Output "Настройка политики аудита..."
$message = "Выполняется установка политики: "
$errorOccurred = $false
$ErrorActionPreference = "Stop"
try {
	Write-Host "$message Проверка учетных данных"
	auditpol /set /subcategory:"{0CCE923F-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable 
	Write-Host "$message Другие события входа учетных записей"
	auditpol /set /subcategory:"{0CCE9241-69AE-11D9-BED3-505054503030}" /success:disable /failure:enable
	Write-Host "$message Управление группой приложений"
	auditpol /set /subcategory:"{0CCE9239-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Управление группой безопасности"
	auditpol /set /subcategory:"{0CCE9237-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Управление учетными записями"
	auditpol /set /subcategory:"{0CCE9235-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Создание процесса"
	auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Завершение процесса"
	auditpol /set /subcategory:"{0CCE922C-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Вход в систему"
	auditpol /set /subcategory:"{0CCE9215-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Выход из системы"
	auditpol /set /subcategory:"{0CCE9216-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Блокировка учетной записи"
	auditpol /set /subcategory:"{0CCE9217-69AE-11D9-BED3-505054503030}" /failure:enable
	Write-Host "$message Специальный вход"
	auditpol /set /subcategory:"{0CCE921B-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Другие события входа и выхода"
	auditpol /set /subcategory:"{0CCE921C-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Файловая система"
	auditpol /set /subcategory:"{0CCE921D-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Реестр"
	auditpol /set /subcategory:"{0CCE921E-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message SAM"
	auditpol /set /subcategory:"{0CCE9220-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Работа с дескриптором"
	auditpol /set /subcategory:"{0CCE9223-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Общий файловый ресурс"
	auditpol /set /subcategory:"{0CCE9224-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Другие события доступа к объекту"
	auditpol /set /subcategory:"{0CCE9227-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Сведения об общем файловом ресурсе"
	auditpol /set /subcategory:"{0CCE9244-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Съемные носители"
	auditpol /set /subcategory:"{0CCE9245-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Изменение политики проверки подлинности"
	auditpol /set /subcategory:"{0CCE9230-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Изменение политики авторизации"
	auditpol /set /subcategory:"{0CCE9231-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Изменение политики платформы фильтрации"
	auditpol /set /subcategory:"{0CCE9233-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
	Write-Host "$message Другие события изменения политики"
	auditpol /set /subcategory:"{0CCE9234-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Аудит изменения политики"
	auditpol /set /subcategory:"{0CCE922F-69AE-11D9-BED3-505054503030}" /success:enable
	Write-Host "$message Использование прав, не затрагивающее конфиденциальные данные"
	auditpol /set /subcategory:"{0CCE9229-69AE-11D9-BED3-505054503030}" /failure:enable
	Write-Host "$message Использование прав, затрагивающее конфиденциальные данные"
	auditpol /set /subcategory:"{0CCE9228-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable 
  }
catch {
    $errorOccurred = $true
}

if ($errorOccurred) {
    Write-Host "Настройка политики аудита завершилась с ошибкой(ами)." -ForegroundColor red
} else {
    Write-Host "Политика аудита настроена успешно!" -ForegroundColor green
}
$ErrorActionPreference = "Continue"

$winrmService = Get-Service -Name "WinRM" -ErrorAction SilentlyContinue

if ($winrmService -and $winrmService.Status -eq 'Stopped') {
    winrm quickconfig -q
    Write-Output "Служба WinRM была включена."
} elseif (-not $winrmService) {
    Write-Host "Служба WinRM не найдена на системе." -ForegroundColor red 
} else {
    Write-Output "Служба WinRM уже включена."
}

# 3. Включение правил межсетевого экрана для удаленного управления журналом событий
Write-Output "Включение правил межсетевого экрана..."
$firewallRuleName = "Windows Remote Management (HTTP-In)"
$remoteManagementPorts = 5985 # Порт для HTTP (WinRM)

$existingRule = Get-NetFirewallRule | Where-Object {
    ($_ | Get-NetFirewallPortFilter).LocalPort -eq $remoteManagementPorts
}


if ($existingRule) {
    Write-Output "Правило '$firewallRuleName' уже существует. Пропускаем создание."
} else {
    # Создаем правило для разрешения входящих подключений по WinRM (HTTP)
    New-NetFirewallRule -DisplayName $firewallRuleName `
                        -Direction Inbound `
                        -Action Allow `
                        -Protocol TCP `
                        -LocalPort $remoteManagementPorts `
                        -Profile Any

    Write-Host "Создано правило '$firewallRuleName' для разрешения входящих подключений на порт $remoteManagementPorts." -ForegroundColor green
}

if ($sendToWEC -match '^(Y|y)$') {
    Write-Output "Настройка политики для отправки событий на $serverAddress..."
	Write-Host "Настройка пересылки событий..."
	$eventLogPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"
	New-Item -Path $eventLogPolicyPath -Force | Out-Null
	$subscriptionManager = "Server=http://${serverAddress}:5985/wsman/SubscriptionManager/WEC,Refresh=$refreshInterval"
	Set-ItemProperty -Path $eventLogPolicyPath -Name "1" -Value $subscriptionManager
	wevtutil sl Security "/ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)"

	Write-Host "Настройка завершена. Обновление групповой политики..."
	gpupdate /force | Out-Null
	
} else {
    Write-Host "Отправка данных на $serverAddress пропущена."
	Write-Output "Настройка доступа к журналу Security для пользователя $mp10collector ..."
	$userSid = wmic useraccount where "name='$mp10collector'" get sid | Select-Object -Skip 2
	$userSid = ([string]$userSid).Trim()
	wevtutil sl Security "/ca:O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)(A;;0x1;;;$userSid)"
	try {
		Enable-NetFirewallRule -DisplayName "Удаленное управление журналом событий (именованные каналы - входящий)" -ErrorAction Stop
		Enable-NetFirewallRule -DisplayName "Удаленное управление журналом событий (RPC)" -ErrorAction Stop
		Enable-NetFirewallRule -DisplayName "Удаленное управление журналом событий (RPC-EPMAP)" -ErrorAction Stop
	} catch {
		Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC)"
		Enable-NetFirewallRule -DisplayName "Remote Event Log Management (NP-In)"
		Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC-EPMAP)"
	}
}


Write-Host "Настройка завершена." -ForegroundColor green

