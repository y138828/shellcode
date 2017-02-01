;
;  Copyright © 2017 Odzhan. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;

    bits 32

; returns pointer to GetProcAddress in ebp
locate_gpa:
    push   30h
    pop    edx
    mov    ebx, [fs:edx]      ; ebx = peb
    mov    ebx, [ebx+08h]     ; ebx = ImageBaseAddress
    add    edx, [ebx+3ch]     ; eax = e_lfanew
    mov    esi, [ebx+edx+50h]
    add    esi, ebx
imp_l0:
    lodsd                   ; OriginalFirstThunk +00h
    xchg   eax, ebp         ; store in ebp
    lodsd                   ; TimeDateStamp      +04h
    lodsd                   ; ForwarderChain     +08h
    lodsd                   ; Name               +0Ch
    xchg   eax, edx         ; store in edx
    lodsd                   ; FirstThunk         +10h 
    xchg   eax, edi         ; store in edi
    
    mov    eax, [edx+ebx]
    or     eax, 20202020h   ; convert to lowercase
    cmp    eax, 'kern'
    jnz    imp_l0
    
    mov    eax, [edx+ebx+4]
    or     eax, 20202020h   ; convert to lowercase
    cmp    eax, 'el32'
    jnz    imp_l0
    
    lea    esi, [ebp+ebx]
    add    edi, ebx
imp_l1:
    lodsd                   ; eax = oft->u1.Function, oft++;
    scasd                   ; ft++;
    test   eax, eax
    jz     imp_l0           ; get next module if zero
    js     imp_l1           ; skip ordinals 
    
    cmp    dword[eax+ebx+2], 'GetP'
    jnz    imp_l1
    
    cmp    dword[eax+ebx+10], 'ddre'
    jnz    imp_l1
    
    mov    ebp, [edi-4]     ; ebp = ft->u1.Function
    ret
    